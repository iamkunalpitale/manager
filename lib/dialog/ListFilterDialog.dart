import 'dart:typed_data';

import 'package:date_format/date_format.dart';
import 'package:expansion_manager/dialog/SelectCategoryDialog.dart';
import 'package:expansion_manager/helper/database_helper.dart';
import 'package:expansion_manager/helper/injection.dart';
import 'package:expansion_manager/models/category_model.dart';
import 'package:expansion_manager/models/transaction_change_notifier.dart';
import 'package:expansion_manager/models/transaction_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ListFilterDialog extends StatefulWidget {
  String _type;
  TransactionModel _transactionModel;

  ListFilterDialog(this._type);

  @override
  State<StatefulWidget> createState() =>
      ListFilterDialogState(this._transactionModel);
}

class ListFilterDialogState extends State<ListFilterDialog> {
  final DatabaseHelper _db = Injection.injector.get<DatabaseHelper>();
  TransactionChangeNotifier _transactionList;
  String _type;
  DateTime _dateTime = new DateTime.now();
  Uint8List _bytesImage;
  String _image;
  String base64Image;
  TransactionModel model;
  var currentSelectedValue, amountSelectedValues, currentTypeValue,
      selectedTypeValue;
  final List<String> _amountValues = ["Greater than", "Less than"];
  final List<String> _typeValues = ["Credit", "Debit"];
  DateTime _startDateTime = new DateTime.now(); // start date
  DateTime _endDateTime = new DateTime.now(); // end date
  TransactionChangeNotifier _transactionChangeNotifier;

  ListFilterDialogState(TransactionModel transactionModel) {
    this.model = transactionModel;
    model = new TransactionModel(
        startDate: DateTime.now().toString(),
        endDate: DateTime.now().toString());
  }

  TextEditingController _amountController = new TextEditingController();
  TextEditingController _transactionNameController =
      new TextEditingController();

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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _categoryWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Column(
                children: <Widget>[
                  InkWell(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: Container(
                            color: Color(0xFF004f9e),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                model.categoryName == null
                                    ? "Select Category"
                                    : model.categoryName,
                                style: TextStyle(
                                    color: Color(0xff4D84BB), fontSize: 20.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    onTap: () async {
                      var result = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: SelectCategoryDialog());
                          });
                      if (result is CategoryModel) {
                        setState(() {
                          model.categoryId = result.id;
                          model.categoryName = result.name;
                          //  model.categoryColor = result.color;
                        });
                      }
                    },
                  ),
                ],
              ),
            ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _transactionChangeNotifier =
        Provider.of<TransactionChangeNotifier>(context);
    return AlertDialog(
        backgroundColor: Color(0xff0576E7),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0))),
        content: Container(
            padding: const EdgeInsets.all(8),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(9.0),
                      child: Center(
                        child: Text(
                          "Credit Filter",
                          style: TextStyle(fontSize: 18.0, color: Colors.white),
                        ),
                      ),
                    ),
                    InkWell(
                      child: Icon(
                        Icons.cancel,
                        color: Colors.white,
                      ),
                      onTap: () {
                        setState(() {
                          Navigator.pop(context, -1);
                        });
                      },
                    )
                  ],
                ),
                //   _transactionType(),
                _categoryWidget(),
                _filterAmount(),
                _amountTextField(),
                _startDateWidget(),
                _endDateWidget(),
                _filterButton(),
              ]),
            )));
  }


  // Greater and Less than Drop Down
  Widget _filterAmount() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: FormField<String>(
        builder: (FormFieldState<String> state) {
          return InputDecorator(
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0))),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                hint: Text("Select "),
                value: currentSelectedValue,
                isDense: true,
                onChanged: (newValue) {
                  setState(() {
                    currentSelectedValue = newValue;
                  });
                  print(currentSelectedValue);
                },
                items: _amountValues.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  // Credit , Debit Type Value
  Widget _transactionType() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: FormField<String>(
        builder: (FormFieldState<String> state) {
          return InputDecorator(
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0))),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                hint: Text(currentTypeValue),
                value: currentTypeValue,
                isDense: true,
                onChanged: (newValue) {
                  setState(() {
                    currentTypeValue = newValue;
                  });
                  print(currentTypeValue);
                },
                items: _typeValues.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _amountTextField() {
    return Row(children: <Widget>[
      new Expanded(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: new TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
            enabled: true,
            decoration: InputDecoration(
              filled: false,
              labelText: 'Amount',
              hintText: "Amount name",
            ),
          ),
        ),
        flex: 2,
      ),
    ]);
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
                      InkWell(child: Text("Start Date - ")),
                      Padding(
                        padding: const EdgeInsets.all(1.0),
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
                        padding: const EdgeInsets.all(1.0),
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

  Widget _filterButton() {
    return Column(
      children: <Widget>[
        ButtonTheme(
          minWidth: 500.0,
          child: RaisedButton(
              color: Color(0xff12E294),
              disabledColor: Colors.greenAccent,
              child: Text(
                "Filter",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () async {
                await _listFilterData();
                Navigator.pop(context, true);
              },
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(8))),
        )
      ],
    );
  }

  Future<void> _listFilterData() async {
    double d = double.parse(_amountController.text);
    await _transactionChangeNotifier.listFilter(TransactionModel.TYPE_CREDIT,
        categoryName: model.categoryName,
        amount: d.toString(),
        startDate: model.startDate,
        endDate: model.endDate);
  }
}
