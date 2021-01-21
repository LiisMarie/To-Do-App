import 'dart:async';

import 'package:flutter/material.dart';

class Model with ChangeNotifier {
  String _token = "";
  Timer _timer;
  ThemeData _themeData = ThemeData.dark();

  String get token => _token;

  Timer get timer => _timer;

  getTheme() => _themeData;

  void updateToken(String newToken) {
    _token = newToken;
    notifyListeners();
  }

  void resetToken() {
    _token = "";
    notifyListeners();
  }

  void setTimer(Timer newTimer) {
    _timer = newTimer;
  }

  void cancelTimer() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
  }

  setTheme(ThemeData theme) {
    _themeData = theme;

    notifyListeners();
  }
}
