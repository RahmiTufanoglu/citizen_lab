import 'package:flutter/material.dart';
import 'package:citizen_lab/colors.dart';

class FlatAlertDialogButton extends StatelessWidget {
  final String title;
  final double fontSize;
  final double borderRadius;
  final double elevation;
  final double highlightElevation;
  final double textPadding;
  final Color fontColor;
  final Color buttonColor;
  final GestureTapCallback onPressed;

  FlatAlertDialogButton({
    @required this.title,
    @required this.onPressed,
    this.fontSize = 18.0,
    this.borderRadius = 8.0,
    this.elevation = 2.0,
    this.highlightElevation = 8.0,
    this.textPadding = 8.0,
    this.fontColor = Colors.black,
    this.buttonColor = background_grey_dark,
  })  : assert(title != null),
        assert(onPressed != null);

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      fillColor: buttonColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      elevation: elevation,
      highlightElevation: highlightElevation,
      child: Padding(
        padding: EdgeInsets.all(textPadding),
        child: Text(
          title,
          style: TextStyle(
            color: fontColor,
            fontSize: fontSize,
          ),
        ),
      ),
      onPressed: onPressed,
    );
  }
}
