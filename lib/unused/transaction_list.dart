import 'dart:math';
import 'package:expansion_manager/unused/transaction_model_2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransactionList2 extends StatefulWidget {
  TransactionList2({Key key}) : super(key: key);

  @override
  _TransactionList2State createState() {
    return _TransactionList2State();
  }
}

class _TransactionList2State extends State<TransactionList2> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<TransactionModel2>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Hello"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              final tempModel = new TransactionModel2();
              tempModel.amount = Random.secure().nextDouble();
              model.add(tempModel);
            },
          )
        ],
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return InkWell(
            child: ListTile(
              title: Text(model.items[index].amount.toString()),
            ),
            onTap: () {
              Navigator.pushNamed(context, "/dashboard");
            },
          );
        },
        itemCount: model.items.length,
      ),
    );
  }
}
