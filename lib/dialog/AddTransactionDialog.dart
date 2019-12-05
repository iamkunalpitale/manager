import 'dart:convert';
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
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddTransactionDialog extends StatefulWidget {

  String _type;
  TransactionModel _transactionModel;
  AddTransactionDialog(this._type);

  @override
  State<StatefulWidget> createState() =>
      AddTransactionDialogState(this._type,this._transactionModel);
}

  class AddTransactionDialogState extends State<AddTransactionDialog> {
  final DatabaseHelper _db = Injection.injector.get<DatabaseHelper>();
  TransactionChangeNotifier _transactionList;
  String _type;
  DateTime _dateTime = new DateTime.now();
  Uint8List _bytesImage;
  String _image;
  String  base64Image;
  TransactionModel model;
  AddTransactionDialogState(String type,TransactionModel transactionModel) {
    this._type = type;
    this.model = transactionModel;

    model = new TransactionModel(
        amount: 0, date: DateTime.now().toString(), type: type);
  }

  TextEditingController _amountController = new TextEditingController();
  TextEditingController _transactionNameController = new TextEditingController();

  Future getImageFromCam()async{
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
  Future getImageFromGallery()async{
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
        lastDate: DateTime(2021, 18));

    if (picked != null && picked != _dateTime) {
      if (picked != null) {
        setState(() {
          model.date = formatDate(DateTime.parse(picked.toString()),
              [yyyy, '-', mm, '-', dd]);
          _dateTime = picked;
        });
      }
    }
  }

  //done
  Widget _transactionNameWidget() {
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
                    controller: _transactionNameController,
                    keyboardType: TextInputType.text,
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


  Widget _amountWidget() {
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
                    controller: _amountController,
                    keyboardType: TextInputType.number,
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

  Widget _cameraWidget(){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text('Camera', style: TextStyle(color: Colors.white),),
          InkWell( onTap: (){
            _settingModalBottomSheet(context);
          },
              child: Icon(Icons.camera_alt, color: Colors.white,)),
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
                  new Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      InkWell(child: Icon(Icons.date_range)),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('${formatDate(_dateTime, [dd, '-', mm, '-', yyyy])}',style: TextStyle(color: Colors.white),),
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

  Widget _buttonWidget(){
    return Column(
      children: <Widget>[
        ButtonTheme(
          minWidth: 500.0,
          child: RaisedButton(
              color: Colors.greenAccent,
              disabledColor: Colors.greenAccent,
              child: Text(
                "ADD",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                model.itemName = _transactionNameController.text;
                model.amount = double.parse(_amountController.text);
                model.image = _image.toString();
                await _transactionList.add(model);
                Navigator.pop(context,true);
              },
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(8))),
        )
      ],
    );
}


  Widget _categoryWidget(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              InkWell(
                child: Text(
                  model.categoryName == null ? "Select Category" : model.categoryName,
                  style: TextStyle(color: Colors.white,),
                ),
                onTap: () async {
                  var result = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(10.0))),
                            child: SelectCategoryDialog());
                      });

                  if (result is CategoryModel) {
                    setState(() {
                      model.categoryId = result.id;
                      model.categoryName = result.name;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _imageDisplay() {
    if(model.image == null){
      return Container();
    }
    var convert = Base64Decoder().convert(model.image);
    return Image.memory(convert);
  }

//  Widget _imageCameraDisplay() {
//    if (model.image == null) {
//      return Container();
//    }
//    var convert = Base64Decoder().convert(model.image);
//    return Image.memory(convert);
//  }

  @override
  Widget build(BuildContext context) {
    _transactionList = Provider.of<TransactionChangeNotifier>(context);
    return AlertDialog(
      backgroundColor: Colors.blue[700],
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0))),
        content: Container(
            height: MediaQuery
                .of(context)
                .size
                .height / 3,
            width: MediaQuery.of(context).size.width,
            child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(9.0),
                        child: Center(
                          child: Text(
                            _type,
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
                  _transactionNameWidget(),
                  _amountWidget(),
                  _categoryWidget(),
                  _dateWidget(),
                  _cameraWidget(),
                  _imageDisplay(),
                  _buttonWidget(),

                ]
            )
        )
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
                    }
                ),
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


//
//  Future getImageFromBase64String()async {
//    if (model.image == null)
//      return new Container();
//    Uint8List bytes = Base64Decoder().convert(model.image);
//    return new Scaffold(
//      body: new ListTile(
//        leading: new Image.memory(bytes),
//        title: new Text(model.image),
//      ),
//    );
////  }

}
