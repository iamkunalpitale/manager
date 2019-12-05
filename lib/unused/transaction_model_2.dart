import 'dart:collection';
import 'package:flutter/foundation.dart';

class TransactionModel2 extends ChangeNotifier {
  int id;
  String date;
  String type;
  double amount;

  final List<TransactionModel2> _list = [];

  UnmodifiableListView<TransactionModel2> get items =>
      UnmodifiableListView(_list);

  void add(TransactionModel2 item) {
    _list.add(item);
    notifyListeners();
  }
}
