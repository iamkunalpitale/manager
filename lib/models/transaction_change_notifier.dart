import 'dart:collection';

import 'package:date_format/date_format.dart';
import 'package:expansion_manager/helper/database_helper.dart';
import 'package:expansion_manager/helper/injection.dart';
import 'package:expansion_manager/models/category_model.dart';
import 'package:expansion_manager/models/transaction_model.dart';
import 'package:flutter/foundation.dart';

class TransactionChangeNotifier extends ChangeNotifier {
  final DatabaseHelper _db = Injection.injector.get<DatabaseHelper>();

  TransactionChangeNotifier() {
    init();
  }

  final List<TransactionModel> _list = [];
  final List<TransactionModel> _filteredList = [];
  final List<Map<String, dynamic>> _graphData = [];
  final List<Map<String, dynamic>> _balanceData = [];
  final List<Map<String, dynamic>> _listFilterData = [];
  final List<Map<String, dynamic>> _sevenDaysGraphData = [];
  final List<Map<String, dynamic>> _fifteenDaysGraphData = [];
  final List<Map<String, dynamic>> _thirtyDaysGraphData = [];

  UnmodifiableListView<TransactionModel> get items =>
      UnmodifiableListView(_list);

  UnmodifiableListView<TransactionModel> get filteredItems =>
      UnmodifiableListView(_filteredList);

  UnmodifiableListView<Map<String, dynamic>> get graphData =>
      UnmodifiableListView(_graphData);

  UnmodifiableListView<Map<String, dynamic>> get listData =>
      UnmodifiableListView(_listFilterData);

  UnmodifiableListView<Map<String, dynamic>> get totalBalanceData =>
      UnmodifiableListView(_balanceData);

  UnmodifiableListView<Map<String, dynamic>> get sevenDaysGraphData =>
      UnmodifiableListView(_sevenDaysGraphData);

  UnmodifiableListView<Map<String, dynamic>> get fifteenDaysGraphData =>
      UnmodifiableListView(_fifteenDaysGraphData);

  UnmodifiableListView<Map<String, dynamic>> get thirtyDaysGraphData =>
      UnmodifiableListView(_thirtyDaysGraphData);

  Future<int> add(TransactionModel txnModel) async {
    try {
      int id = await _db.db.insert("transactions", txnModel.toMap());
      txnModel.id = id;
      _list.add(txnModel);
      await populateSevenDaysGraphData();
      await populateFifteenDaysGraphData();
      await populateThirtyDaysGraphData();

      await getBalance();
      notifyListeners();
      return id;
    } catch (e) {
      print(e.toString());
      return -1;
    }
  }

  Future<int> delete(TransactionModel txnModel) async {
    int id = await _db.db
        .rawDelete('DELETE FROM transactions WHERE id = ?', [txnModel.id]);
    _list.removeWhere((txn) => txnModel.id == txn.id);

    await populateSevenDaysGraphData();
    await populateFifteenDaysGraphData();
    await populateThirtyDaysGraphData();

    await getBalance();
    notifyListeners();
    return id;
  }

  Future<int> update(TransactionModel txnModel) async {
    var res = await _db.db.update("transactions", txnModel.toJson(),
        where: "id = ?", whereArgs: [txnModel.id]);
    await populateSevenDaysGraphData();
    await populateFifteenDaysGraphData();
    await populateThirtyDaysGraphData();

    await getBalance();
    notifyListeners();
    return res;
  }


  Future<TransactionModel> getTransactionById(int id) async {
    List<Map> list =
        await _db.db.rawQuery("SELECT * FROM transactions where id = ?", [id]);
    return TransactionModel.fromJson(list[0]);
  }

  Future<List<TransactionModel>> getTransactions(String categoryName) async {
    List<Map> list = await _db.db.rawQuery(
        "SELECT transactions.*, categories.color as category_color "
            "FROM transactions join categories on categories.id = transactions.category_id");
    List<TransactionModel> modelList = new List();
    list.forEach((item) {
      TransactionModel tempModel = TransactionModel.fromJson(item);
      modelList.add(tempModel);
      notifyListeners();
    });
    return modelList;
  }

