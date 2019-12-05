import 'dart:convert';

import 'package:date_format/date_format.dart';
import 'package:expansion_manager/dialog/SelectCategoryDialog.dart';
import 'package:expansion_manager/helper/database_helper.dart';
import 'package:expansion_manager/helper/injection.dart';
import 'package:expansion_manager/helper/preferences_interface.dart';
import 'package:expansion_manager/models/category_model.dart';
import 'package:expansion_manager/models/transaction_change_notifier.dart';
import 'package:expansion_manager/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EditTransactionScreen extends StatefulWidget {
  TransactionModel _transactionModel;

  EditTransactionScreen(this._transactionModel);

  @override
  State<StatefulWidget> createState() =>
      EditTransactionScreenState(this._transactionModel);
}

class EditTransactionScreenState extends State<EditTransactionScreen> {
  final DatabaseHelper _db = Injection.injector.get<DatabaseHelper>();

  String _mySelectedCurrency;
  List<Map> _myCurrencies;
  final PreferencesInterface _sharedPrefrence =
  Injection.injector.get<PreferencesInterface>();
  TransactionChangeNotifier _transactionList;
  String _type, _date, _amount, _itemName;
  String _image;
  DateTime _dateTime = new DateTime.now();
  var formatter = DateFormat('yyyy-MM-dd');

  TransactionModel _transactionModel;

  EditTransactionScreenState(TransactionModel transactionModel) {
    this._transactionModel = transactionModel;
  }

  var imageFileBytes;

  TextEditingController _itemNameController = new TextEditingController();
  TextEditingController _amountController = new TextEditingController();

  Future<void> _selectDatePicker(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: (_date != null)
            ? DateTime.parse(_date)
            : DateTime.parse(_transactionModel.date),
        firstDate: DateTime(2015, 18),
        lastDate: DateTime.now());
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

  Future getImageFromCam() async {
    // TransactionModel _transactionModel = new TransactionModel();
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    // convert image and encode in it BASE64 String value
    List<int> imageBytes = image.readAsBytesSync();
    print(imageBytes);
    String base64Image = Base64Encoder().convert(imageBytes);
    _image = base64Image;
    setState(() {
      _transactionModel.image = _image;

      print("------------" + _image);
    });
  }

