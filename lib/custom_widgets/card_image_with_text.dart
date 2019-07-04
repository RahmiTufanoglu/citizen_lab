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
  final Color gradientColor1;
  final Color gradientColor2;

  CardImageWithText({
    @required this.asset,
    @required this.title,
    @required this.onTap,
    @required this.gradientColor1,
    @required this.gradientColor2,
    this.fontSize = 28.0,
    this.fontColor = Colors.black,
    this.shadow1Color = Colors.black,
    this.shadow2Color = Colors.black,
    this.shadow1OffsetX = 56.0,
    this.shadow1OffsetY = 56.0,
    this.shadow2OffsetX = 56.0,
    this.shadow2OffsetY = 56.0,
    this.shadow1Blur = 16.0,
    this.shadow2Blur = 24.0,
  })  : assert(asset != null),
        assert(title != null),
        assert(onTap != null);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RaisedButton(
        padding: EdgeInsets.all(0.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
        ),
        child: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
                gradient: LinearGradient(
                  colors: [
                    gradientColor1,
                    gradientColor2,
                  ],
                ),
              ),
              child: Center(
                child: Container(
                  color: Colors.white.withOpacity(0.4),
                  width: double.infinity,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: fontColor,
                      fontSize: fontSize,
                      shadows: <Shadow>[
                        _buildShadow(
                          shadow1OffsetX,
                          shadow1OffsetY,
                          shadow1Blur,
                          shadow1Color,
                        ),
                        _buildShadow(
                          shadow2OffsetX,
                          shadow2OffsetY,
                          shadow2Blur,
                          shadow2Color,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
                onTap: onTap,
              ),
            ),
          ],
        ),
        onPressed: () {},
      ),
    );

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
      child: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
              /*image: DecorationImage(
                image: AssetImage(asset),
                fit: BoxFit.fill,
              ),*/
              gradient: LinearGradient(
                colors: [
                  gradientColor1,
                  gradientColor2,
                ],
              ),
            ),
            child: Center(
              child: Container(
                color: Colors.white,
                width: double.infinity,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: fontColor,
                    fontSize: fontSize,
                    /*shadows: <Shadow>[
                      _buildShadow(
                        shadow1OffsetX,
                        shadow1OffsetY,
                        shadow1Blur,
                        shadow1Color,
                      ),
                      _buildShadow(
                        shadow2OffsetX,
                        shadow2OffsetY,
                        shadow2Blur,
                        shadow2Color,
                      ),
                    ],*/
                  ),
                ),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
              onTap: onTap,
            ),
          ),
        ],
      ),
    );
  }

  Shadow _buildShadow(
    double shadowOffsetX,
    double shadowOffsetY,
    double shadowBlur,
    Color shadowColor,
  ) {
    return Shadow(
      offset: Offset(
        shadowOffsetX,
        shadowOffsetY,
      ),
      blurRadius: shadowBlur,
      color: shadowColor,
    );
  }
}
