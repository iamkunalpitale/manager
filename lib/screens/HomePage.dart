import 'package:expansion_manager/dialog/fab_bottom_app_bar.dart';
import 'package:expansion_manager/models/change_button_visibility.dart';
import 'package:expansion_manager/models/transaction_change_notifier.dart';
import 'package:expansion_manager/models/transaction_model.dart';
import 'package:expansion_manager/screens/DashboardScreen.dart';
import 'package:expansion_manager/screens/GraphScreen.dart';
import 'package:expansion_manager/screens/GraphsScreen.dart';
import 'package:expansion_manager/screens/GraphsScreens.dart';
import 'package:expansion_manager/screens/SettingScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'AnchoredOverlay.dart';
import 'CategoryScreen.dart';
import 'fab_with_icons.dart';

class DrawerItem {
  String _title;
  IconData _icon;

  DrawerItem(this._title, this._icon);
}

class HomePage extends StatefulWidget {
  final drawerItem = [
    new DrawerItem("Home", Icons.home),
    new DrawerItem("Categories", Icons.grid_on),
    new DrawerItem("Graph & Analysis", Icons.show_chart),
    new DrawerItem("Settings", Icons.settings),
  ];

  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  int _selectDrawerIndex = 0;
  bool _fabVisible = true;
  var returnValue;
  TransactionChangeNotifier _transactionChangeNotifier;

//  bool isMyDayNumberVisible = !(context == DashboardScreen());

  final _fragments = [
    DashboardScreen(),
    CategoryScreen(),
    GraphScreens(),
    SettingScreens(),
  ];

  _onSelectedItem(int index) {
    setState(() => _selectDrawerIndex = index);
    Navigator.of(context).pop(); //close drawer
  }

  @override
  Widget build(BuildContext context) {
    final buttonVisibilityNotifier = Provider.of<ChangeButtonVisibility>(
        context);
    var drawerOptions = <Widget>[];
    for (var i = 0; i < widget.drawerItem.length; i++) {
      var d = widget.drawerItem[i];
      drawerOptions.add(new ListTile(
        leading: new Icon(d._icon),
        title: new Text(d._title),
        selected: i == _selectDrawerIndex,
        onTap: () => _onSelectedItem(i),
      ));
    }
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        resizeToAvoidBottomInset: false,
        extendBody: true,
        bottomNavigationBar: FABBottomAppBar(
          color: Colors.grey,
          selectedColor: Colors.red,
          notchedShape: CircularNotchedRectangle(),
          onTabSelected: _selectedTab,
          items: [
            FABBottomAppBarItem(iconData: Icons.home, text: 'Home'),
            FABBottomAppBarItem(iconData: Icons.layers, text: 'Category'),
            FABBottomAppBarItem(iconData: Icons.dashboard, text: 'Graphs'),
            FABBottomAppBarItem(iconData: Icons.settings, text: 'Settings'),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton:
        Visibility(visible: buttonVisibilityNotifier.visible,
            child: _buildFab(context)),
        body: IndexedStack(
          children: _fragments,
          index: _selectDrawerIndex,
        ));
  }

  void _selectedTab(int index) {
    setState(() {
      _selectDrawerIndex = index;
    });
  }

  Widget _buildFab(BuildContext context) {
    final icons = [Icons.add, Icons.remove];
    return AnchoredOverlay(
      showOverlay: _fabVisible,
      overlayBuilder: (context, offset) {
        return CenterAbout(
          position: Offset(offset.dx, offset.dy - icons.length * 35.0),
          child: FabWithIcons(
            icons: icons,
            onIconTapped: _selectedFab,
          ),
        );
      },
      child: FloatingActionButton(
        heroTag: '',
        tooltip: 'Increment',
      ),
    );
  }

  // use the debit and credit function in this _selectedFab method
  void _selectedFab(int index) async {
    final buttonVisibilityNotifier = Provider.of<ChangeButtonVisibility>(
        context);
    buttonVisibilityNotifier.visible = false;
    if (index == 0) {
      Navigator.pushNamed(context, "add-credit-transaction").then((v) {
        buttonVisibilityNotifier.visible = true;
      });
    }
    if (index == 1) {
      Navigator.pushNamed(context, "add-debit-transaction").then((v) {
        buttonVisibilityNotifier.visible = true;
      });
    }
  }

  double totalAmount(List<TransactionModel> transList) {
    double amount = 0.0;
    for (var model in transList) {
      amount += model.amount;
    }
    return amount;
  }
}
