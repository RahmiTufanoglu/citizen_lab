import 'package:flutter/material.dart';

class SimpleAlertDialogWithIcon extends StatelessWidget {
  final Key key;
  final String text;
  final double fontSize;
  final double iconSize;
  final double borderRadius;
  final double textIconSpace;
  final Color fontColor;
  final Color iconColor;
  final IconData icon;
  final List<Widget> actions;

  const SimpleAlertDialogWithIcon({
    @required this.text,
    @required this.icon,
    @required this.actions,
    this.key,
    this.fontSize = 18.0,
    this.iconSize = 42.0,
    this.textIconSpace = 32.0,
    this.borderRadius = 8.0,
    this.fontColor = Colors.black,
    this.iconColor = Colors.red,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      ),
      title: Column(
        children: <Widget>[
          Text(
            text,
            style: TextStyle(
              color: fontColor,
              fontSize: fontSize,
            ),
          ),
          SizedBox(height: textIconSpace),
          Icon(
            icon,
            color: iconColor,
            size: iconSize,
          ),
        ],
      ),
      actions: actions,
    );
  }
}
