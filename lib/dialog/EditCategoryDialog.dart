import 'dart:convert';

import 'package:expansion_manager/models/category_change_notifier.dart';
import 'package:expansion_manager/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class EditCategoryDialog extends StatefulWidget {

  CategoryModel model;
  EditCategoryDialog(this.model);

  @override
  State<StatefulWidget> createState() =>
      EditCategoryDialogState(this.model);
}

class EditCategoryDialogState extends State<EditCategoryDialog> {

  CategoryModel model;

  EditCategoryDialogState(CategoryModel model){
    this.model = model;
  }

  CategoryChangeNotifier _categoryChangeNotifier = new CategoryChangeNotifier();
  TextEditingController _categoryNameController = new TextEditingController();

  bool _favouriteSelection = false;

  //done but not used.
  final _colorList = [

    16711680,
    16711680,
    16711680,
    16711680,
  ];



  //done
  Widget _topWidget() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Text(
                      'Category Name',
                      style: TextStyle(fontSize: 15.0,color: Colors.white),
                    ),
                    InkWell(child: Icon(Icons.cancel,color: Colors.white,),onTap: (){
                      setState(() {
                        Navigator.pop(context);
                      });
                    },)
                  ],
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  //done
  Widget _midWidget(String itemName) {
    _categoryNameController.text = itemName;
    print(
        "=============================================================================");
    print(
        "=============================================================================");
    print(json.encode(model));
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
                    controller: _categoryNameController,
                    keyboardType: TextInputType.text,
                    onChanged: (value) {
                      model.name = value;
                      print(
                          "New amount $value==============================================================");
                    },
                    decoration: InputDecoration(
                      hintText: 'Category Name',
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

  //done but not used
  Widget _setColorWidget() {
    return Container(
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[Text("Choose Color",style: TextStyle(color: Colors.white),)],
            ),
          ),
          _colorsListView(),
          Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  new Checkbox(
                    value: _favouriteSelection,
                    onChanged: (bool value) {
                      setState(() {
                        _favouriteSelection = value;
                      });
                    },
                  ),
                  Text(
                    "Set as Favourite",
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  //done but not used.
  Widget _colorsListView() {
    return Container(
      height: 50,
      child: ListView.builder(itemBuilder: (context, index) {
        return InkWell(
          onTap: (){
            model.color = _colorList[index].toString();
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            height: 50,
            child: new CircleAvatar(
              foregroundColor: Color(_colorList[index]),
              radius: 20.0,
              //backgroundColor: Color(_colorList[index]),
            ),
          ),
        );
      },  itemCount: _colorList.length,
        scrollDirection: Axis.horizontal,
//          shrinkWrap: true,
      ),
    );
  }

  //done
  Widget _addCategoryWidget(){
    return Column(
      children: <Widget>[
        ButtonTheme(
          minWidth: 500.0,
          child: RaisedButton(
              color: Colors.greenAccent,
              disabledColor: Colors.greenAccent,
              child: Text("Update",style: TextStyle(color: Colors.white),),
              onPressed: (){
//                 int index;
                CategoryModel model = new CategoryModel();
//                 model.color = _colorList[index].toString();
                model.name = _categoryNameController.text;
//                 model.favourite = _favouriteSelection ? 1 : 0;
                Fluttertoast.showToast(
                    msg: "Categories is updated successfully",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIos: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0
                );
                _categoryChangeNotifier.update(model);
                Navigator.pop(context, true);
              },
              shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(8))
          ),
        )
      ],
    );
  }

  //done
  @override
  Widget build(BuildContext context) {
    _categoryChangeNotifier = Provider.of<CategoryChangeNotifier>(context);
    return AlertDialog(
        backgroundColor: Colors.blue[800],
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0))),
        content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _topWidget(),
              _midWidget(model.name.toString()),
              //_setColorWidget(),
              _addCategoryWidget(),
            ]));
  }
}

