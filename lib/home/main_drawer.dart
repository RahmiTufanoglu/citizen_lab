import 'package:flutter/material.dart';
import 'package:citizen_lab/custom_widgets/made_with_love_text_box.dart';

class MainDrawer extends StatelessWidget {
  final String location;
  final List<Widget> children;

  MainDrawer({
    this.location = 'Dortmund',
    @required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300.0,
      child: Drawer(
        elevation: 16.0,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              child: ListView(children: children),
            ),
            Positioned(
              child: MadeWithLoveTextBox(
                place: 'in $location',
              ),
              width: 300.0,
              bottom: 0.0,
            ),
          ],
        ),
      ),
    );
  }
}
