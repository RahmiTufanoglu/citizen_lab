import 'package:citizen_lab/themes/theme.dart';
import 'package:flutter/material.dart';

class ThemeChangerProvider with ChangeNotifier {
  ThemeData _themeData;
  bool _darkModeEnabled;

  ThemeChangerProvider(this._themeData);

  void setTheme() {
    if (_darkModeEnabled) {
      _themeData = appLightTheme();
    } else {
      _themeData = appDarkTheme();
    }
    notifyListeners();
  }

  void checkIfDarkModeEnabled(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    if (theme.brightness == appDarkTheme().brightness) {
      _darkModeEnabled = true;
    } else {
      _darkModeEnabled = false;
    }
  }

  ThemeData get getTheme => _themeData;

  bool get getDarkModeStatus => _darkModeEnabled;
}
