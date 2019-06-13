import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimerProvider with ChangeNotifier {
  TimerProvider();

  void setTimer() {
    notifyListeners();
  }

  String get getTime {
    final String formattedDateTime = _dateFormatted();
    return formattedDateTime;
  }

  String _dateFormatted() {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('dd.MM.yyyy, hh:mm:ss');
    String formatted = formatter.format(now);
    return formatted;
  }
}
