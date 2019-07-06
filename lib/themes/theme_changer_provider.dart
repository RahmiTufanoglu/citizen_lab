import 'package:citizen_lab/themes/theme.dart';
import 'package:flutter/material.dart';

class ThemeChangerProvider with ChangeNotifier {
  ThemeData _themeData;
  bool _darkModeEnabled = false;

  ThemeChangerProvider(this._themeData);

  ThemeData get getTheme => _themeData;

  bool get getDarkModeStatus => _darkModeEnabled;

  void setTheme() {
    _darkModeEnabled
        ? _themeData = appLightTheme()
        : _themeData = appDarkTheme();

    _darkModeEnabled = !_darkModeEnabled;
    notifyListeners();
  }
}
