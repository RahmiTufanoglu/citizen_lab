import 'package:citizen_lab/projects/project.dart';
import 'package:flutter/material.dart';

class ProjectItem extends StatelessWidget {
  final Project project;
  final GestureTapCallback onTap;
  final GestureTapCallback onLongPress;

  ProjectItem({
    @required this.project,
    @required this.onLongPress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(project.cardColor),
      margin: EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                project.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: Color(project.cardTextColor),
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                'Erstellt am: ${project.dateCreated}',
                style: TextStyle(
                  fontSize: 14.0,
                  fontStyle: FontStyle.italic,
                  color: Color(project.cardTextColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
