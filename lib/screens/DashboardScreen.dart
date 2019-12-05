import 'package:date_format/date_format.dart';
import 'package:expansion_manager/dialog/ListFilterDialog.dart';
import 'package:expansion_manager/dialog/SearchDialog.dart';
import 'package:expansion_manager/models/category_change_notifier.dart';
import 'package:expansion_manager/models/category_model.dart';
import 'package:expansion_manager/models/change_button_visibility.dart';
import 'package:expansion_manager/models/transaction_change_notifier.dart';
import 'package:expansion_manager/models/transaction_model.dart';
import 'package:expansion_manager/screens/EditTransactionScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  TransactionModel _transactionModel;

  DashboardScreen({Key key}) : super(key: key);

  @override
  _DashboardScreenState createState() {
    return _DashboardScreenState(this._transactionModel);
  }
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  Widget appBarTitle = new Text("Home");
  Icon actionIcon = new Icon(Icons.search);

  final key = new GlobalKey<ScaffoldState>();
  final TextEditingController _searchQuery = new TextEditingController();
  List<String> _list;
  bool _IsSearching;
  String _searchText = "";
  var currentSelectedValue, amountSelectedValues;
  CategoryModel categoryModel;
  TransactionChangeNotifier _transactionChangeNotifier;
  bool changeColor = false;
  bool isOpened = false;
  TextEditingController editingController = TextEditingController();
  CategoryChangeNotifier categoryChangeNotifier = new CategoryChangeNotifier();
  TransactionModel _transactionModel;
  static final String isCurrencySet = "currency";

  _DashboardScreenState(TransactionModel transactionModel) {
    this._transactionModel = transactionModel;
    _transactionModel = new TransactionModel(
        startDate: DateTime.now().toString(),
        endDate: DateTime.now().toString());

    _searchQuery.addListener(() {
      if (_searchQuery.text.isEmpty) {
        setState(() {
          _IsSearching = false;
          _searchText = "";
        });
      } else {
        setState(() {
          _IsSearching = true;
          _searchText = _searchQuery.text;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _IsSearching = false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _transactionChangeNotifier =
        Provider.of<TransactionChangeNotifier>(context);
    final buttonVisibilityNotifier =
    Provider.of<ChangeButtonVisibility>(context);
    return Scaffold(
      key: key,
      appBar: AppBar(
        leading: Builder(builder: (BuildContext context) {
          return IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () async {
              await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                        child: ListFilterDialog(TransactionModel.TYPE_CREDIT));
                  });
            },
          );
        }),
        centerTitle: true,
        title: appBarTitle,
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
              onPressed: () async {
                await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        child: SearchDialog(),
                      );
                    });
              })
        ],
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            // _searchListView(),
            _balanceWidgets(),
            _topWidget(),
          ],
        ),
      ),
    );
  }

// for show the total balances
  Widget _balanceWidgets() {
    return new Positioned(
      child: Container(
        width: MediaQuery
            .of(context)
            .size
            .width,
        height: 50,
        decoration: new BoxDecoration(
            gradient: new LinearGradient(
              colors: [
                const Color(0xFF00CCFF),
                const Color(0xFF3366FF),
              ],
            )),
        child: Center(
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2.0),
                    child: Text(
                      "   Balance    =  ",
                      style: TextStyle(fontSize: 20.0, color: Colors.white),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2.0),
                    child: Text(
                      balanceString(),
                      style: TextStyle(fontSize: 20.0, color: Colors.white),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topWidget() {
    return Container(
      margin: EdgeInsets.only(top: 50.0),
      child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            TransactionModel model = _transactionChangeNotifier.items[index];
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
                    _transactionChangeNotifier =
                        Provider.of<TransactionChangeNotifier>(context);
                    Fluttertoast.showToast(
                        msg: "Transaction Deleted Successfully",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                    _transactionChangeNotifier.delete(model);
                  },
                ),
              ],
            );
            // return _buildWidget();
          },
          itemCount: _transactionChangeNotifier.items.length),
    );
  }

  Widget _rowWidget(int index, TransactionModel model) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              height: 60,
              width: 8.0,
              color: (model.amount < 0) ? Colors.red : Colors.green,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Card(
                elevation: 10.0,
                child: Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.94,
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
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircleAvatar(
                                  radius: 30.0,
                                  backgroundColor: Colors.white,
                                  child: new Text(
                                    _transactionChangeNotifier
                                        .items[index].itemName.isNotEmpty
                                        ? _transactionChangeNotifier
                                        .items[index].itemName
                                        .substring(0, 1)
                                        .toUpperCase()
                                        : "",
                                    style: TextStyle(fontSize: 28.0),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                                child: new Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceEvenly,
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
                                            _transactionChangeNotifier
                                                .items[index].itemName
                                            //model.specificTrans.toString()
                                            ,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 18.0),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            //  model.currencySymbol.toString() ?? "" + model.amount.toString() ?? "",
                                            model.currencySymbol +
                                                model.amount.toString() ??
                                                "INR",
                                            // model.currencySymbol ?? "INR" + model.amount.toString(),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 18.0),
                                          ),
                                        ),
                                      ],
                                    ),
                                    new Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 7.0,
                                              right: 8.0,
                                              left: 1.0,
                                              top: 4.0),
                                          child: Text(
                                            //"  Shopping"
                                            //use transaction model to store
                                            _transactionChangeNotifier
                                                .items[index].categoryName ??
                                                '',
                                            style: TextStyle(fontSize: 18.0),
                                          ),
                                        ),

//                                        Padding(
//                                            padding: const EdgeInsets.all(8.0),
//                                            //  child: categoryModel.favourite == 1 ? Icon(Icons.star) : Container()
//                                            //  child: Icon(Icons.star)
//                                        ),
                                      ],
                                    )
                                  ],
                                )),
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
                                  Icon(Icons.calendar_today),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: Text(
                                      formatDate(DateTime.parse(model.date),
                                          [dd, '-', mm, '-', yyyy]),
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 18.0),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 0.0),
                                child: new InkWell(
                                  onTap: () {
                                    Provider
                                        .of<ChangeButtonVisibility>(context)
                                        .visible = false;
                                    Navigator.push(
                                        context,
                                        new MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                EditTransactionScreen(
                                                    _transactionChangeNotifier
                                                        .items[index]))).then(
                                            (v) {
                                          Provider
                                              .of<ChangeButtonVisibility>(
                                              context)
                                          .visible = true;
                                    });
                                  },
                                  child: new Padding(
                                    padding: new EdgeInsets.all(10.0),
                                    child: new Icon(Icons.edit),
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

  String balanceString() {
    String balance = "";
    _transactionChangeNotifier.totalBalanceData.forEach((balanceMap) {
      final tempString =
          balanceMap['currency_symbol'] + " " + balanceMap['amount'].toString();
      balance += " " + tempString;
    });
    return balance;
  }
}
