import 'package:flutter/foundation.dart';

class TransactionModel extends ChangeNotifier {
  static const TYPE_CREDIT = "Credit";
  static const TYPE_DEBIT = "Debit";

  int id;
  int categoryId;
  String date;
  String type;
  double amount;
  String image;
  String itemName;
  String categoryName;
  String startDate;
  String endDate;
  String currencySymbol;
  String categoryColor;

  TransactionModel({this.id,
    this.categoryId,
    this.amount,
    this.date,
    this.type,
    this.image,
    this.itemName,
    this.categoryName,
    this.startDate,
    this.endDate,
    this.currencySymbol,
    this.categoryColor});

  TransactionModel.map(dynamic obj) {
    this.id = obj["id"];
    this.categoryId = obj["category_id"];
    this.date = obj["date"];
    this.type = obj["type"];
    this.amount = obj["amount"];
    this.image = obj["image"];
    this.itemName = obj["itemName"];
    this.categoryName = obj["category_name"];
    this.startDate = obj["start_date"];
    this.endDate = obj["end_date"];
    this.currencySymbol = obj["currency_symbol"];

  }

  factory TransactionModel.fromJson(Map<String, dynamic> data) =>
      new TransactionModel(
          id: data["id"],
          categoryId: data["category_id"],
          date: data["date"],
          type: data["type"],
          amount: data["amount"],
          image: data["image"],
          itemName: data["itemName"],
          categoryName: data["category_name"],
          startDate: data["start_date"],
          endDate: data["end_date"],
          currencySymbol: data["currency_symbol"],
          categoryColor: data["category_color"]);

  Map<String, dynamic> toJson() =>
      {
        "id": id,
        "category_id": categoryId,
        "date": date,
        "amount": amount,
        "type": type,
        "image": image,
        "itemName": itemName,
        "category_name": categoryName,
        "start_date": startDate,
        "end_date": endDate,
        "currency_symbol": currencySymbol,
        "category_color": categoryColor
      };

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["category_id"] = categoryId;
    map["date"] = date;
    map["type"] = type;
    map["amount"] = amount;
    map["image"] = image;
    map["itemName"] = itemName;
    map["category_name"] = categoryName;
    map["start_date"] = startDate;
    map["end_date"] = endDate;
    map["currency_symbol"] = currencySymbol;
    map["category_color"] = categoryColor;

    return map;
  }

  Map<String, dynamic> toMapWithoutId() =>
      {
        "date": date,
        "type": type,
        "amount": amount,
        "image": image,
        "itemName": itemName,
        "category_id": categoryId,
        "category_name": categoryName,
        "start_date": startDate,
        "end_date": endDate,
        "currency_symbol": currencySymbol,
        "category_color": categoryColor
      };

  void setTransId(int id) {
    this.id = id;
  }
}
