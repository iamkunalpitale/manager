import 'package:flutter/foundation.dart';

class ChangeButtonVisibility extends ChangeNotifier {

  bool _visible = true;

  bool get visible => _visible;

  set visible(bool value) {
    _visible = value;
  }
}
