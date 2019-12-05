import 'package:expansion_manager/helper/injection.dart';
import 'package:expansion_manager/models/category_change_notifier.dart';
import 'package:expansion_manager/models/change_button_visibility.dart';
import 'package:expansion_manager/screens/AddTransactionScreen.dart';
import 'package:expansion_manager/screens/CategoryScreen.dart';
import 'package:expansion_manager/screens/DashboardScreen.dart';
import 'package:expansion_manager/screens/EditTransactionScreen.dart';
import 'package:expansion_manager/screens/GraphScreen.dart';
import 'package:expansion_manager/screens/GraphsScreen.dart';
import 'package:expansion_manager/screens/GraphsScreens.dart';
import 'package:expansion_manager/screens/HomePage.dart';
import 'package:expansion_manager/screens/SettingScreen.dart';
import 'package:expansion_manager/screens/SubstractTransactionScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'models/transaction_change_notifier.dart';
import 'models/transaction_model.dart';
import 'screens/CategoryTransactionListScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Injection.initInjection();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(
            builder: (context) => TransactionChangeNotifier()),
        ChangeNotifierProvider(builder: (context) => CategoryChangeNotifier()),
        ChangeNotifierProvider(builder: (context) => ChangeButtonVisibility()),

      ],
      child: MaterialApp(
        home: HomePage(),
        routes: {
          '/dashboard': (context) => DashboardScreen(),
          '/categoryboard': (context) => CategoryScreen(),
          '/transactionlistboard': (context) => CategoryTransactionListScreen(),
          '/graphscreen': (context) => GraphScreens(),
          '/settingscreen': (context) => SettingScreens(),
          'add-credit-transaction': (context) =>
              AddTransactionScreen(TransactionModel.TYPE_CREDIT),
          'add-debit-transaction': (context) =>
              SubtractTransactionScreen(TransactionModel.TYPE_DEBIT),


        },
      ),
    ));
  });
}

