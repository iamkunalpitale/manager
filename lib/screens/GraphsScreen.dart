import 'package:charts_flutter/flutter.dart' as charts;
import 'package:date_format/date_format.dart';
import 'package:expansion_manager/models/transaction_change_notifier.dart';
import 'package:expansion_manager/models/transaction_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GraphsScreen extends StatefulWidget {
  TransactionModel _transactionModel;

  GraphsScreen();

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

class _GraphScreenState extends State<GraphsScreen> {
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
        lastDate: DateTime(2021, 18));

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
        lastDate: DateTime(2021, 18));

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

  Widget _lastSevenDays() {
    return FlatButton(
      onPressed: _getSevenDaysGraphData,
      child: Text("Last 7 Days"),
      color: Colors.red,
    );
  }

  Widget _lastfifteenDays() {
    return FlatButton(
      onPressed: _getFifteenDaysGraphData,
      child: Text("Last 15 Days"),
      color: Colors.green,
    );
  }

  Widget _lastThirtyDays() {
    return FlatButton(
      onPressed: _getThirtyDaysGraphData,
      child: Text("Last 30 Days"),
      color: Colors.yellow,
    );
  }

  Widget _customDays() {
    return FlatButton(
      onPressed: () =>
          showCustomDatePicker().then((res) {
            print(res);
            _getGraphData();
          }),
      child: Text("Custom"),
      color: Colors.teal,
    );
  }

  @override
  Widget build(BuildContext context) {
    _transactionChangeNotifier =
        Provider.of<TransactionChangeNotifier>(context);
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
    var chartWidget = chart;
    return Scaffold(
      appBar: AppBar(
        title: Text("Graphs"),
      ),
      body: Container(
        height: 650,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  _lastSevenDays(),
                  _lastfifteenDays(),
                  _lastThirtyDays(),
                  _customDays()
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: chartWidget
              ), // show graph chart from chartWidget
            )
          ],
        ),
      ),
    );
  }


  void _getGraphData() async {
    List<Map<String, dynamic>> graphData =
    await _transactionChangeNotifier.graphFilter(
        TransactionModel.TYPE_CREDIT, model.startDate, model.endDate);
    print("-------------- startDate --------" + model.startDate);
    print("--------------endDate--------" + model.endDate);
    setState(() {
      _graphData.addAll(graphData);
    });
  }

  // last seven days graph data
  void _getSevenDaysGraphData() async {
    _transactionChangeNotifier.clearGraphData();
    //last 7 days date
    DateTime pastDays = DateTime.now().subtract(Duration(days: 7));
    DateTime currentDay = DateTime.now();
    await _transactionChangeNotifier.graphFilter(
        TransactionModel.TYPE_CREDIT,
        formatDate(
            DateTime.parse(pastDays.toString()), [yyyy, '-', mm, '-', dd]),
        formatDate(
            DateTime.parse(currentDay.toString()), [yyyy, '-', mm, '-', dd]));
    print(pastDays);
    print(currentDay);
  }

  // last fifteen days graph data
  void _getFifteenDaysGraphData() async {
    _transactionChangeNotifier.clearGraphData();
    //last 7 days date
    DateTime pastDays = DateTime.now().subtract(Duration(days: 15));
    DateTime currentDay = DateTime.now();
    await _transactionChangeNotifier.graphFilter(
        TransactionModel.TYPE_CREDIT,
        formatDate(
            DateTime.parse(pastDays.toString()), [yyyy, '-', mm, '-', dd]),
        formatDate(
            DateTime.parse(currentDay.toString()), [yyyy, '-', mm, '-', dd]));
    print(pastDays);
    print(currentDay);
  }

  // last thirty days graph data
  void _getThirtyDaysGraphData() async {
    _transactionChangeNotifier.clearGraphData();
    //last 30 days date
    DateTime pastMonth = DateTime.now().subtract(Duration(days: 30));
    DateTime currentDay = DateTime.now();
    await _transactionChangeNotifier.graphFilter(
        TransactionModel.TYPE_CREDIT,
        formatDate(
            DateTime.parse(pastMonth.toString()), [yyyy, '-', mm, '-', dd]),
        formatDate(
            DateTime.parse(currentDay.toString()), [yyyy, '-', mm, '-', dd]));
    print(pastMonth);
    print(currentDay);
  }

  List dateRes = [];

  Future<dynamic> showCustomDatePicker() async {
    var res = await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => MyDatePicker()
    );
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
        width: MediaQuery
            .of(context)
            .size
            .width - 10,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Choose Dates", textAlign: TextAlign.center,),
            SizedBox(height: 10,),
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
                            borderSide: BorderSide(
                                color: Colors.grey
                            )
                        )
                    ),
                  ),
                ),
                SizedBox(width: 10,),
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
                            borderSide: BorderSide(
                                color: Colors.grey
                            )
                        )
                    ),
                  ),
                ),
                SizedBox(width: 10,),
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
                child: Text("SET", style: TextStyle(color: Colors.blue),),
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