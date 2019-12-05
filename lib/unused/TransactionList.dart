import 'dart:async';

import 'package:expansion_manager/unused/data_helper.dart';
import 'package:expansion_manager/models/transaction_model.dart';

abstract class TransactionList {
  void screenUpdate();
}

class TransactionPresenter {
  TransactionList _view;
  var db = new DatabaseHelperOld();

  TransactionPresenter(this._view);

  delete(TransactionModel trans) {
    var db = new DatabaseHelperOld();
    db.deleteTransaction(trans);
    updateScreen();
  }

  Future<List<TransactionModel>> getTransactions() {
    return db.getTransactions();
  }

  updateScreen() {
    _view.screenUpdate();
  }
}
