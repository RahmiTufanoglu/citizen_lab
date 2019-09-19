import 'package:logger/logger.dart';

class CustomLogPrinter extends LogPrinter {
  final String _className;

  CustomLogPrinter(this._className);

  @override
  void log(LogEvent event) {
    final color = PrettyPrinter.levelColors[event.level];
    final emoji = PrettyPrinter.levelEmojis[event.level];
    println(color('$emoji $_className: ${event.message}'));
  }
}

Logger getLogger(String className) =>
    Logger(printer: CustomLogPrinter(className));
