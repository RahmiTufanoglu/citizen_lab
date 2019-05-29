import 'package:flutter/material.dart';

class AlertDialogWithPager extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color titleColor;
  final Color contentColor;
  final double borderRadius;
  final List<Widget> actions;
  final List<Widget> content;

  AlertDialogWithPager({
    @required this.text,
    @required this.actions,
    @required this.content,
    this.borderRadius = 8.0,
    this.fontSize = 18.0,
    this.titleColor = Colors.black,
    this.contentColor = Colors.black,
  })  : assert(text != null),
        assert(actions != null);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(borderRadius),
        ),
      ),
      content: PageView(
        children: <Widget>[],
      ),
      actions: actions,
    );
  }
}
