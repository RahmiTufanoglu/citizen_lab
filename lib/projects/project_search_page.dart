import 'package:citizen_lab/projects/project.dart';
import 'package:citizen_lab/projects/project_item.dart';
import 'package:citizen_lab/themes/theme.dart';
import 'package:citizen_lab/utils/route_generator.dart';
import 'package:flutter/material.dart';

class ProjectSearchPage extends SearchDelegate<String> {
  List<Project> projectList = [];
  bool isFromProjectSearchPage;

  final Function reloadProjectList;
  bool _darkModeEnabled = false;

  ProjectSearchPage({
    @required this.projectList,
    @required this.reloadProjectList,
    @required this.isFromProjectSearchPage,
  });

  @override
  ThemeData appBarTheme(BuildContext context) {
    _checkIfDarkModeEnabled(context);
    return _darkModeEnabled ? appDarkTheme() : appLightTheme();
  }

  /*@override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      primaryColor: theme.primaryColor,
      primaryIconTheme: theme.primaryIconTheme,
      primaryColorBrightness: theme.primaryColorBrightness,
      primaryTextTheme: theme.primaryTextTheme,
    );
  }*/

  void _checkIfDarkModeEnabled(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    theme.brightness == appDarkTheme().brightness
        ? _darkModeEnabled = true
        : _darkModeEnabled = false;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () => query = '',
      ),
      SizedBox(width: 8.0),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList =
        query.isEmpty ? [] : _getProjectTitles(projectList, query);
    return SafeArea(
      child: ListView.builder(
        itemCount: suggestionList == null ? 0 : suggestionList.length,
        padding: EdgeInsets.all(4.0),
        itemBuilder: (context, index) {
          return ProjectItem(
            project: suggestionList[index],
            onTap: () async {
              close(context, null);
              final result = await Navigator.pushNamed(
                context,
                RouteGenerator.entry,
                arguments: {
                  'project': suggestionList[index],
                  'projectTitle': suggestionList[index].title,
                  'isFromCreateProjectPage': false,
                  'isFromProjectPage': true,
                  'isFromProjectSearchPage': true,
                },
              );

              //if (result == 'ok') close(context, result);
              //print('RES' + result);
              if (result) reloadProjectList();
            },
          );
        },
      ),
    );
  }

  List<Project> _getProjectTitles(
    List<Project> notes,
    String query,
  ) {
    List<Project> notesCopy = [];

    for (int i = 0; i < notes.length; i++) {
      if (notes[i].title.toLowerCase().contains(query)) {
        notesCopy.add(notes[i]);
      }
    }

    return notesCopy;
  }
}
