import 'package:expansion_manager/models/transaction_change_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SearchDialog extends StatefulWidget {
  @override
  _SearchDialogState createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  TransactionChangeNotifier _transactionChangeNotifier;
  TextEditingController _transactionNameController =
      new TextEditingController();

  Widget _itemNameWidget() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new TextField(
                    controller: _transactionNameController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      fillColor: Colors.blue[900],
                      suffixIcon: Image.asset(
                          'lib/images/photo.png'),
                      hintText: 'Enter title',
                      hintStyle: TextStyle(
                          fontSize: 20, color: Color(0xff4D84BB)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          width: 0,
                          style: BorderStyle.none,
                        ),
                      ),
                      filled: true,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _filterButton() {
    return Column(
      children: <Widget>[
        ButtonTheme(
          minWidth: 500.0,
          child: RaisedButton(
              color: Color(0xff12E294),
              disabledColor: Colors.greenAccent,
              child: Text(
                "Search",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () {
                _searchData();
                Navigator.pop(context, true);
              },
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(8))),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _transactionChangeNotifier =
        Provider.of<TransactionChangeNotifier>(context);
    return AlertDialog(
        backgroundColor: Color(0xff0576E7),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0))),
        content: Container(
            padding: const EdgeInsets.all(8),
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(9.0),
                    child: Center(
                      child: Text(
                        "Search",
                        style: TextStyle(fontSize: 18.0, color: Colors.white),
                      ),
                    ),
                  ),
                  InkWell(
                    child: Icon(
                      Icons.cancel,
                      color: Colors.white,
                    ),
                    onTap: () {
                      setState(() {
                        Navigator.pop(context, -1);
                      });
                    },
                  )
                ],
              ),
              _itemNameWidget(),
              _filterButton(),
            ])
        )
    );
  }

  Future<void> _searchData() async {
    String d = (_transactionNameController.text);
    await _transactionChangeNotifier.searchList(itemName: d.toString());
  }

}
