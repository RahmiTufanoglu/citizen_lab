import 'package:flutter/material.dart';

class MadeWithLoveTextBox extends StatelessWidget {
  final String place;
  final Color iconColorHeart;
  final Color iconColorSmile;
  final double iconSize;
  final double iconRightPadding;
  final double iconLeftPadding;

  MadeWithLoveTextBox({
    @required this.place,
    this.iconColorHeart = Colors.red,
    this.iconColorSmile = Colors.green,
    this.iconSize = 16.0,
    this.iconRightPadding = 4.0,
    this.iconLeftPadding = 4.0,
  }) : assert(place != null);

  @override
  Widget build(BuildContext context) {
    final String madeWith = 'Made with';
    final String and = 'and';

    return Card(
      shape: Border(),
      margin: const EdgeInsets.all(0.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(madeWith),
            Padding(
              padding: EdgeInsets.only(
                right: iconRightPadding,
                left: iconLeftPadding,
              ),
              child: Icon(
                Icons.favorite,
                size: iconSize,
                color: iconColorHeart,
              ),
            ),
            Text(and),
            Padding(
              padding: EdgeInsets.only(
                right: iconRightPadding,
                left: iconLeftPadding,
              ),
              child: Icon(
                Icons.tag_faces,
                size: iconSize,
                color: iconColorSmile,
              ),
            ),
            Text(place),
          ],
        ),
      ),
    );
  }
}
