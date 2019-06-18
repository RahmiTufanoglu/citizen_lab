import 'package:citizen_lab/custom_widgets/made_with_love_text_box.dart';
import 'package:flutter/material.dart';

class MainDrawer extends StatelessWidget {
  final String location;
  final List<Widget> children;

  MainDrawer({
    this.location = 'Dortmund',
    @required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: screenWidth / 1.5,
      child: Drawer(
        elevation: 16.0,
        child: Stack(
          children: <Widget>[
            Container(
              child: ListView(children: children),
            ),
            Positioned(
              child: SafeArea(
                child: MadeWithLoveTextBox(
                  place: 'in $location',
                ),
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
