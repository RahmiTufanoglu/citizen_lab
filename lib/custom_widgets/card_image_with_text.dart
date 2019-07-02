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
    this.fontSize = 32.0,
    this.fontColor = Colors.black,
    this.shadow1Color = Colors.grey,
    this.shadow2Color = Colors.grey,
    this.shadow1OffsetX = 12.0,
    this.shadow1OffsetY = 12.0,
    this.shadow2OffsetX = 12.0,
    this.shadow2OffsetY = 12.0,
    this.shadow1Blur = 8.0,
    this.shadow2Blur = 24.0,
  })  : assert(asset != null),
        assert(title != null),
        assert(onTap != null);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
      child: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
              image: DecorationImage(
                image: AssetImage(asset),
                fit: BoxFit.fill,
              ),
              /*gradient: LinearGradient(
                colors: [
                  Colors.white,
                  gradientColor1,
                  gradientColor2,
                ],
              ),*/
            ),
            child: Center(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    ),
                    width: double.infinity,
                    height: 60.0,
                    child: Center(
                      child: Text(
                        title,
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
