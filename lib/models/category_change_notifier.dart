import 'dart:collection';

import 'package:expansion_manager/helper/database_helper.dart';
import 'package:expansion_manager/helper/injection.dart';
import 'package:expansion_manager/models/category_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CategoryChangeNotifier extends ChangeNotifier {
  final DatabaseHelper _dbctg = Injection.injector.get<DatabaseHelper>();

  CategoryChangeNotifier() {
    init();
  }

  final List<CategoryModel> _categorylist = [];

  UnmodifiableListView<CategoryModel> get items =>
      UnmodifiableListView(_categorylist);

  Future<int> add(CategoryModel ctgModel) async {
    int id = -1;
    try {
      id = await _dbctg.db.insert("categories", ctgModel.toMapWithoutId());
      ctgModel.id = id;
      _categorylist.add(ctgModel);
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }

    notifyListeners();
    return id;
  }

  Future<int> delete(CategoryModel ctgModel) async {
    int id = await _dbctg.db
        .rawDelete('DELETE FROM categories WHERE id = ?', [ctgModel.id]);
    _categorylist.removeWhere((ctgtxn) => ctgModel.id == ctgtxn.id);
    notifyListeners();
    return id;
  }

  Future<int> update(CategoryModel ctgModel) async {
    var res = await _dbctg.db.update("categories", ctgModel.toJson(),
        where: "id = ?", whereArgs: [ctgModel.id]);
    notifyListeners();
    return res;
  }

  Future<List<CategoryModel>> getCategories() async {
    List<Map> list = await _dbctg.db.rawQuery("SELECT * FROM categories");
    List<CategoryModel> modelList = new List();
    list.forEach((item) {
      CategoryModel catgModel = CategoryModel.fromJson(item);
      modelList.add(catgModel);
      notifyListeners();
    });
    return modelList;
  }

  void init() async {
    _categorylist.clear();
    List<Map> list = await _dbctg.db
        .rawQuery("SELECT * FROM categories ORDER BY favourite DESC");
    list.forEach((item) {
      CategoryModel catgModel = CategoryModel.fromJson(item);
      _categorylist.add(catgModel);
    });

    notifyListeners();
  }
}
