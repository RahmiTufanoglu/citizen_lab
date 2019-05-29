import 'dart:ui';

import 'package:flutter/material.dart';

class SimpleDrawerHeader extends StatelessWidget {
  final String title;
  final Color titleColor;
  final Color backgroundColor;
  final Color backgroundColor2;
  final double padding;
  final double fontSize;

  SimpleDrawerHeader({
    @required this.title,
    this.titleColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.backgroundColor2 = Colors.white,
    this.fontSize = 24.0,
    this.padding = 8.0,
  })  : assert(title != null),
        assert(titleColor != null),
        assert(backgroundColor != null),
        assert(fontSize != null);

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        //color: backgroundColor,
        color: Colors.black.withOpacity(0.8),
          shape: BoxShape.rectangle,
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Text(
          title,
          style: TextStyle(
            //color: titleColor,
            color: Colors.white,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }
}
