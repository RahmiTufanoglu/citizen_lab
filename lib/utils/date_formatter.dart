import 'package:intl/intl.dart';

String dateFormatted() {
  DateTime now = DateTime.now();
  DateFormat formatter = DateFormat('dd.MM.yyyy, kk:mm:ss');
  String formatted = formatter.format(now);
  return formatted;
}
