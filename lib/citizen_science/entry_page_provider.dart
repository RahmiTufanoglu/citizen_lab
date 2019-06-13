import 'package:flutter/material.dart';

class EntryPageProvider with ChangeNotifier {
  String _title;

  EntryPageProvider();

  void setTitle(String title) {
    _title = title;
    notifyListeners();
  }

  String get getTitle => _title;
}
