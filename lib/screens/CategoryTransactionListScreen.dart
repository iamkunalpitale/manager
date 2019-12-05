import 'package:date_format/date_format.dart';
import 'package:expansion_manager/dialog/EditAlertDialog.dart';
import 'package:expansion_manager/models/category_model.dart';
import 'package:expansion_manager/models/transaction_change_notifier.dart';
import 'package:expansion_manager/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class CategoryTransactionListScreen extends StatefulWidget {

  CategoryTransactionListScreen({Key key,}) : super(key: key);

  @override
  _CategoryTransactionListScreenState createState() {
    return _CategoryTransactionListScreenState();
  }
}

class _CategoryTransactionListScreenState extends State<CategoryTransactionListScreen>
    with SingleTickerProviderStateMixin {

  TransactionChangeNotifier _transactionChangeNotifier;

  bool changeColor = false;
  bool isOpened = false;
  AnimationController _animationController;
  AnimationController _controller;
  static const List<IconData> icons = const [Icons.add, Icons.remove];

  @override
  initState() {
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  @override
  Widget build(BuildContext context,) {
    _transactionChangeNotifier = Provider.of<TransactionChangeNotifier>(context);
    CategoryModel ctgmodel = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title:  new Text(ctgmodel.name),
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            _topWidget(),
            //  _balanceWidgets(),
          ],
        ),
      ),
    );
  }

  Widget _topWidget() {
    return Container(
      margin: EdgeInsets.only(top: 20.0),
      child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            TransactionModel model = _transactionChangeNotifier.filteredItems[index];
            return Slidable(
              child: _rowWidget(index, model),
              actionPane: SlidableDrawerActionPane(),
              actionExtentRatio: 0.25,
              secondaryActions: <Widget>[
                IconSlideAction(
                  caption: 'Delete',
                  color: (model.categoryColor == null)
                      ? Colors.blueGrey
                      : Color(int.parse(model.categoryColor)),
                  icon: Icons.delete,
                  onTap: () {
                    //TODO: add delete function here
                    _transactionChangeNotifier =
                        Provider.of<TransactionChangeNotifier>(context);
                    _transactionChangeNotifier.delete(model);
                  },
                ),
              ],
            );
          },

          itemCount: _transactionChangeNotifier.filteredItems.length),
    );
  }

  Widget _rowWidget(int index, TransactionModel model) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              height: 50,
              width: 5.0,
              color: (model.amount < 0) ? Colors.red : Colors.green,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Card(
                elevation: 8.0,
                //  color: (model.amount < 0) ? Colors.red : Colors.green,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.94,
                  decoration: BoxDecoration(
                      boxShadow: [
                        new BoxShadow(color: Colors.black, blurRadius: 5.0)
                      ],
                      borderRadius: BorderRadius.circular(12.0),
                      gradient: LinearGradient(colors: [
                        (model.categoryColor == null)
                            ? Colors.blueGrey
                            : Color(int.parse(model.categoryColor)),
                        (model.categoryColor == null)
                            ? Colors.blueGrey
                            : Color(int.parse(model.categoryColor)),
                        (model.categoryColor == null)
                            ? Colors.blueGrey
                            : Color(int.parse(model.categoryColor))
                      ])),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 5.0, right: 5.0, top: 12.0),
                        child: new Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircleAvatar(
                                radius: 30.0,
                                backgroundColor: Colors.white,
                                child: Text(_transactionChangeNotifier
                                    .filteredItems[index].itemName.isNotEmpty
                                    ? _transactionChangeNotifier
                                    .filteredItems[index].itemName.substring(
                                    0, 1).toUpperCase()
                                    : "",),
                              ),
                            ),
                            Expanded(
                                child: new Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    new Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 1.0, bottom: 2.0),
                                          child: Text(
                                            //"  Clothes"
                                            //use transaction model to store
                                             _transactionChangeNotifier.filteredItems[index].itemName,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 18.0),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            model.amount.toString(),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 18.0),
                                          ),
                                        ),
                                      ],
                                    ),
                                    new Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 7.0,
                                              right: 8.0,
                                              left: 8.0,
                                              top: 4.0),
                                          child: Text(
                                            //"  Shopping"
                                            // for category name.
                                            _transactionChangeNotifier.filteredItems[index].categoryName,
                                            style: TextStyle(fontSize: 18.0),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                )
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            gradient: LinearGradient(colors: [
                              (model.categoryColor == null)
                                  ? Colors.blueGrey
                                  : Color(int.parse(model.categoryColor)),
                              (model.categoryColor == null)
                                  ? Colors.blueGrey
                                  : Color(int.parse(model.categoryColor)),
                              (model.categoryColor == null)
                                  ? Colors.blueGrey
                                  : Color(int.parse(model.categoryColor))
                            ])),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 1.0, bottom: 0.0, left: 5.0, right: 5.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              new Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    "Date :" +
                                        formatDate(DateTime.parse(model.date),
                                            [dd, '-', mm, '-', yyyy]),
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 18.0),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 0.0),
                                child: new InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Container(
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5.0))),
                                            child: EditAlertDialog(
                                                _transactionChangeNotifier
                                                    .filteredItems[index]));
                                      },
                                    );
                                  },
                                  child: new Padding(
                                    padding: new EdgeInsets.all(10.0),
                                    child: new Text(
                                      "Edit",
                                      style: TextStyle(fontSize: 18.0),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  double totalAmount(List<TransactionModel> transList) {
    double amount = 0.0;

    for (var model in transList) {
      amount += model.amount;
    }
    return amount;
  }

}
