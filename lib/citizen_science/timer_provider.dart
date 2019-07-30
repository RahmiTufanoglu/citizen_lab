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
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('dd.MM.yyyy, hh:mm:ss');
    final String formatted = formatter.format(now);
    return formatted;
  }
}
