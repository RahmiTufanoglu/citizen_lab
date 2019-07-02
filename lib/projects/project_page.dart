import 'package:citizen_lab/custom_widgets/alarm_dialog.dart';
import 'package:citizen_lab/database/database_provider.dart';
import 'package:citizen_lab/projects/project.dart';
import 'package:citizen_lab/projects/project_item.dart';
import 'package:citizen_lab/projects/project_search_page.dart';
import 'package:citizen_lab/themes/theme_changer_provider.dart';
import 'package:citizen_lab/utils/constants.dart';
import 'package:citizen_lab/utils/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProjectPage extends StatefulWidget {
  final bool isFromCreateProjectPage;

  ProjectPage({@required this.isFromCreateProjectPage});

  @override
  _ProjectPageState createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _projectDb = DatabaseProvider.db;
  final List<Project> _projectList = [];

  ThemeChangerProvider _themeChanger;

  //bool _darkModeEnabled = false;

  @override
  void initState() {
    _loadProjectList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _themeChanger = Provider.of<ThemeChangerProvider>(context);
    //_themeChanger.checkIfDarkModeEnabled(context);
    //_checkIfDarkModeEnabled();

    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        tooltip: back,
        icon: Icon(Icons.arrow_back),
        //onPressed: () => Navigator.pop(context),
        onPressed: () => _onBackPressed(),
      ),
      title: GestureDetector(
        onPanStart: (_) => _themeChanger.setTheme(),
        child: Container(
          width: double.infinity,
          child: Tooltip(
            message: '',
            child: Text('Experimente'),
          ),
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            showSearch(
              context: context,
              delegate: ProjectSearchPage(
                projectList: _projectList,
                isFromProjectSearchPage: false,
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
          builder: (contextSnackBar) {
            return IconButton(
              highlightColor: Colors.red.withOpacity(0.2),
              splashColor: Colors.red.withOpacity(0.8),
              icon: Icon(Icons.delete),
              onPressed: () => _deleteAllProjects(contextSnackBar),
            );
          },
        ),
      ],
    );
  }

  /*void _checkIfDarkModeEnabled() {
    final ThemeData theme = Theme.of(context);
    theme.brightness == appDarkTheme().brightness
        ? _darkModeEnabled = true
        : _darkModeEnabled = false;
  }

  void _enableDarkMode() {
    _darkModeEnabled
        ? _themeChanger.setTheme(appLightTheme())
        : _themeChanger.setTheme(appDarkTheme());
  }*/

  Widget _buildFab() {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        Navigator.pushNamed(
          context,
          RouteGenerator.createProject,
        );
      },
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
      child: WillPopScope(
        onWillPop: _onBackPressed,
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
                    onDismissed: (direction) => _deleteProject(index),
                    child: Container(
                      width: double.infinity,
                      child: ProjectItem(
                        project: _projectList[index],
                        onTap: () => _navigateToEntry(index),
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

  Future<void> _navigateToEntry(int index) async {
    final result = await Navigator.pushNamed(
      context,
      RouteGenerator.entry,
      arguments: {
        'project': _projectList[index],
        'projectTitle': _projectList[index].title,
        'isFromCreateProjectPage': false,
        'isFromProjectPage': true,
        'isFromProjectSearchPage': false,
      },
    );

    if (result) _loadProjectList();
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

  Future<void> _loadProjectList() async {
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

    // TODO: check this
    _choiceSortOption(sort_by_release_date_desc);
  }

  Future<void> _deleteProject(int index) async {
    await _projectDb.deleteProject(id: _projectList[index].id);

    if (_projectList.contains(_projectList[index])) {
      setState(() {
        _projectList.removeAt(index);
      });
    }
  }

  Future<bool> _onBackPressed() async {
    if (widget.isFromCreateProjectPage) {
      Navigator.popUntil(
        context,
        ModalRoute.withName(RouteGenerator.routeHomePage),
      );
      /*} else if (widget.isFromProjectSearchPage) {
      Navigator.pop(context, 'fromEntry');*/
    } else {
      Navigator.pop(context, true);
    }

    return false;
  }
}
