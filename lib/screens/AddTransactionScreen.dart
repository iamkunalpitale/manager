import 'dart:async';
import 'dart:convert';
import 'package:date_format/date_format.dart';
import 'package:expansion_manager/dialog/SelectCategoryDialog.dart';
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

class AddTransactionScreen extends StatefulWidget {
  final String _type;

  AddTransactionScreen(this._type);

  @override
  State<StatefulWidget> createState() => AddTransactionDialogState(this._type);
}

class AddTransactionDialogState extends State<AddTransactionScreen> {
  TransactionChangeNotifier _transactionList;
  String _type;
  DateTime _dateTime = new DateTime.now();

  TransactionModel _model;
  String _mySelectedCurrency;
  List<Map> _myCurrencies;

  final PreferencesInterface _sharedPreferences =
  Injection.injector.get<PreferencesInterface>();

  AddTransactionDialogState(String type) {
    this._type = type;
    _model = new TransactionModel(
        amount: 0, date: DateTime.now().toString(), type: type);
  }

  TextEditingController _amountController = new TextEditingController();
  TextEditingController _transactionNameController =
  new TextEditingController();

  Future getImageFromCam() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    // convert image and encode in it BASE64 String value
    List<int> imageBytes = image.readAsBytesSync();
    print(imageBytes);
    String base64Image = Base64Encoder().convert(imageBytes);
    setState(() {
      _model.image = base64Image;
    });
  }

  // add image string to model
  Future getImageFromGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    // convert image and encode in it BASE64 String value
    List<int> imageBytes = image.readAsBytesSync();
    print(imageBytes);
    String base64Image = Base64Encoder().convert(imageBytes);
    setState(() {
      _model.image = base64Image;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadLocalJsonData();
  }

  Future _loadLocalJsonData() async {
    String jsonCurrency =
    await rootBundle.loadString("lib/assets/currencies.json");
    setState(() {
      _myCurrencies = List<Map>.from(jsonDecode(jsonCurrency) as List);
    });
  }

  //

  Future<void> _selectDatePicker(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.parse(_model.date),
        firstDate: DateTime(2015, 18),
        lastDate: DateTime.now());

    if (picked != null && picked != _dateTime) {
      if (picked != null) {
        setState(() {
          _model.date = formatDate(
              DateTime.parse(picked.toString()), [yyyy, '-', mm, '-', dd]);
          _dateTime = picked;
        });
      }
    }
  }

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
                        style: TextStyle(fontSize: 15.0, color: Colors.white),
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
                        style: TextStyle(fontSize: 15.0, color: Colors.white),
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
                      fillColor: Color(0xFF004f9e),
                      suffix: Text(_sharedPreferences.getCurrency(),
                        style: TextStyle(color: Colors.white),),
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
                  style: TextStyle(fontSize: 15.0, color: Colors.white),
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
                  color: Color(0xFF004f9e),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)),
                    child: Image.asset(
                      'lib/images/select-image.png',
                      color: Color(0xff4D84BB),
                    ),
              )),
          )
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
                          style: TextStyle(fontSize: 15.0, color: Colors.white),
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
                            color: Color(0xFF004f9e),
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
          color: Color(0xff12E294),
          child: Text(
            "SAVE",
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () async {
            _model.itemName = _transactionNameController.text;
            _model.amount = double.parse(_amountController.text);
            _model.currencySymbol = _sharedPreferences.getCurrency();
            Fluttertoast.showToast(
                msg: "Transaction added successfully",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIos: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
            await _transactionList.add(_model);
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
                          style: TextStyle(fontSize: 15.0, color: Colors.white),
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
                            color: Color(0xFF004f9e),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                _model.categoryName == null
                                    ? "Select Category"
                                    : _model.categoryName,
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
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: SelectCategoryDialog()
                            );
                          }
                      );

                      if (result is CategoryModel) {
                        setState(() {
                          _model.categoryId = result.id;
                          _model.categoryName = result.name;
                          _model.categoryColor = result.color;
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
                        style: TextStyle(fontSize: 15.0, color: Colors.white),
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
                              borderRadius: BorderRadius.circular(5.0))
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
                            _sharedPreferences.saveCurrency(newValue);
                            //streamController.add(newValue);
                          });
                          //  Navigator.pop(context);
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
    if (_model.image == null) {
      return Container();
    }
    var convert = Base64Decoder().convert(_model.image);
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
      backgroundColor: Color(0xff0576E7),
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
