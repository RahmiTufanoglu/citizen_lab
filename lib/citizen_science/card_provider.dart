import 'package:flutter/material.dart';

class CardProvider with ChangeNotifier {
  String _type;

  CardProvider(this._type);

  getType() => _type;

  setTheme(String type) {
    _type = type;
    notifyListeners();
  }
}
