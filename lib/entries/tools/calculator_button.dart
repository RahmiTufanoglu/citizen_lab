import 'package:flutter/material.dart';

class CalculatorButton extends StatelessWidget {
  final bool isIcon;
  final String title;
  final IconData iconData;
  final GestureTapCallback onPressed;

  const CalculatorButton(
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
        onPressed: () => onPressed,
        child: Text(title),
      );
    } else {
      return RaisedButton(
        onPressed: () => onPressed,
        child: Icon(iconData),
      );
    }
  }
}
