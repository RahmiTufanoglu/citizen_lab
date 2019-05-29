import 'package:flutter/widgets.dart';

class InheritedTheme extends InheritedWidget {
  final snapshot;

  InheritedTheme({
    this.snapshot,
    Widget child,
  }) : super(child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static InheritedTheme of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(InheritedTheme);
  }
}
