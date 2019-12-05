import 'dart:async';
import 'dart:convert';

import 'package:expansion_manager/helper/injection.dart';
import 'package:expansion_manager/helper/preferences_interface.dart';
import 'package:expansion_manager/models/transaction_change_notifier.dart';
import 'package:expansion_manager/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class DropDownScreen extends StatefulWidget {
  DropDownScreen({
    Key key,
  }) : super(key: key);

  @override
  _DropDownScreenState createState() {
    return _DropDownScreenState();
  }
}

class _DropDownScreenState extends State<DropDownScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  TransactionChangeNotifier _transactionChangeNotifier;
  TransactionModel model;
  StreamController<String> streamController = new StreamController();
  String _mySelectedCurrency;
  final PreferencesInterface _sharedPrefrence =
      Injection.injector.get<PreferencesInterface>();
  List<Map> _myCurrencies;

  @override
  void initState() {
    super.initState();
    _loadLocalJsonData();
  }

  @override
  void dispose(){
    streamController.close();
    super.dispose();

  }

  Future _loadLocalJsonData() async {
    String jsonCurrency =
        await rootBundle.loadString("lib/assets/currencies.json");
    setState(() {
      _myCurrencies = List<Map>.from(jsonDecode(jsonCurrency) as List);
      print("*******_myCurrencies: $_myCurrencies");
    });
  }

  @override
  Widget build(BuildContext context) {
    _transactionChangeNotifier =
        Provider.of<TransactionChangeNotifier>(context);
    return _myCurrencies == null ? _buildWait(context) : _buildRun(context);
  }

  Widget _buildRun(BuildContext context) {
    final _itemsName = _myCurrencies.map((c) {
      return new DropdownMenuItem<String>(
        value: c["cc"].toString(),
        child: new Text(c["symbol"].toString()),
      );
    }).toList();
    return new Scaffold(
        appBar: AppBar(
          title: Text("Currency Picker"),
        ),
        key: _scaffoldKey,
        body: new SafeArea(
            top: false,
            bottom: false,
            child: new Form(
                key: _formKey,
                child: new ListView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 32.0),
                  children: <Widget>[
                    new FormField<String>(
                      builder: (FormFieldState<String> state) {
                        return InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'CHOOSE CURRENCY',
                            labelStyle: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700),
                            errorText: state.hasError ? state.errorText : null,
                          ),
                          isEmpty: _mySelectedCurrency == '',
                          child: new DropdownButtonHideUnderline(
                            child: new DropdownButton<String>(
                              isExpanded: true,
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                              value: _mySelectedCurrency,
                              isDense: true,
                              onChanged: (String newValue) {
                                setState(() async {
                                  _mySelectedCurrency = newValue;
                                  await _sharedPrefrence.saveCurrency(newValue);
                                  //streamController.add(newValue);
                                });
                                Navigator.pop(context);
                              },
                              items: _itemsName,
                            ),
                          ),
                        );
                      },
                      validator: (val) {
                        return val != '' ? null : 'Choose Currency...';
                      },
                    ),
                  ],
                ))));
  }

  Widget _buildWait(BuildContext context) {
    return new Scaffold(
      body: new Center(child: CircularProgressIndicator()),
    );
  }
}
