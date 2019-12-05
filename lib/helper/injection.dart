import 'dart:async';
import 'package:expansion_manager/helper/database_helper.dart';
import 'package:expansion_manager/helper/preferences_interface.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';

class Injection {
  static PreferencesInterface _preferencesInterface = PreferencesInterface();
  static DatabaseHelper _databaseHelper = DatabaseHelper();

  static Injector injector;

  static Future initInjection() async {
    await _preferencesInterface.initPreferences();
    await _databaseHelper.initDb();

    injector = Injector.getInjector();

    injector.map<PreferencesInterface>((i) => _preferencesInterface,
        isSingleton: true);
    injector.map<DatabaseHelper>((i) => _databaseHelper,
        isSingleton: true);
  }
}
