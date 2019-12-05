import 'package:expansion_manager/models/category_change_notifier.dart';
import 'package:expansion_manager/models/category_model.dart';
import 'package:expansion_manager/models/transaction_change_notifier.dart';
import 'package:expansion_manager/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class SelectCategoryDialog extends StatefulWidget {
  SelectCategoryDialog();

  @override
  State<StatefulWidget> createState() => SelectCategoryDialogState();
}

class SelectCategoryDialogState extends State<SelectCategoryDialog> {
  CategoryChangeNotifier _categoriesList = new CategoryChangeNotifier();
  TransactionChangeNotifier _transactionList = new TransactionChangeNotifier();
  TransactionModel _transactionModel;
  CategoryModel model;

  //done
  Widget _topWidget() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(9.0),
                  child: Text(
                    'Select Category',
                    style: TextStyle(fontSize: 18.0, color: Colors.white),
                  ),
                ),
                InkWell(
                  child: Icon(
                    Icons.cancel,
                    color: Colors.white,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  }, // onTap
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryListWidget() {
    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width,
      height: MediaQuery.of(context).size.width / 2,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: _categoriesList.items.length,
          itemExtent: 70.0,
          padding: EdgeInsets.only(bottom: 2.0),
          itemBuilder: (BuildContext context, int index) {
            return _categoryListViewWidget(index, model);
          }),
    );
  }

  Widget _categoryListViewWidget(int index, CategoryModel model) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            height: 30,
            width: 5.0,
          ),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                InkWell(
                  child: Row(
                    children: <Widget>[
                      new Container(
                        width: 50.0,
                        height: 50.0,
                        decoration: BoxDecoration(
                            color: Color(int.parse(_categoriesList.items[index].color)),
                            shape: BoxShape.circle),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Text(
                          _categoriesList.items[index].name,
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  ),
                  onTap: () {
                    Navigator.pop(context, _categoriesList.items[index]);
                  }, // OnTap
                )
              ],
            ),
          )
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    _categoriesList = Provider.of<CategoryChangeNotifier>(context);
    return AlertDialog(
        backgroundColor: Colors.blue[800],
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0))),
        content: Container(
            padding: const EdgeInsets.all(10),
            //height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _topWidget(),
                _categoryListWidget(),
              ],
            )));
  }
}