  // add image string to model
  Future getImageFromGallery() async {
    // TransactionModel _transactionModel = new TransactionModel();
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    // convert image and encode in it BASE64 String value
    List<int> imageBytes = image.readAsBytesSync();
    print(imageBytes);
    String base64Image = Base64Encoder().convert(imageBytes);
    _image = base64Image;
    setState(() {
      _transactionModel.image = _image;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadLocalJsonData();
  }

  @override
  void dispose() {
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
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Title",
                        style: TextStyle(fontSize: 20.0, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new TextField(
                    controller: _itemNameController,
                    keyboardType: TextInputType.text,
                    style: TextStyle(color: Colors.white),
                    inputFormatters: [
                      BlacklistingTextInputFormatter(
                          new RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%\s-]'))
                    ],
                    onChanged: (value) {
                      _itemName = value;
                      _transactionModel.itemName = value;
                      print(
                          "New amount $value==============================================================");
                    },
                    decoration: InputDecoration(
                      fillColor: Colors.blue[900],
                      suffixIcon: Icon(Icons.title),
                      hintText: 'Enter title',
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
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropDownList(String parsedCurrency) {
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
                        _transactionModel.currencySymbol,
                        style: TextStyle(fontSize: 20.0, color: Colors.white),
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
                          _transactionModel.currencySymbol = newValue;
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
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Amount",
                        style: TextStyle(fontSize: 20.0, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Colors.white),
                    inputFormatters: [
                      WhitelistingTextInputFormatter.digitsOnly
                    ],
                    onChanged: (value) {
                      _amount = value;
                      _transactionModel.amount = double.parse(value);
                      print(
                          "New amount $value==============================================================");
                    },
                    decoration: InputDecoration(
                      fillColor: Colors.blue[900],
                      suffixIcon: Image.asset('lib/images/rs.png'),
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
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _categoryWidget(String parsedCategory) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Category",
                      style: TextStyle(fontSize: 20.0, color: Colors.white),
                    ),
                  ),
                ),
              ),
              InkWell(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: Container(
                        color: Colors.blue[900],
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: (parsedCategory != null)
                                ? Text(
                              _transactionModel.categoryName,
//                  model.categoryName == null
//                      ? "Select Category"
//                      : model.categoryName,
                              style: TextStyle(
                                  color: Colors.white, fontSize: 20.0),
                            )
                                : Text("")),
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
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0))),
                            child: SelectCategoryDialog());
                      });
                  if (result is CategoryModel) {
                    setState(() {
                      _transactionModel.categoryId = result.id;
                      _transactionModel.categoryName = result.name;
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

  Widget _dateWidget(String parsedDate) {
    return Row(
      children: <Widget>[
        Expanded(
          child: InkWell(
            onTap: () => _selectDatePicker(context),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Date",
                          style: TextStyle(fontSize: 20.0, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  new Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      InkWell(child: Image.asset('lib/images/calendar.png')),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          child: Container(
                              color: Colors.blue[900],
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: (parsedDate != null)
                                    ? Text(
                                  _transactionModel.date,
                                        style: TextStyle(color: Colors.white),
                                      )
                                    : Text(
                                        '${formatDate(_dateTime, [
                                          dd,
                                          '-',
                                          mm,
                                          '-',
                                          yyyy
                                        ])}',
                                        style: TextStyle(fontSize: 20.0),
                                      ),
                              )),
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

  getImageFromModel(TransactionModel model) {
    print("\n");
    if (model.image != null) {
      var bytes = base64.decode(model.image);
      print(bytes); //this must run

      setState(() {
        imageFileBytes = bytes;
      });
      return bytes;
    }
  }

  Widget _cameraWidget(TransactionModel model) {
    getImageFromModel(model);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Select Image",
                  style: TextStyle(fontSize: 20.0, color: Colors.white),
                ),
              ),
            ),
          ),
          InkWell(
              onTap: () {
                _settingModalBottomSheet(context);
              },
              child: Container(
                width: 300,
                height: 200,
                color: Colors.blue[900],
                child: imageFileBytes != null
                    ? Image.memory(
                  imageFileBytes,
                  // color: Colors.white,
                )
                    : new Center(
                  child: new Text("No Preview available !"),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buttonWidget() {
    return Container(
      height: 50,
      child: RaisedButton(
          color: Colors.greenAccent,
          child: Text(
            "SAVE",
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            _transactionModel.amount = double.parse(_amountController.text);
            _transactionModel.date =
            (_date != null) ? _date : _transactionModel.date;
            Fluttertoast.showToast(
                msg: "Transaction added successfully",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIos: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
            _transactionList.update(_transactionModel);
            Navigator.pop(context);
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    _transactionList = Provider.of<TransactionChangeNotifier>(context);
    print(json.encode(_transactionModel.image));
    return Scaffold(
      appBar: AppBar(
        title: Text(_transactionModel.type.toString()),
      ),
      bottomNavigationBar: _buttonWidget(),
      backgroundColor: Colors.blue[700],
      body: Container(
          child: ListView(shrinkWrap: true, children: <Widget>[
            _itemNameWidget(_transactionModel.itemName.toString()),
            _dropDownList(_transactionModel.currencySymbol.toString()),
            _amountWidget(_transactionModel.amount.toString()),
            _categoryWidget(_transactionModel.categoryName),
            _dateWidget(_transactionModel.date),
            _cameraWidget(_transactionModel),
          ])),
    );
  }

  // used the bottom sheet for showing gallery and camera
  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.camera),
                    title: new Text('Gallery'),
                    onTap: () => {
                          getImageFromGallery(),
                        }),
                new ListTile(
                  leading: new Icon(Icons.camera_alt),
                  title: new Text('Camera'),
                  onTap: () => {
                    getImageFromCam(),
                  },
                ),
              ],
            ),
          );
        });
  }
}
