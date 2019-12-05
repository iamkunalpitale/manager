import 'dart:async';
import 'dart:io' as io;

import 'package:expansion_manager/models/transaction_model.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:streamqflite/streamqflite.dart';

class DatabaseHelperOld {
  static final DatabaseHelperOld _instance = new DatabaseHelperOld.internal();

  factory DatabaseHelperOld() => _instance;
  static Database _db;
  static StreamDatabase _streamDatabase;

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  Database get db2 {
    return _db;
  }

  StreamDatabase get streamDb {
    return _streamDatabase;
  }

  DatabaseHelperOld.internal();

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "main.db");
    _db = await openDatabase(path, version: 2, onCreate: _onCreate);
    _streamDatabase = StreamDatabase(_db);
    return _db;
  }

  void _onCreate(Database db, int version) async {
    // When creating the db, create the table
    await db.execute(
        'CREATE TABLE transactions(id INTEGER PRIMARY KEY AUTOINCREMENT ,type TEXT,date TEXT, amount double)');
  }

  Future<int> saveTransaction(TransactionModel transactionModel) async {
    await db;
    int res = await streamDb.insert(
        "transactions", transactionModel.toMapWithoutId());
    return res;
  }

  Future<List<TransactionModel>> getTransactions() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery("SELECT * FROM transactions");
    List<TransactionModel> modelList = new List();
    list.forEach((item) {
      TransactionModel tempModel = TransactionModel.fromJson(item);
      modelList.add(tempModel);
    });
    return modelList;
  }

  Stream<List<TransactionModel>> getTransactionsStream() {
    return streamDb.createQuery(
      "transactions",
      columns: ["id", "date", "type", "amount"],
    ).mapToList((map) {
      print(map.toString());
      return TransactionModel.fromJson(map);
    }
    );
  }

  Future<int> deleteTransaction(TransactionModel transactionModel) async {
    var dbClient = await db;

    int res = await dbClient.rawDelete(
        'DELETE FROM transactions WHERE id = ?', [transactionModel.id]);
    return res;
  }

  updateTransaction(TransactionModel transactionModel) async {
    final dbClient = await db;
    var res = await dbClient.update("transactions", transactionModel.toJson(),
        where: "id = ?", whereArgs: [transactionModel.id]);
    return res;
  }
}
