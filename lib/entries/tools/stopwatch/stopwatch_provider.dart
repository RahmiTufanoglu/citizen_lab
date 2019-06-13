import 'package:flutter/material.dart';

class StopwatchProvider with ChangeNotifier {
  String _time;

  StopwatchProvider(_time);

  getTime() => _time;

  setTheme(String time) {
    _time = time;
    notifyListeners();
  }
}
