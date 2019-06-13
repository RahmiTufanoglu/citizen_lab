import 'package:flutter/material.dart';

class ThemeChangerProvider with ChangeNotifier {
  ThemeData _themeData;

  ThemeChangerProvider(this._themeData);

  void setTheme(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  ThemeData get getTheme => _themeData;
}
