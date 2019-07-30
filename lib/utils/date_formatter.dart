import 'package:intl/intl.dart';

String dateFormatted() {
  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('dd.MM.yyyy, kk:mm:ss');
  final String formatted = formatter.format(now);
  return formatted;
}
