import 'dart:convert';

import 'package:date_format/date_format.dart';
import 'package:expansion_manager/helper/database_helper.dart';
import 'package:expansion_manager/helper/injection.dart';
import 'package:expansion_manager/models/transaction_change_notifier.dart';
import 'package:expansion_manager/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EditAlertDialog extends StatefulWidget {
  TransactionModel _transactionModel;
  EditAlertDialog(this._transactionModel);

  @override
  State<StatefulWidget> createState() =>
      EditAlertDialogState(this._transactionModel);
}

class EditAlertDialogState extends State<EditAlertDialog> {
  final DatabaseHelper _db = Injection.injector.get<DatabaseHelper>();

  TransactionChangeNotifier _transactionList;
  String _type, _date, _amount, _itemName;
  DateTime _dateTime = new DateTime.now();
  var formatter = DateFormat('yyyy-MM-dd');

  TransactionModel _transactionModel;

  EditAlertDialogState(TransactionModel transactionModel) {
    this._transactionModel = transactionModel;
  }

  TextEditingController _itemNameController = new TextEditingController();
  TextEditingController _amountController = new TextEditingController();

  Future<void> _selectDatePicker(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: (_date != null)
            ? DateTime.parse(_date)
            : DateTime.parse(_transactionModel.date),
        firstDate: DateTime(2015, 18),
        lastDate: DateTime(2021, 18));
    // Select the date and its format in the (yyyy-MM-dd)
    if (picked != null && picked != _dateTime) {
      setState(() {
        var selectedVal = picked;
        var formattedDate = formatter.format(selectedVal);
        _transactionModel.date = formattedDate;
        _dateTime = picked;
        _date = formattedDate;

        print('Formatted/*/**/*/*/*/*/*/*** $formattedDate');
        print('/*/**/*/*/*/*/*/*** $_dateTime');
      });
    }
  }

  Widget _itemNameWidget(String itemName) {
    _itemNameController.text = itemName;
    print(
        "=============================================================================");
    print(
        "=============================================================================");
    print(json.encode(_transactionModel));
    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                new Expanded(
                  child: new TextField(
                    autofocus: true,
                    controller: _itemNameController,
                    keyboardType: TextInputType.text,
                    onChanged: (value) {
                      _itemName = value;
                      _transactionModel.itemName = value;
                      print(
                          "New amount $value==============================================================");
                    },
                    decoration: new InputDecoration(
                      hintText: 'Item Name',
                      hintStyle: TextStyle(fontSize: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          width: 0,
                          style: BorderStyle.none,
                        ),
                      ),
                      filled: true,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _amountWidget(String amount) {
    _amountController.text = amount;
    print(
        "=============================================================================");
    print(
        "=============================================================================");
    print(json.encode(_transactionModel));
    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                new Expanded(
                  child: new TextField(
                    autofocus: true,
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _amount = value;
                      _transactionModel.amount = double.parse(value);
                      print(
                          "New amount $value==============================================================");
                    },
                    decoration: new InputDecoration(
                      hintText: 'Amount',
                      hintStyle: TextStyle(fontSize: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          width: 0,
                          style: BorderStyle.none,
                        ),
                      ),
                      filled: true,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _dateWidget(String parsedDate) {
    return Row(
      children: <Widget>[
        Expanded(
          child: InkWell(
            onTap: () => _selectDatePicker(context),
            child: new Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                InkWell(child: Icon(Icons.date_range)),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: (parsedDate != null)
                      ? Text(
                    _transactionModel.date,
                    style: TextStyle(color: Colors.white),
                  )
                      : Text(
                      '${formatDate(_dateTime, [dd, '-', mm, '-', yyyy])}'),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _bottomWidget() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(
          child: InkWell(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(6)),
                color: Colors.lightBlueAccent,
              ),
              height: 45,
              child: Center(
                  child: new FlatButton(
                    onPressed: () {
                    _transactionModel.amount =
                        double.parse(_amountController.text);
                    _transactionModel.date =
                    (_date != null) ? _date : _transactionModel.date;
                    _transactionList.update(_transactionModel);
                     Navigator.pop(context, true);
                     },
                    child: Text(
                     "Update",
                      style: TextStyle(
                      color: Colors.white,
                  ),
                ),
              )),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _transactionList = Provider.of<TransactionChangeNotifier>(context);
    return AlertDialog(
        backgroundColor: Colors.blue[800],
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0))),
        content: Container(
            padding: const EdgeInsets.all(8),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Text(
                            _transactionModel.type.toString(),
                            style: TextStyle(fontSize: 20, color: Colors.white),
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
                          ),
                        ],
                      ),
                    ),

                    _itemNameWidget(_transactionModel.itemName.toString()),
                    _amountWidget(_transactionModel.amount.toString()),
                    _dateWidget(_transactionModel.date),
                    _bottomWidget(),
                  ]),
            )));
  }
}
