import 'dart:io' as io;

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;
  static Database _db;

  DatabaseHelper.internal();

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "main.db");
    _db = await openDatabase(path, version: 2, onCreate: _onCreate);
  }

  Database get db {
    return _db;
  }

  void _onCreate(Database db, int version) async {
    // When creating the db, create the table
    await db.execute(
        'CREATE TABLE transactions(id INTEGER PRIMARY KEY AUTOINCREMENT'
            ', type TEXT, '
            'date TEXT, '
            'amount double, '
            'image TEXT, '
            'itemName TEXT, '
            'category_name TEXT, '
            'start_date TEXT, '
            'end_date TEXT, '
            'currency_symbol TEXT, '
            'category_id INTEGER, category_color TEXT)');
    await db.execute(
        'CREATE TABLE categories(id INTEGER PRIMARY KEY AUTOINCREMENT,'
            ' name TEXT, color TEXT, favourite INTEGER)');
  }
}
