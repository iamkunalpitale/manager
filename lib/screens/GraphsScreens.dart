import 'package:charts_flutter/flutter.dart' as charts;
import 'package:date_format/date_format.dart';
import 'package:expansion_manager/models/transaction_change_notifier.dart';
import 'package:expansion_manager/models/transaction_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GraphScreens extends StatefulWidget {
  TransactionModel _transactionModel;

  GraphScreens();

  @override
  _GraphScreenState createState() => _GraphScreenState(this._transactionModel);
}

class ClicksPerYear {
  final String year;
  final int clicks;
  final charts.Color color;

  ClicksPerYear(this.year, this.clicks, Color color)
      : this.color = new charts.Color(
            r: color.red, g: color.green, b: color.blue, a: color.alpha);
}

class _GraphScreenState extends State<GraphScreens> {
  TransactionModel model;
  TransactionChangeNotifier _transactionChangeNotifier;
  DateTime _startDateTime = new DateTime.now(); // start date
  DateTime _endDateTime = new DateTime.now(); // end date
  TextEditingController _textFieldController = TextEditingController();
  List<Map<String, dynamic>> _graphData = [];

  _GraphScreenState(TransactionModel transactionModel) {
    this.model = transactionModel;
    model = new TransactionModel(
        startDate: DateTime.now().toString(),
        endDate: DateTime.now().toString());
  }

  // Select Start Date Picker
  Future<void> _selectStartDatePicker(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.parse(model.startDate),
        firstDate: DateTime(2015, 18),
        lastDate: DateTime.now());

    if (picked != null && picked != _startDateTime) {
      if (picked != null) {
        setState(() {
          model.startDate = formatDate(
              DateTime.parse(picked.toString()), [yyyy, '-', mm, '-', dd]);
          _startDateTime = picked;
        });
      }
    }
  }

  // Select End Date Picker
  Future<void> _selectEndDatePicker(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.parse(model.endDate),
        firstDate: DateTime(2015, 18),
        lastDate: DateTime.now());

    if (picked != null && picked != _endDateTime) {
      if (picked != null) {
        setState(() {
          model.endDate = formatDate(
              DateTime.parse(picked.toString()), [yyyy, '-', mm, '-', dd]);
          _endDateTime = picked;
        });
      }
    }
  }

  Widget _graphButton() {
    return FlatButton(onPressed: () async {
      await _transactionChangeNotifier.graphFilter(
          TransactionModel.TYPE_DEBIT, model.startDate, model.endDate);
    }, color: Colors.teal, child: Text("Graph"),);
  }

