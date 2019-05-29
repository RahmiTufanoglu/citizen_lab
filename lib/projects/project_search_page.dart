import 'package:citizen_lab/themes/theme.dart';
import 'package:citizen_lab/themes/theme_changer.dart';
import 'package:flutter/material.dart';
import 'package:citizen_lab/projects/project.dart';
import 'package:citizen_lab/projects/project_item.dart';
import 'package:citizen_lab/utils/route_generator.dart';
import 'package:provider/provider.dart';

class ProjectSearchPage extends SearchDelegate<String> {
  List<Project> projectList = [];
  final Function reloadProjectList;
  bool _darkModeEnabled = false;

  ProjectSearchPage({
    @required this.projectList,
    @required this.reloadProjectList,
  });

  void _checkIfDarkModeEnabled(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    theme.brightness == appDarkTheme().brightness
        ? _darkModeEnabled = true
        : _darkModeEnabled = false;
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    _checkIfDarkModeEnabled(context);

    /*ThemeData theme = Theme.of(context);
    theme = appLightTheme();
    return theme;*/

    return _darkModeEnabled ? appDarkTheme() : appLightTheme();
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
    return ListView.builder(
      itemCount: suggestionList == null ? 0 : suggestionList.length,
      padding: EdgeInsets.all(4.0),
      itemBuilder: (context, index) {
        return ProjectItem(
          project: suggestionList[index],
          onTap: () async {
            final result = await Navigator.pushNamed(
              context,
              RouteGenerator.entry,
              arguments: {
                'projectTitle': suggestionList[index].title,
                'isFromCreateProjectPage': false,
                'isFromProjectPage': true,
                'project': suggestionList[index],
              },
            );

            if (result) {
              reloadProjectList();
            }
          },
        );
      },
    );
  }

  List<Project> _getProjectTitles(List<Project> notes, String query) {
    List<Project> notesCopy = [];

    for (int i = 0; i < notes.length; i++) {
      if (notes[i].title.toLowerCase().contains(query)) {
        notesCopy.add(notes[i]);
      }
    }

    return notesCopy;
  }
}
