import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CategoryModel extends ChangeNotifier {
  int id;
  String name;
  String color;
  int favourite;

  CategoryModel({this.id, this.name, this.color, this.favourite});

  CategoryModel.map(dynamic obj) {
    this.name = obj["name"];
    this.color = obj["color"];
    this.favourite = obj["favourite"];
  }

  factory CategoryModel.fromJson(Map<String, dynamic> data) =>
      new CategoryModel(
        id: data["id"],
        name: data["name"],
        color: data["color"],
        favourite: data["favourite"],
      );

  Map<String, dynamic> toJson() =>
      {
        "id": id,
        "name": name,
        "color": color,
        "favourite": favourite,
      };

  Map<String, dynamic> toMapWithoutId() =>
      {
        "name": name,
        "color": color,
        "favourite": favourite,
      };

  void setTransId(int id) {
    this.id = id;
  }
}
