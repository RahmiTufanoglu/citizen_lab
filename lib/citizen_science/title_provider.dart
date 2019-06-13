import 'package:flutter/material.dart';

class TitleProvider with ChangeNotifier {
  String _title;

  TitleProvider();

  void setTitle(String title) {
    _title = title;
    notifyListeners();
  }

  String get getTitle => _title;
}