  Future<int> saveTransaction(TransactionModel transactionModel) async {
    int res = await _db.db.insert("transactions", transactionModel.toMap());
    _list.add(transactionModel);
    notifyListeners();
  }

  void init() async {
    //_list.clear();
    List<Map<String, dynamic>> list = await _db.db.rawQuery(
        "SELECT * FROM transactions");
    list.forEach((item) {
      TransactionModel tempModel = TransactionModel.fromJson(item);
      _list.add(tempModel);
    });


    //Populate 7 days graph data
    DateTime pastDays = DateTime.now().subtract(Duration(days: 7));
    DateTime currentDay = DateTime.now();
    List<Map<String, dynamic>> list7 = await graphFilter(
        TransactionModel.TYPE_DEBIT,
        formatDate(
            DateTime.parse(pastDays.toString()), [yyyy, '-', mm, '-', dd]),
        formatDate(
            DateTime.parse(currentDay.toString()), [yyyy, '-', mm, '-', dd]));
    _sevenDaysGraphData.addAll(list7);
    print(_sevenDaysGraphData);

    //Populate 15 days graph data
    DateTime pastDay = DateTime.now().subtract(Duration(days: 15));
    DateTime currentDays = DateTime.now();
    List<Map<String, dynamic>> list15 = await graphFilter(
        TransactionModel.TYPE_DEBIT,
        formatDate(
            DateTime.parse(pastDay.toString()), [yyyy, '-', mm, '-', dd]),
        formatDate(
            DateTime.parse(currentDays.toString()), [yyyy, '-', mm, '-', dd]));
    _fifteenDaysGraphData.addAll(list15);
    print(_fifteenDaysGraphData);


    //Populate 30 days graph data
    DateTime pastMonth = DateTime.now().subtract(Duration(days: 30));
    DateTime currentDayss = DateTime.now();
    List<Map<String, dynamic>> list30 = await graphFilter(
        TransactionModel.TYPE_DEBIT,
        formatDate(
            DateTime.parse(pastMonth.toString()), [yyyy, '-', mm, '-', dd]),
        formatDate(
            DateTime.parse(currentDayss.toString()), [yyyy, '-', mm, '-', dd]));
    _thirtyDaysGraphData.addAll(list30);
    print(_thirtyDaysGraphData);
    await populateSevenDaysGraphData();
    await populateFifteenDaysGraphData();
    await populateThirtyDaysGraphData();

    await getBalance();
    notifyListeners();
  }

  // method of 7 Days Graph Data

  populateSevenDaysGraphData() async {
    DateTime pastDays = DateTime.now().subtract(Duration(days: 7));
    DateTime currentDay = DateTime.now();
    List<Map<String, dynamic>> list7 = await graphFilter(
        TransactionModel.TYPE_DEBIT,
        formatDate(
            DateTime.parse(pastDays.toString()), [yyyy, '-', mm, '-', dd]),
        formatDate(
            DateTime.parse(currentDay.toString()), [yyyy, '-', mm, '-', dd]));
    _sevenDaysGraphData.addAll(list7);
    print(_sevenDaysGraphData);
  }

  // method of 15 Days Graph Data

  populateFifteenDaysGraphData() async {
    DateTime pastDay = DateTime.now().subtract(Duration(days: 15));
    DateTime currentDays = DateTime.now();
    List<Map<String, dynamic>> list15 = await graphFilter(
        TransactionModel.TYPE_DEBIT,
        formatDate(
            DateTime.parse(pastDay.toString()), [yyyy, '-', mm, '-', dd]),
        formatDate(
            DateTime.parse(currentDays.toString()), [yyyy, '-', mm, '-', dd]));
    _fifteenDaysGraphData.addAll(list15);
    print(_fifteenDaysGraphData);
  }

  // method of 30 Days Graph Data

