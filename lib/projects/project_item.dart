import 'package:citizen_lab/projects/project.dart';
import 'package:flutter/material.dart';

class ProjectItem extends StatelessWidget {
  final Project project;
  final GestureTapCallback onTap;
  final GestureTapCallback onLongPress;

  ProjectItem({
    @required this.project,
    @required this.onTap,
    @required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double topBarHeight =
        MediaQuery.of(context).padding.top + kToolbarHeight;

    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        height: (screenHeight + topBarHeight) / 10,
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
        child: RaisedButton(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: (screenWidth - 8.0) / 1.5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          project.title,
                          style: TextStyle(color: Color(project.cardTextColor)),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Erstellt am: ${project.dateCreated}',
                          style: TextStyle(
                            color: Color(project.cardTextColor),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.touch_app,
                size: 20.0,
                color: Color(project.cardTextColor),
              ),
            ],
          ),
          color: Color(project.cardColor),
          onPressed: onTap,
        ),
      ),
    );
  }
}
