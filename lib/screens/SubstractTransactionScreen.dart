import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:date_format/date_format.dart';
import 'package:expansion_manager/dialog/SelectCategoryDialog.dart';
import 'package:expansion_manager/helper/database_helper.dart';
import 'package:expansion_manager/helper/injection.dart';
import 'package:expansion_manager/helper/preferences_interface.dart';
import 'package:expansion_manager/models/category_model.dart';
import 'package:expansion_manager/models/transaction_change_notifier.dart';
import 'package:expansion_manager/models/transaction_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class SubtractTransactionScreen extends StatefulWidget {
  String _type;
  TransactionModel _transactionModel;

  SubtractTransactionScreen(this._type);

  @override
  State<StatefulWidget> createState() =>
      SubtractTransactionScreenState(this._type);
}

class SubtractTransactionScreenState extends State<SubtractTransactionScreen> {
  final DatabaseHelper _db = Injection.injector.get<DatabaseHelper>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  StreamController<String> streamController = new StreamController();
  TransactionChangeNotifier _transactionList;
  String _type;
  DateTime _dateTime = new DateTime.now();
  Uint8List _bytesImage;
  String _image;
  List<Map> _myCurrencies;
  String base64Image;
  TransactionModel model;
  String _mySelectedCurrency;
  final PreferencesInterface _sharedPrefrence =
  Injection.injector.get<PreferencesInterface>();

  SubtractTransactionScreenState(String type) {
    this._type = type;

    model = new TransactionModel(
        amount: 0, date: DateTime.now().toString(), type: type);
  }

  TextEditingController _amountController = new TextEditingController();
  TextEditingController _transactionNameController =
  new TextEditingController();

  Future getImageFromCam() async {
    // TransactionModel _transactionModel = new TransactionModel();
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    // convert image and encode in it BASE64 String value
    List<int> imageBytes = image.readAsBytesSync();
    print(imageBytes);
    String base64Image = Base64Encoder().convert(imageBytes);
    _image = base64Image;
    setState(() {
      model.image = _image;
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
      model.image = _image;
    });
  }

  //

  Future<void> _selectDatePicker(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.parse(model.date),
        firstDate: DateTime(2015, 18),
        lastDate: DateTime.now());

    if (picked != null && picked != _dateTime) {
      if (picked != null) {
        setState(() {
          model.date = formatDate(
              DateTime.parse(picked.toString()), [yyyy, '-', mm, '-', dd]);
          _dateTime = picked;
        });
      }
    }
  }

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

  //done
  Widget _transactionNameWidget() {
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
                    controller: _transactionNameController,
                    keyboardType: TextInputType.text,
                    style: TextStyle(color: Colors.white),
                    inputFormatters: [
                      BlacklistingTextInputFormatter(
                          new RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%\s-]'))
                    ],
                    decoration: InputDecoration(
                      fillColor: Color(0xFF004f9e),
                      suffixIcon: Image.asset(
                          'lib/images/photo.png'),
                      hintText: 'Enter title',
                      hintStyle: TextStyle(
                          fontSize: 20.0, color: Color(0xff4D84BB)),
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

  Widget _amountWidget() {
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
                    decoration: InputDecoration(
                      fillColor: Colors.blue[900],
                      suffix: Text(
                        _sharedPrefrence.getCurrency(),
                        style: TextStyle(color: Colors.white),
                      ),
                      hintText: 'Enter Amount',
                      hintStyle: TextStyle(
                          fontSize: 20.0, color: Color(0xff4D84BB)
                      ),
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

  Widget _cameraWidget() {
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
                child: Image.asset(
                  'lib/images/select-image.png',
                  color: Colors.white,
                ),
              )),
        ],
      ),
    );
  }

  Widget _dateWidget() {
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
                              child: Text(
                                '${formatDate(_dateTime, [
                                  dd,
                                  '-',
                                  mm,
                                  '-',
                                  yyyy
                                ])}',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20.0),
                              ),
                            ),
                          ),
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

  Widget _buttonWidget() {
    return Container(
      height: 50,
      child: RaisedButton(
          color: Colors.greenAccent,
          child: Text(
            "SAVE",
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () async {
            model.itemName = _transactionNameController.text;
            model.amount = double.parse("-${_amountController.text}");
            model.image = _image.toString();
            model.currencySymbol = _sharedPrefrence.getCurrency();
            Fluttertoast.showToast(
                msg: "Subtraction Transaction is successfully Added",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIos: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
            await _transactionList.add(model);
            Navigator.pop(context);
          }),
    );
  }

  Widget _categoryWidget() {
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
                              child: Text(
                                model.categoryName == null
                                    ? "Select Category"
                                    : model.categoryName ?? "",
                                style:
                                TextStyle(
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
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(10.0))),
                                child: SelectCategoryDialog());
                          });

                      if (result is CategoryModel) {
                        setState(() {
                          model.categoryId = result.id;
                          model.categoryName = result.name;
                          model.categoryColor = result.color;
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

//  Widget _dropDownList() {
//    return _myCurrencies == null ? _buildWait(context) : _buildRun(context);
//  }

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
                        style: TextStyle(fontSize: 20.0, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                new Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InputDecorator(
                      decoration: InputDecoration(
                          fillColor: Color(0xFF004f9e),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)
                          )
                      ),
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
                          // Navigator.pop(context);
                        },
                        items: _itemsName,
                      ),
                    ),
                  ),
                ),
              ])))
    ]);
  }

  Widget _imageDisplay() {
    if (model.image == null) {
      return Container();
    }
    var convert = Base64Decoder().convert(model.image);
    return Image.memory(convert);
  }

  @override
  Widget build(BuildContext context) {
    _transactionList = Provider.of<TransactionChangeNotifier>(context);
    // print(_sharedPreferences.getCurrency());
    return Scaffold(
      appBar: AppBar(
        title: Text(_type),
      ),
      bottomNavigationBar: _buttonWidget(),
      backgroundColor: Colors.blue[700],
      body: Container(
          child: ListView(shrinkWrap: true, children: <Widget>[
            _transactionNameWidget(),
            _dropDownList(),
            _amountWidget(),
            _categoryWidget(),
            _dateWidget(),
            _cameraWidget(),
            _imageDisplay(),
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
