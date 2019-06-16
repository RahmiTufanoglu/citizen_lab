import 'package:flutter/material.dart';

class TopTextCard extends StatelessWidget {
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
  final GestureTapCallback onTapTitle;
  final GestureTapCallback onTapImage;

  TopTextCard({
    @required this.asset,
    @required this.title,
    @required this.onTapTitle,
    @required this.onTapImage,
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
        assert(onTapImage != null);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Stack(
              children: <Widget>[
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      topRight: Radius.circular(8.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(),
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTapTitle,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      topRight: Radius.circular(8.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 8,
            child: Stack(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(asset),
                          fit: BoxFit.fill,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8.0),
                          bottomRight: Radius.circular(8.0),
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onTapImage,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8.0),
                          bottomRight: Radius.circular(8.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}