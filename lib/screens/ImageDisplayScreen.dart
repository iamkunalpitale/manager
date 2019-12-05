import 'dart:convert';

import 'package:expansion_manager/models/transaction_model.dart';
import 'package:flutter/material.dart';

class ImageDisplayScreen extends StatefulWidget {
  @override
  _ImageDisplayScreenState createState() => _ImageDisplayScreenState();
}

class _ImageDisplayScreenState extends State<ImageDisplayScreen> {

  @override
  Widget build(BuildContext context) {
    TransactionModel model = ModalRoute.of(context).settings.arguments;
    var convert = Base64Decoder().convert(model.image);
    return Scaffold(
      appBar: AppBar(
        title:  new Text("Image Picker"),
      ),
      body: Container(

        child: Image.memory(convert)

      ),
    );
  }
}
