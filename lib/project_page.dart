import 'package:flutter/material.dart';
import 'package:citizen_lab/project.dart';
import 'package:citizen_lab/project_database_provider.dart';
import 'package:citizen_lab/project_item.dart';
import 'package:citizen_lab/project_search_page.dart';
import 'package:citizen_lab/route_generator.dart';

import 'alarm_dialog.dart';
import 'constants.dart';

class ProjectPage extends StatefulWidget {
  @override
  _ProjectPageState createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _projectDb = ProjectDatabaseProvider();
  final List<Project> _projectList = [];

  @override
  void initState() {
    super.initState();
    _loadProjectList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        tooltip: back,
        icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text('Projekte'),
      elevation: 4.0,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            showSearch(
              context: context,
              delegate: ProjectSearchPage(
                projectList: _projectList,
                reloadProjectList: () => _loadProjectList(),
              ),
            );
          },
        ),
        PopupMenuButton(
          icon: Icon(Icons.sort),
          elevation: 2.0,
          tooltip: sort_options,
          onSelected: _choiceSortOption,
          itemBuilder: (BuildContext context) {
            return choices.map(
              (String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              },
            ).toList();
          },
        ),
        Builder(
          builder: (contextSnackBar) => IconButton(
                highlightColor: Colors.red.withOpacity(0.2),
                splashColor: Colors.red.withOpacity(0.8),
                icon: Icon(Icons.delete),
                onPressed: () => _deleteAllProjects(contextSnackBar),
              ),
        ),
      ],
    );
  }

  Future<bool> _deleteAllProjects(BuildContext contextSnackBar) async {
    return await showDialog(
      context: context,
      builder: (context) => AlarmDialog(
            text: 'Alle Projekte löschen?',
            icon: Icons.warning,
            onTap: () {
              if (_projectList.isNotEmpty) {
                _projectDb.deleteAllProjects();
                _scaffoldKey.currentState.showSnackBar(
                  _buildSnackBar(text: 'Projekte gelöscht.'),
                );
              } else {
                _scaffoldKey.currentState.showSnackBar(
                  _buildSnackBar(text: 'Nichts gelöscht.'),
                );
              }

              setState(() {
                _projectList.clear();
              });

              Navigator.pop(context);
            },
          ),
    );
  }

  void _choiceSortOption(String choice) {
    switch (choice) {
      case sort_by_title_arc:
        setState(() {
          _projectList.sort(
            (Project a, Project b) =>
                a.title.toLowerCase().compareTo(b.title.toLowerCase()),
          );
        });
        break;
      case sort_by_title_desc:
        setState(() {
          _projectList.sort(
            (Project a, Project b) =>
                b.title.toLowerCase().compareTo(a.title.toLowerCase()),
          );
        });
        break;
      case sort_by_release_date_asc:
        setState(() {
          _projectList.sort(
            (Project a, Project b) => a.dateCreated.compareTo(b.dateCreated),
          );
        });
        break;
      case sort_by_release_date_desc:
        setState(() {
          _projectList.sort(
            (Project a, Project b) => b.dateCreated.compareTo(a.dateCreated),
          );
        });
        break;
      default:
        break;
    }
  }

  Widget _buildBody() {
    return SafeArea(
      child: Container(
        child: _projectList.isNotEmpty
            ? ListView.builder(
                padding: const EdgeInsets.all(8.0),
                reverse: false,
                itemCount: _projectList.length,
                itemBuilder: (context, index) {
                  final _project = _projectList[index];
                  final key = Key('${_project.hashCode}');
                  return Dismissible(
                    key: key,
                    direction: DismissDirection.startToEnd,
                    background: Container(
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.arrow_forward,
                            size: 28.0,
                          ),
                          SizedBox(width: 8.0),
                          Icon(
                            Icons.delete,
                            size: 28.0,
                          ),
                        ],
                      ),
                    ),
                    onDismissed: (direction) {
                      _deleteProject(index);
                    },
                    child: Container(
                      width: double.infinity,
                      child: ProjectItem(
                        project: _projectList[index],
                        onTap: () async {
                          await Navigator.pushNamed(
                            context,
                            RouteGenerator.entry,
                            arguments: {
                              'projectTitle': _projectList[index].title,
                              'isFromCreateProjectPage': false,
                              'isFromProjectPage': true,
                              'project': _projectList[index],
                            },
                          );
                        },
                      ),
                    ),
                  );
                },
              )
            : Center(
                child: Text(
                  empty_list,
                  style: TextStyle(fontSize: 24.0),
                ),
              ),
      ),
    );
  }

  Widget _buildSnackBar({@required String text}) {
    return SnackBar(
      backgroundColor: Colors.black.withOpacity(0.5),
      duration: Duration(seconds: 1),
      content: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  _loadProjectList() async {
    for (int i = 0; i < _projectList.length; i++) {
      _projectList.removeWhere((element) {
        _projectList[i].id = _projectList[i].id;
      });
    }

    List projects = await _projectDb.getAllProjects();

    projects.forEach((project) {
      setState(() {
        _projectList.add(Project.map(project));
      });
    });
  }

  _deleteProject(int index) async {
    await _projectDb.deleteProject(id: _projectList[index].id);

    if (_projectList.contains(_projectList[index])) {
      setState(() {
        _projectList.removeAt(index);
      });
    }
  }
}