// start date widget for selecting the start date
  Widget _startDateWidget() {
    return Row(
      children: <Widget>[
        Expanded(
          child: InkWell(
            onTap: () => _selectStartDatePicker(context),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      InkWell(child: Text("Start Date ")),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${formatDate(_startDateTime, [
                            dd,
                            '-',
                            mm,
                            '-',
                            yyyy
                          ])}',
                          style: TextStyle(color: Colors.black),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // end date widget for selecting the end date
  Widget _endDateWidget() {
    return Row(
      children: <Widget>[
        Expanded(
          child: InkWell(
            onTap: () => _selectEndDatePicker(context),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      InkWell(child: Text("End Date -")),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${formatDate(_endDateTime, [
                            dd,
                            '-',
                            mm,
                            '-',
                            yyyy
                          ])}',
                          style: TextStyle(color: Colors.black),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // in this custom widget (start widget, end widget, graph button and graph)
  Widget _customDays() {
    var series = [
      new charts.Series<Map, String>(
        domainFn: (Map map, _) => map['category_name'],
        measureFn: (Map map, _) => map['amount'],
        colorFn: (_, __) => charts.MaterialPalette.gray.shade700,
        id: 'Clicks',
        data: _transactionChangeNotifier.graphData,
      ),
    ];
    var chart = new charts.BarChart(
      series,
      animate: true,
    );
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _startDateWidget(),
          _endDateWidget(),
          _graphButton(),
          Expanded(
            flex: 3,
            child: Align(
                alignment: Alignment.bottomCenter,
                child: chart), // show graph chart from chartWidget
          )
        ],
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    _transactionChangeNotifier =
        Provider.of<TransactionChangeNotifier>(context);
    return MaterialApp(
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
            appBar: AppBar(
              bottom: TabBar(
                tabs: [
                  Text('Last 7 Days', style: TextStyle(fontSize: 11),),
                  Text('Last 15 Days', style: TextStyle(fontSize: 11),),
                  Text('Last 30 Days', style: TextStyle(fontSize: 11),),
                  Text('Custom', style: TextStyle(fontSize: 11),)
                ],
              ),
            ),
            body: Center(
              child: Container(
                height: MediaQuery.of(context).size.height / 2,
                child: TabBarView(
                    children: List<Widget>.generate(4, (int index) {
                      if (index < 3)
                        return _getGraphContainer(index);
                      else
                        return _customDays();
                })),
              ),
            )),
      ),
    );
  }

  Widget _getGraphContainer(int index) {
    List<Map<String, dynamic>> mapData = [];
    switch (index) {
      case 0:
        mapData = _transactionChangeNotifier.sevenDaysGraphData;
        break;
      case 1:
        mapData = _transactionChangeNotifier.fifteenDaysGraphData;
        break;
      case 2:
        mapData = _transactionChangeNotifier.thirtyDaysGraphData;
        break;
      case 3:
        break;

      /*case 1: _getFifteenDaysGraphData(); break;
      case 2: _getThirtyDaysGraphData(); break;
      case 3: _customDays(); break;*/
    }
    var series = [
      new charts.Series<Map, String>(
        domainFn: (Map map, _) => map['category_name'],
        measureFn: (Map map, _) => map['amount'],
        colorFn: (_, __) => charts.MaterialPalette.gray.shade700,
        id: 'Clicks',
        data: mapData,
      ),
    ];
    var chart = new charts.BarChart(
      series,
      animate: true,
    );
    return Container(
      height: 100,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Align(
                alignment: Alignment.bottomCenter,
                child: chart), // show graph chart from chartWidget
          )
        ],
      ),
    );
  }

  List dateRes = [];

  Future<dynamic> showCustomDatePicker() async {
    var res = await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => MyDatePicker());
    return res;
  }
}

// Dialog with two Date Picker

class MyDatePicker extends StatefulWidget {
  @override
  _MyDatePickerState createState() => _MyDatePickerState();
}

class _MyDatePickerState extends State<MyDatePicker> {
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();

  List dates = [];

  Future showMyDatePicker(BuildContext context) async {
    var res = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2018),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.light(),
          child: child,
        );
      },
    );
    // truncate to remove the time part from the result
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(),
      content: Container(
        height: 250,
        width: MediaQuery.of(context).size.width - 10,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Choose Dates",
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: <Widget>[
                Flexible(
                  child: TextField(
                    controller: _startDateController,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[100],
                        hintText: "Start Date",
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey))),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                OutlineButton(
                  color: Colors.blue,
                  child: Text("Add Date"),
                  onPressed: () {
                    showMyDatePicker(context).then((res) {
                      if (res != null) {
                        setState(() {
                          _startDateController.text = "$res";
                          dates.add(_startDateController.text);
                        });
                      }
                    });
                  },
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: <Widget>[
                Flexible(
                  child: TextField(
                    controller: _endDateController,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[100],
                        hintText: "End Date",
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey))),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                OutlineButton(
                  color: Colors.blue,
                  child: Text("Add Date"),
                  onPressed: () {
                    showMyDatePicker(context).then((res) {
                      if (res != null) {
                        setState(() {
                          _endDateController.text = "$res";
                          dates.add(_endDateController.text);
                        });
                      }
                    });
                  },
                )
              ],
            ),
            Center(
              child: OutlineButton(
                color: Colors.blue,
                child: Text(
                  "SET",
                  style: TextStyle(color: Colors.blue),
                ),
                onPressed: () {
                  if (dates.isEmpty) {
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).pop(dates);
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
