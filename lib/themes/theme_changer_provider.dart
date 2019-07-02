import 'package:citizen_lab/themes/theme.dart';
import 'package:flutter/material.dart';

class ThemeChangerProvider with ChangeNotifier {
  ThemeData _themeData;
  bool _darkModeEnabled = false;

  ThemeChangerProvider(this._themeData);

  ThemeData get getTheme => _themeData;

  bool get getDarkModeStatus => _darkModeEnabled;

  void setTheme() {
    //void setTheme(BuildContext context) {
    //final ThemeData theme = Theme.of(context);
    //if (theme.brightness == appDarkTheme().brightness) {
    !_darkModeEnabled
        ? _themeData = appLightTheme()
        : _themeData = appDarkTheme();

    _darkModeEnabled = !_darkModeEnabled;
    notifyListeners();
  }

/*void checkIfDarkModeEnabled(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    if (theme.brightness == appDarkTheme().brightness) {
      _darkModeEnabled = true;
    } else {
      _darkModeEnabled = false;
    }
  }*/
}
