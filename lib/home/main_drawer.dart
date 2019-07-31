import 'package:citizen_lab/custom_widgets/made_with_love_text_box.dart';
import 'package:flutter/material.dart';

class MainDrawer extends StatelessWidget {
  final double drawerWidth;
  final String location;
  final List<Widget> children;

  const MainDrawer({
    @required this.drawerWidth,
    @required this.location,
    @required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: drawerWidth,
      child: Drawer(
        elevation: 16.0,
        child: Stack(
          children: <Widget>[
            Container(child: ListView(children: children)),
            Positioned(
              width: drawerWidth,
              bottom: 0.0,
              child: SafeArea(
                child: MadeWithLoveTextBox(place: 'in $location'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
