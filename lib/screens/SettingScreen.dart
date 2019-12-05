import 'dart:async';
import 'dart:convert';

import 'package:expansion_manager/helper/injection.dart';
import 'package:expansion_manager/helper/preferences_interface.dart';
import 'package:expansion_manager/models/transaction_change_notifier.dart';
import 'package:expansion_manager/screens/DropDownScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingScreens extends StatefulWidget {
  SettingScreens({
    Key key,
  }) : super(key: key);

  @override
  SettingScreenState createState() {
    return SettingScreenState();
  }
}

class SettingScreenState extends State<SettingScreens> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  List<Map> _myCurrencies;
  TransactionChangeNotifier _transactionList;
  String _mySelectedCurrency;
  final PreferencesInterface _sharedPrefrence =
  Injection.injector.get<PreferencesInterface>();
  StreamController<String> streamController = new StreamController();

  @override
  void initState() {
    super.initState();
    _loadLocalJsonData();
  }

  @override
  void dispose() {
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


  // for export the CSV file

  Widget _exportToCSVWidget() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Export to CSV",
                        style: TextStyle(
                            fontSize: 20.0,
                            fontFamily: 'Champagne_Limousines',
                            color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropDownList() {
    final _itemsName = _myCurrencies?.map((c) {
      return new DropdownMenuItem<String>(
        value: c["cc"].toString(),
        child: new Text(c["symbol"].toString()),
      );
    })?.toList() ??
        [];
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
      Expanded(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Choose Currency",
                        style: TextStyle(fontSize: 15.0, color: Colors.black),
                      ),
                    ),
                  ),
                ),
                new Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
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
                        setState(() {
                          _mySelectedCurrency = newValue;
                          _sharedPrefrence.saveCurrency(newValue);
                          //streamController.add(newValue);
                        });
                        //  Navigator.pop(context);
                      },
                      items: _itemsName,
                    ),
                  ),
                ),
              ])))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Container(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              //  _exportToCSVWidget(),
              // Divider(color: Colors.black,),
              _dropDownList(),
            ],
          )),
    );
  }
}
