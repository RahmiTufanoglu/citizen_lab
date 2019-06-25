import 'package:flutter/material.dart';

class TitleChangerProvider with ChangeNotifier {
  String _title = '';

  void setTitle(String title) {
    _title = title;
    notifyListeners();
  }

  String titleIsEmpty = 'Title ist leer.';

  String getErrorMessage() {
    if (_title.isEmpty) {
      return titleIsEmpty;
    } else {
      return 'A';
    }
  }

  String get getTitle => _title;
}
