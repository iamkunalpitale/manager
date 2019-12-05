//import 'dart:core';
//import 'package:date_format/date_format.dart';
//import 'package:expansion_manager/unused/data_helper.dart';
//import 'package:expansion_manager/dialog/AddTransactionDialog.dart';
//import 'package:expansion_manager/dialog/EditAlertDialog.dart';
//import 'package:expansion_manager/helper/injection.dart';
//import 'package:expansion_manager/models/transaction_change_notifier.dart' as prefix0;
//import 'package:expansion_manager/models/transaction_model.dart';
//import 'package:expansion_manager/unused/TransactionList.dart';
//import 'package:flutter/cupertino.dart';
//import 'package:flutter/material.dart';
//import 'package:flutter_slidable/flutter_slidable.dart';
//import 'package:provider/provider.dart';
//
//class DashboardScreenOld extends StatefulWidget {
//  DashboardScreenOld({Key key}) : super(key: key);
//
//
//  @override
//  State<StatefulWidget> createState() => DashboardScreenOldState();
//}
//
//class DashboardScreenOldState extends State<DashboardScreenOld> {
//  final DatabaseHelperOld _db = Injection.injector.get<DatabaseHelperOld>();
//  TransactionList transactionList;
//  TransactionPresenter transactionPresenter;
//
//  List<TransactionModel> _transactionList = new List();
//  TransactionModel model;
//  bool changeColor = false;
//
//
//
//
// // final DatabaseHelper _db = new DatabaseHelper();
//
//  Widget _balanceWidgets() {
//    return Container(
//      child: Center(
//        child: Column(
//          children: <Widget>[
//            Row(
//              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//              children: <Widget>[
//                Padding(
//                  padding: const EdgeInsets.only(top: 15.0),
//                  child: Text(
//                    "Total Expenses",
//                    style: TextStyle(fontSize: 20.0),
//                  ),
//                ),
//                Padding(
//                  padding: const EdgeInsets.only(top: 15.0),
//                  child: Text(
//                    "Total Income",
//                    style: TextStyle(fontSize: 20.0),
//                  ),
//                )
//              ],
//            ),
//            new Row(
//              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//              children: <Widget>[
//                Padding(
//                  padding: const EdgeInsets.only(bottom: 15.0),
//                  child: Text(
//                    totalAmount(_transactionList).toString(),
//                    style: TextStyle(fontSize: 20.0),
//                  ),
//                ),
//                Padding(
//                  padding: const EdgeInsets.only(bottom: 15.0),
//                  child: Text(
//                    totalAmount(_transactionList).toString(),
//                    style: TextStyle(fontSize: 20.0),
//                  ),
//                )
//              ],
//            )
//          ],
//        ),
//      ),
//    );
//  }
//
////  Widget _topWidget() {
////    return Container(
////      margin: EdgeInsets.only(top: 70.0),
////      child: ListView.builder(
////        itemBuilder: (BuildContext context, int index) {
////          TransactionModel model = _transactionList[index];
////          return Slidable(
////            child: _rowWidget(model),
////            actionPane: SlidableDrawerActionPane(),
////            actionExtentRatio: 0.25,
////            secondaryActions: <Widget>[
////              IconSlideAction(
////                caption: 'Delete',
////                color: Colors.red,
////                icon: Icons.delete,
////                onTap: () {
////                  setState(() {
////                    _db.deleteTransaction(model);
////                    _transactionList.removeWhere((temp) {
////                      return model.id == temp.id;
////                    });
////                  });
////                },
////              ),
////            ],
////          );
////          // return _builddWidget();
////        },
////        itemCount: _transactionList.length,
////      ),
////    );
////  }
//
//  @override
//  void initState() {
//    super.initState();
//    updateUi();
//  }
//
//  void updateUi() {
//    _db.getTransactions().then((list) {
//      setState(() {
//        _transactionList = list;
//      });
//    });
//  }
////
////  Widget _listViewWidget() {
////    return StreamBuilder<List<TransactionModel>>(
////      stream: _db.getTransactionsStream(),
////      builder: (context, snapshot) {
////        return snapshot.hasData
////            ? ListView.builder(
////                itemBuilder: (BuildContext context, int index) {
////                  TransactionModel model = snapshot.data[index];
////                  return _rowWidget(model);
////                },
////                itemCount: _transactionList.length,
////              )
////            : Center(
////                child: new Text("Data not Loaded"),
////              );
////      },
////    );
////  }
//
////  Widget _rowWidget(TransactionModel model) {
////    return Column(
////      children: <Widget>[
////        Row(
////          mainAxisSize: MainAxisSize.max,
////          children: <Widget>[
////            Container(
////              height: 50,
////              width: 5.0,
////              color: (model.amount < 0) ? Colors.red : Colors.green,
////            ),
////            Padding(
////              padding: const EdgeInsets.only(bottom: 15.0),
////              child: Card(
////                elevation: 8.0,
////                //  color: (model.amount < 0) ? Colors.red : Colors.green,
////                child: Container(
////                  width: MediaQuery.of(context).size.width * 0.94,
////                  decoration: BoxDecoration(
////                      boxShadow: [
////                        new BoxShadow(color: Colors.black, blurRadius: 5.0)
////                      ],
////                      borderRadius: BorderRadius.circular(12.0),
////                      gradient: LinearGradient(colors: [
////                        Colors.pink[600],
////                        Colors.pink[600],
////                        Colors.pink[600]
////                      ])),
////                  child: new Column(
////                    crossAxisAlignment: CrossAxisAlignment.start,
////                    children: <Widget>[
////                      Padding(
////                        padding: const EdgeInsets.only(
////                            left: 5.0, right: 5.0, top: 12.0),
////                        child: new Row(
////                          mainAxisSize: MainAxisSize.max,
////                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
////                          children: <Widget>[
////                            Padding(
////                              padding: const EdgeInsets.all(8.0),
////                              child: CircleAvatar(
////                                radius: 30.0,
////                                backgroundColor: Colors.white,
////                              ),
////                            ),
////                            Expanded(
////                                child: new Column(
////                              mainAxisSize: MainAxisSize.max,
////                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
////                              children: <Widget>[
////                                new Row(
////                                  mainAxisAlignment:
////                                      MainAxisAlignment.spaceBetween,
////                                  children: <Widget>[
////                                    Padding(
////                                      padding: const EdgeInsets.only(
////                                          left: 1.0, bottom: 2.0),
////                                      child: Text(
////                                        "  Clothes",
////                                        style: TextStyle(
////                                            color: Colors.black,
////                                            fontSize: 18.0),
////                                      ),
////                                    ),
////                                    Padding(
////                                      padding: const EdgeInsets.all(8.0),
////                                      child: Text(
////                                        model.amount.toString(),
////                                        style: TextStyle(
////                                            color: Colors.black,
////                                            fontSize: 18.0),
////                                      ),
////                                    ),
////                                  ],
////                                ),
////                                new Row(
////                                  mainAxisAlignment:
////                                      MainAxisAlignment.spaceBetween,
////                                  children: <Widget>[
////                                    Padding(
////                                      padding: const EdgeInsets.only(
////                                          bottom: 7.0,
////                                          right: 8.0,
////                                          left: 8.0,
////                                          top: 4.0),
////                                      child: Text(
////                                        "Shopping",
////                                        style: TextStyle(fontSize: 18.0),
////                                      ),
////                                    ),
////                                  ],
////                                )
////                              ],
////                            )),
////                          ],
////                        ),
////                      ),
//////                new Column(
//////                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
//////                  children: <Widget>[
////////                    new IconButton(
////////                      icon: const Icon(
////////                        Icons.edit,
////////                        color: const Color(0xFF167F67),
////////                      ),
////////                      onPressed: () async {
////////                        bool checker = await showDialog(
////////                            context: context,
////////                            builder: (BuildContext context) {
////////                              return Container(
////////                                  decoration: BoxDecoration(
////////                                      borderRadius: BorderRadius.all(
////////                                          Radius.circular(5.0))),
////////                                  child: EditAlertDialog(
////////                                      model.id,
////////                                      model.type.toString(),
////////                                      _db,
////////                                      model.date.toString(),
////////                                      model.amount.toString()));
////////                            });
////////                       // update the UI
////////                        if (checker == true){
////////                          updateUi();
////////                        }
////////                      },
////////                    ),
////////                    new IconButton(
////////                      icon: const Icon(Icons.delete_forever,
////////                          color: const Color(0xFF167F67)),
////////                      onPressed: () {
////////                        setState(() {
////////                          _db.deleteTransaction(model);
////////                          _transactionList.removeWhere((temp) {
////////                            return model.id == temp.id;
////////                          });
////////                        });
////////                      },
////////                    ),
//////                  ],
//////                ),
////                      Container(
////                        decoration: BoxDecoration(
////                            borderRadius: BorderRadius.circular(8.0),
////                            gradient: LinearGradient(colors: [
////                              Colors.pink[900],
////                              Colors.pink[900],
////                              Colors.pink[900]
////                            ])),
////                        child: Padding(
////                          padding: const EdgeInsets.only(
////                              top: 1.0, bottom: 0.0, left: 5.0, right: 5.0),
////                          child: Row(
////                            mainAxisSize: MainAxisSize.max,
////                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
////                            children: <Widget>[
////                              new Row(
////                                mainAxisAlignment:
////                                    MainAxisAlignment.spaceBetween,
////                                children: <Widget>[
////                                  Text(
////                                    "Date :" +
////                                        formatDate(DateTime.parse(model.date),
////                                            [dd, '-', mm, '-', yyyy]),
////                                    style: TextStyle(
////                                        color: Colors.black, fontSize: 18.0),
////                                  ),
//////                            Text(
//////                              formatDate(DateTime.parse(model.date),
//////                                  [dd, '-', mm, '-', yyyy]),
//////                              style: TextStyle(
//////                                  color: Colors.black, fontSize: 15.0),
//////                            ),
////                                ],
////                              ),
//////                              Padding(
//////                                  padding: const EdgeInsets.only(top: 0.0),
//////                                  child: new InkWell(
//////                                    onTap: () async {
//////                                      bool checker = await showDialog(
//////                                          context: context,
//////                                          builder: (BuildContext context) {
//////                                            return Container(
//////                                                decoration: BoxDecoration(
//////                                                    borderRadius:
//////                                                        BorderRadius.all(
//////                                                            Radius.circular(
//////                                                                5.0))),
//////                                                child: EditAlertDialog(
//////                                                    model.id,
//////                                                    model.type.toString(),
//////                                                    model.date.toString(),
//////                                                    model.amount.toString()));
//////                                          });
//////                                      // update the UI
//////                                      if (checker == true) {
//////                                        updateUi();
//////                                      }
//////                                    },
//////                                    child: new Padding(
//////                                      padding: new EdgeInsets.all(10.0),
//////                                      child: new Text(
//////                                        "Edit",
//////                                        style: TextStyle(fontSize: 18.0),
//////                                      ),
//////                                    ),
//////                                  )),
//////                            ],
//////                          ),
//////                        ),
//////                      ),
//////                    ],
//////                  ),
//////                ),
//////              ),
//////            ),
////          ],
////        ),
////      ],
////    );
////  }
//
////  Widget _middleWidget() {
////    return new Positioned(
////      bottom: 48.0,
////      child: new Container(
////        width: MediaQuery.of(context).size.width,
////        height: 45,
////        color: Colors.orange[500],
////        margin: const EdgeInsets.all(0.0),
////        child: new Column(
////          mainAxisAlignment: MainAxisAlignment.center,
////          children: <Widget>[
////            new Align(
////              alignment: Alignment.bottomCenter,
////              child: Padding(
////                padding: const EdgeInsets.all(12.0),
////                child: Row(
////                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
////                  children: <Widget>[
////                    Text(
////                      "Balance :",
////                      textAlign: TextAlign.left,
////                      style: TextStyle(
////                          fontWeight: FontWeight.bold, color: Colors.white),
////                    ),
////                    Text(
////                      totalAmount(_transactionList).toString(),
////                      textAlign: TextAlign.left,
////                      style: TextStyle(
////                          fontWeight: FontWeight.bold, color: Colors.white),
////                    )
////                  ],
////                ),
////              ),
////            ),
////          ],
////        ),
////      ),
////    );
////  }
//
//  Widget _bottomWidget() {
//    return new Positioned(
//      bottom: 0.0,
//      child: new Container(
//        width: MediaQuery.of(context).size.width,
//        padding: EdgeInsets.only(right: 50.0, left: 50.0),
//        child: new Column(
//          mainAxisAlignment: MainAxisAlignment.center,
//          children: <Widget>[
//            new Align(
//                alignment: Alignment.bottomCenter,
//                child: Row(
//                  mainAxisAlignment: MainAxisAlignment.center,
//                  mainAxisSize: MainAxisSize.max,
//                  children: <Widget>[
//                    Expanded(
//                      child: Container(
//                        child: Padding(
//                          padding: const EdgeInsets.all(8.0),
//                          child: SizedBox(
//                            height: 55,
//                            child: RawMaterialButton(
////                            height: double.infinity,
////                            color: Colors.red[500],
//                              child: Text(
//                                "-",
//                                style: TextStyle(color: Colors.white),
//                              ),
//                              shape: CircleBorder(),
//                              elevation: 8.0,
//                              fillColor: Colors.purple[800],
//                              padding: const EdgeInsets.all(15.0),
//                              onPressed: () async {
//                                var returnValue = await showDialog(
//                                    context: context,
//                                    builder: (BuildContext context) {
//                                      return Container(
//                                          decoration: BoxDecoration(
//                                              borderRadius: BorderRadius.all(
//                                                  Radius.circular(10.0))),
//                                          child: AddTransactionDialog(
//                                              "Debit"));
//                                    });
//
//                                if (returnValue is TransactionModel) {
//                                  returnValue.amount = returnValue.amount * -1;
//                                  setState(() {
//                                    changeColor = !changeColor;
//                                    _transactionList.add(returnValue);
//                                  });
//                                }
//                              },
//                              // padding: EdgeInsets.all(0),
//                            ),
//                          ),
//                        ),
//                      ),
//                    ),
//                    Expanded(
//                      child: SizedBox(
//                        height: 55,
//                        child: RawMaterialButton(
////                            height: double.infinity,
////                            color: Colors.green[500],.
//                            child: Text(
//                              "+",
//                              style: TextStyle(
//                                  color: Colors.white, fontSize: 18.0),
//                            ),
//                            shape: new CircleBorder(),
//                            elevation: 2.0,
//                            fillColor: Colors.purple[800],
//                            padding: const EdgeInsets.all(15.0),
//                            onPressed: () async {
//                              var returnValue = await showDialog(
//                                  context: context,
//                                  builder: (BuildContext context) {
//                                    return Container(
//                                        decoration: BoxDecoration(
//                                            borderRadius: BorderRadius.all(
//                                                Radius.circular(10.0))),
//                                        child: AddTransactionDialog(
//                                            "Credit"));
//                                  });
//                              if (returnValue is TransactionModel) {
//                                setState(() {
//                                  changeColor = !changeColor;
//                                  _transactionList.add(returnValue);
//                                });
//                              }
//                            }),
//                      ),
//                    ),
//                  ],
//                )),
//          ],
//        ),
//      ),
//    );
//  }
//
////  @override
////  Widget build(BuildContext context) {
////    transactionList = Provider.of<TransactionList>(context);
////    return Scaffold(
////      body: Container(
////        child: Stack(
////          children: <Widget>[
////            _balanceWidgets(),
////            _topWidget(),
////            // _middleWidget(),
////            _bottomWidget(),
////          ],
////        ),
////      ),
////    );
////  }
////}
//
//double totalAmount(List<TransactionModel> transList) {
//  double amount = 0.0;
//
//  for (var model in transList) {
//    amount += model.amount;
//  }
//  return amount;
//}
//
////// use the list builder
////Container(
////child: ListView.builder(itemBuilder: (BuildContext context ,int index){
////return _listItem("");
////},itemCount: 5,),
////),
