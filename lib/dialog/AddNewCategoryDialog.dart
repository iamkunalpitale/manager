import 'package:expansion_manager/colorpicker/block_picker.dart';
import 'package:expansion_manager/models/category_change_notifier.dart';
import 'package:expansion_manager/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class AddNewCategoryDialog extends StatefulWidget {

  AddNewCategoryDialog();

  @override
  State<StatefulWidget> createState() =>
      AddNewCategoryDialogState();
  }

class AddNewCategoryDialogState extends State<AddNewCategoryDialog> {

  Color currentColor;

  void changeColor(Color color) => setState(() => currentColor = color);

  CategoryModel model = new CategoryModel();
  CategoryChangeNotifier _categoryChangeNotifier = new CategoryChangeNotifier();
  TextEditingController _categoryNameController = new TextEditingController();

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
                    InkWell(child: Icon(Icons.cancel, color: Colors.white,),
                      onTap: (){
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
  Widget _midWidget() {
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
                   decoration: InputDecoration(
                     hintText: 'Category Name',
                     hintStyle: TextStyle(
                         fontSize: 16, color: Color(0xff4D84BB)),
                     border: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(8),
                       borderSide: BorderSide(
                         width: MediaQuery
                             .of(context)
                             .size
                             .width,
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
        )
      ],
    );
  }

  //used but only favorite values
  Widget _setFavoriteWidget() {
    return Container(
      height: 80,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                new Checkbox(
                  value: model.favourite == 1 ? true : false,
                  onChanged: (bool value) async {
                    setState(() {
                      value == true ? model.favourite = 1 : model.favourite = 0;
                      }
                    );
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
      ),
    );
  }

  //used but only color values
  Widget _setColorWidget() {
    return Container(
        child: Column(
          children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[Text("Choose Color",style: TextStyle(color: Colors.white),)],
               ),
             ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: BlockPicker(
                pickerColor: currentColor,
                onColorChanged: changeColor,
                 ),
              ),
          ],
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
               child: Text("ADD",style: TextStyle(color: Colors.white),),
               onPressed: () async{
                 String selectedCompColor = (currentColor.value).toString();
                 model.color = selectedCompColor;
                 model.name = _categoryNameController.text;
                 Fluttertoast.showToast(
                     msg: "Categories is successfully Added",
                     toastLength: Toast.LENGTH_SHORT,
                     gravity: ToastGravity.CENTER,
                     timeInSecForIos: 1,
                     backgroundColor: Colors.red,
                     textColor: Colors.white,
                     fontSize: 16.0
                 );
                 await _categoryChangeNotifier.add(model);
                 Navigator.pop(context);
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
        content: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _topWidget(),
                _midWidget(),
                _setColorWidget(),
                _setFavoriteWidget(),
                _addCategoryWidget(),
              ]),
        ));
  }
}

