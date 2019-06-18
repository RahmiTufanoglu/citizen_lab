import 'dart:ui';

import 'package:flutter/material.dart';

class CardImageWithText extends StatelessWidget {
  final String asset;
  final String title;
  final double fontSize;
  final double shadow1OffsetX;
  final double shadow1OffsetY;
  final double shadow2OffsetX;
  final double shadow2OffsetY;
  final double shadow1Blur;
  final double shadow2Blur;
  final Color shadow1Color;
  final Color shadow2Color;
  final Color fontColor;
  final GestureTapCallback onTap;

  CardImageWithText({
    @required this.asset,
    @required this.title,
    @required this.onTap,
    this.fontSize = 36.0,
    this.fontColor = Colors.black,
    this.shadow1Color = Colors.black,
    this.shadow2Color = Colors.black,
    this.shadow1OffsetX = 4.0,
    this.shadow1OffsetY = 4.0,
    this.shadow2OffsetX = 4.0,
    this.shadow2OffsetY = 4.0,
    this.shadow1Blur = 12.0,
    this.shadow2Blur = 16.0,
  })  : assert(asset != null),
        assert(title != null),
        assert(onTap != null);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(16.0),
        ),
      ),
      child: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(16.0),
              ),
              image: DecorationImage(
                image: AssetImage(asset),
                fit: BoxFit.fill,
              ),
            ),
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  color: fontColor,
                  fontSize: fontSize,
                  shadows: <Shadow>[
                    Shadow(
                      offset: Offset(
                        shadow1OffsetX,
                        shadow1OffsetY,
                      ),
                      blurRadius: shadow1Blur,
                      color: shadow1Color,
                    ),
                    Shadow(
                      offset: Offset(
                        shadow2OffsetX,
                        shadow2OffsetY,
                      ),
                      blurRadius: shadow2Blur,
                      color: shadow2Color,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.all(
                Radius.circular(16.0),
              ),
              onTap: onTap,
            ),
          ),
        ],
      ),
    );
  }
}
