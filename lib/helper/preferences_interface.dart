import 'package:shared_preferences/shared_preferences.dart';

class PreferencesInterface {
  SharedPreferences _prefs;
  static final String keyCurrency = "currency";

  Future initPreferences() async {
    _prefs = await SharedPreferences.getInstance();

  }

  Future saveCurrency(String value) async {
    await _prefs.setString(keyCurrency, value);
  }

  String getCurrency() {
    return _prefs.getString(keyCurrency) ?? 'INR';
  }
}