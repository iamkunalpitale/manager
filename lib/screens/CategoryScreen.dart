import 'package:expansion_manager/dialog/AddNewCategoryDialog.dart';
import 'package:expansion_manager/dialog/EditCategoryDialog.dart';
import 'package:expansion_manager/models/category_change_notifier.dart';
import 'package:expansion_manager/models/category_model.dart';
import 'package:expansion_manager/models/change_button_visibility.dart';
import 'package:expansion_manager/models/transaction_change_notifier.dart';
import 'package:expansion_manager/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class CategoryScreen extends StatefulWidget {
  CategoryScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CategoryScreenState();
}

class CategoryScreenState extends State<CategoryScreen> {
  TransactionModel model;
  CategoryChangeNotifier _categoriesChangeNotifier;
  TransactionChangeNotifier _transactionChangeNotifier;


  //done
  @override
  Widget build(BuildContext context) {
    _categoriesChangeNotifier = Provider.of<CategoryChangeNotifier>(context);
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: Icon(Icons.add), onPressed: () async {
            var returnValue = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                              Radius.circular(10.0))),
                      child: AddNewCategoryDialog());
                });
            if (returnValue is CategoryModel) {
              _categoriesChangeNotifier.add(returnValue);
            }
          }),
          title: Text("Categories"),


        ),
      body: Container(
          child: Stack(
            children: <Widget>[
              _categoriesWidget(),
            ],
          )
      ),
    );
  }

  //done
  Widget _categoriesWidget() {
    return Container(
      child: ListView.builder(
          itemCount: _categoriesChangeNotifier.items.length,
          padding: EdgeInsets.only(bottom: 2.0),
          itemBuilder: (BuildContext context, int index) {
            CategoryModel ctgmodel = _categoriesChangeNotifier.items[index];
            _categoriesChangeNotifier = Provider.of<CategoryChangeNotifier>(context);
            return InkWell(
              onTap: () async {
                Provider
                    .of<ChangeButtonVisibility>(context)
                    .visible = false;
                _transactionChangeNotifier = Provider.of<TransactionChangeNotifier>(context);
                await _transactionChangeNotifier.filterList(ctgmodel);
                Navigator.pushNamed(context, '/transactionlistboard',
                  arguments: ctgmodel,
                ).then((v) {
                  Provider
                      .of<ChangeButtonVisibility>(context)
                      .visible = true;
                });
              },
              child: Slidable(
                child: _listViewWidget(index, ctgmodel),
                actionPane: SlidableDrawerActionPane(),
                actionExtentRatio: 0.25,
                actions: <Widget>[
                  IconSlideAction(
                    caption: 'Edit',
                    color: Colors.red,
                    icon: Icons.edit,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all
                                    (Radius.circular(5.0))),
                              child: EditCategoryDialog(
                                  _categoriesChangeNotifier.items[index]));
                        },
                      );
                    },
                  ),
                ],
                secondaryActions: <Widget>[
                  IconSlideAction(
                    caption: 'Delete',
                    color: Colors.red,
                    icon: Icons.delete,
                    onTap: () {
                      _categoriesChangeNotifier = Provider.of<CategoryChangeNotifier>(context);
                      Fluttertoast.showToast(
                          msg: "Categories is deleted successfully",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIos: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0
                      );
                      _categoriesChangeNotifier.delete(ctgmodel);
                    },
                  ),
                ],
              ),
            );
          }),
    );
  }

  //done
  Widget _listViewWidget(int index, CategoryModel model) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              height: 50,
              width: 5.0,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.96,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Container(
                        width: 50.0,
                        height: 50.0,
                        decoration: BoxDecoration(
                            border: Border.all(width: 2.0, color: Colors.white),
                            color: Color((int.parse(model.color))),
                            shape: BoxShape.circle),
                      ),
                      Expanded(
                        child: new Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    model.name,
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 17.0),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                          child: model.favourite == 1 ? Icon(
                            Icons.star, color: Colors.red,) : Container()
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
        new Divider(
          color: Colors.black,
        ),
      ],
    );
  }


}
