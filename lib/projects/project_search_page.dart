import 'package:citizen_lab/projects/project.dart';
import 'package:citizen_lab/projects/project_item.dart';
import 'package:citizen_lab/themes/theme.dart';
import 'package:citizen_lab/utils/route_generator.dart';
import 'package:flutter/material.dart';

class ProjectSearchPage extends SearchDelegate<String> {
  List<Project> projectList = [];
  bool isFromProjectSearchPage;
  bool _darkModeEnabled = false;

  final Function reloadProjectList;

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
      const SizedBox(width: 8.0),
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
        padding: const EdgeInsets.all(4.0),
        itemBuilder: (context, index) {
          return ProjectItem(
            project: suggestionList[index],
            onLongPress: () {},
            onTap: () => _setNavigation(context, suggestionList, index),
          );
        },
      ),
    );
  }

  Future<void> _setNavigation(
    BuildContext context,
    List list,
    int index,
  ) async {
    close(context, null);
    final result = await Navigator.pushNamed(
      context,
      CustomRoute.projectPage,
      arguments: {
        'project': list[index],
        'projectTitle': list[index].title,
        'isFromCreateProjectPage': false,
        'isFromProjectPage': true,
        'isFromProjectSearchPage': true,
      },
    );

    if (result) reloadProjectList();
  }

  List<Project> _getProjectTitles(
    List<Project> notes,
    String query,
  ) {
    final List<Project> notesCopy = [];

    for (int i = 0; i < notes.length; i++) {
      if (notes[i].title.toLowerCase().contains(query)) {
        notesCopy.add(notes[i]);
      }
    }

    return notesCopy;
  }
}
