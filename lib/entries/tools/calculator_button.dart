import 'package:flutter/material.dart';

class CalculatorButton extends StatelessWidget {
  final bool isIcon;
  final String title;
  final IconData iconData;
  final GestureTapCallback onPressed;

  CalculatorButton(
    this.isIcon,
    this.title,
    this.iconData,
    this.onPressed,
  );

  @override
  Widget build(BuildContext context) {
    return _buildWidget();
  }

  Widget _buildWidget() {
    if (!isIcon) {
      return RaisedButton(
        child: Text(title),
        onPressed: () => onPressed,
      );
    } else {
      return RaisedButton(
        child: Icon(iconData),
        onPressed: () => onPressed,
      );
    }
  }
}
