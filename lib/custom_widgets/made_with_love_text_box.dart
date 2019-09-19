import 'package:flutter/material.dart';

class MadeWithLoveTextBox extends StatelessWidget {
  final Key key;
  final String place;
  final Color iconColorHeart;
  final Color iconColorSmile;
  final double iconSize;
  final double iconRightPadding;
  final double iconLeftPadding;

  const MadeWithLoveTextBox({
    @required this.place,
    this.key,
    this.iconColorHeart = Colors.red,
    this.iconColorSmile = Colors.green,
    this.iconSize = 16.0,
    this.iconRightPadding = 4.0,
    this.iconLeftPadding = 4.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const String madeWith = 'Made with';
    const String and = 'and';

    return Semantics(
      label: 'A textbox with love.',
      child: Card(
        margin: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              //const Text(madeWith),
              _buildText(madeWith),
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
              //const Text(and),
              _buildText(and),
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
              //Text(place),
              _buildText(place),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildText(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 12.0),
    );
  }
}
