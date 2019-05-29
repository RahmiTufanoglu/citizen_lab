import 'package:intl/intl.dart';

String dateFormatted() {
  var now = DateTime.now();
  var formatter = DateFormat('dd.MM.yyyy, hh:mm:ss');
  String formatted = formatter.format(now);
  return formatted;
}