  populateThirtyDaysGraphData() async {
    DateTime pastMonth = DateTime.now().subtract(Duration(days: 30));
    DateTime currentDayss = DateTime.now();
    List<Map<String, dynamic>> list30 = await graphFilter(
        TransactionModel.TYPE_DEBIT,
        formatDate(
            DateTime.parse(pastMonth.toString()), [yyyy, '-', mm, '-', dd]),
        formatDate(
            DateTime.parse(currentDayss.toString()), [yyyy, '-', mm, '-', dd]));
    _thirtyDaysGraphData.addAll(list30);
    print(_thirtyDaysGraphData);
  }


    Future<void> filterList(CategoryModel categoryModel) async{
    _filteredList.clear();
    String sql = "SELECT * FROM transactions WHERE category_id = ?";
    List<Map> list = await _db.db.rawQuery(sql, [categoryModel.id]);
    list.forEach((item) {
      TransactionModel tempModel = TransactionModel.fromJson(item);
      _filteredList.add(tempModel);
    });

    notifyListeners();
  }

  // for showing the graph
  Future<List> graphFilter(String type, String startDate,
      String endDate) async {
    _graphData.clear();
    try {
      String sql = "SELECT SUM(amount) as amount, category_name FROM transactions where date(date)>=date(?) and date(date)<=date(?) and type = ? group by category_name";
      List<Map<String, dynamic>> list = await _db.db.rawQuery(
          sql, [startDate, endDate, type]);
      _graphData.addAll(list);
      print(list.toString());
      notifyListeners();
      return _graphData;
    } catch (e) {
      print(e.toString());
    }
    return [];
  }

  void clearGraphData() {
    _graphData.clear();
    notifyListeners();
  }


  // for get the balance
  Future<void> getBalance() async {
    _balanceData.clear();
    try {
      String sql = "SELECT SUM(amount) as amount, currency_symbol FROM transactions group by currency_symbol having sum(amount) <> 0";
      List<Map<String, dynamic>> list = await _db.db.rawQuery(
          sql);
      _balanceData.addAll(list);
      print(list.toString());
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }


//  Future<List> getTotalBalance(String type) async {
//    try {
//      String sql = "SELECT SUM(amount) as amount, currency_symbol FROM transactions group by currency_symbol having sum(amount) > 0";
//      List<Map<String, dynamic>> list = await _db.db.rawQuery(
//          sql);
//      _graphData.addAll(list);
//      print(list.toString());
//      notifyListeners();
//      return _graphData;
//    } catch (e) {
//      print(e.toString());
//    }
//    return [];
//  }



  // for showing the list filter
  Future<void> listFilter(String type,
      {String categoryName, String amount, String startDate,
        String endDate}) async {
    _list.clear();
    try {
      String sql = "SELECT * from transactions where ";
      List args = [];
      if (categoryName != null) {
        sql += "category_name = ?";
        args.add(categoryName);
      }

      if (amount != null) {
        sql += " and amount > ?";
        args.add(amount);
      }

//      if (amount != null) {
//        sql += " and amount < ?";
//        args.add(amount);
//      }

      if (startDate != null) {
        sql += " and date(date)>=date(?)";
        args.add(startDate);
      }

      if (endDate != null) {
        sql += " and date(date)<=date(?)";
        args.add(endDate);
      }
      print(sql);
      // return [];
      List<Map<String, dynamic>> list = await _db.db.rawQuery(
          sql, args);
      list.forEach((item) {
        TransactionModel tempModel = TransactionModel.fromJson(item);
        _list.add(tempModel);
      });
      print(list.toString());
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
    return [];
  }

  void clearListData() {
    _listFilterData.clear();
    notifyListeners();
  }


  // Search the list items
  Future<void> searchList({String itemName}) async {
    _list.clear();
    try {
      String sql = "SELECT * from transactions where itemName like '%$itemName%' order by date(date) desc";
      List args = [];
      List<Map<String, dynamic>> list = await _db.db.rawQuery(
          sql, args);
      list.forEach((item) {
        TransactionModel tempModel = TransactionModel.fromJson(item);
        _list.add(tempModel);
      });
      print(list.toString());
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
    return [];
  }

}
//select * from transactions where title like ? order by date(date) desc

//['%'.variable.'%']