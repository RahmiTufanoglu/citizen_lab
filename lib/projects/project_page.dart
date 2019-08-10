import 'package:citizen_lab/custom_widgets/alarm_dialog.dart';
import 'package:citizen_lab/database/database_helper.dart';
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

  const ProjectPage({@required this.isFromCreateProjectPage});

  @override
  _ProjectPageState createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _projectDb = DatabaseHelper.db;
  final List<Project> _projectList = [];

  ThemeChangerProvider _themeChanger;

  @override
  void initState() {
    super.initState();
    _loadProjectList();
  }

  @override
  Widget build(BuildContext context) {
    _themeChanger = Provider.of<ThemeChangerProvider>(context);

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
        onPressed: () => _onBackPressed(),
      ),
      title: GestureDetector(
        onPanStart: (_) => _themeChanger.setTheme(),
        child: Container(
          width: double.infinity,
          child: Tooltip(
            message: '',
            child: const Text('Experimente'),
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
          tooltip: sortOptions,
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

  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.pushNamed(
          context,
          createProjectPage,
        );
      },
      child: const Icon(Icons.add),
    );
  }

  void _deleteAllProjects(BuildContext contextSnackBar) {
    const String deleteAllProjects = 'Alle Projekte löschen?';
    const String projectDeleted = 'Projekte gelöscht.';
    const String nothingDeleted = 'Nichts gelöscht.';

    showDialog(
      context: context,
      builder: (context) => AlarmDialog(
        text: deleteAllProjects,
        icon: Icons.warning,
        onTap: () {
          if (_projectList.isNotEmpty) {
            _projectDb.deleteAllProjects();
            _scaffoldKey.currentState.showSnackBar(
              _buildSnackBar(text: projectDeleted),
            );
          } else {
            _scaffoldKey.currentState.showSnackBar(
              _buildSnackBar(text: nothingDeleted),
            );
          }

          setState(() => _projectList.clear());

          Navigator.pop(context);
        },
      ),
    );
  }

  void _choiceSortOption(String choice) {
    switch (choice) {
      case sortByTitleArc:
        setState(() {
          _projectList.sort(
            (Project a, Project b) =>
                a.title.toLowerCase().compareTo(b.title.toLowerCase()),
          );
        });
        break;
      case sortByTitleDesc:
        setState(() {
          _projectList.sort(
            (Project a, Project b) =>
                b.title.toLowerCase().compareTo(a.title.toLowerCase()),
          );
        });
        break;
      case sortByReleaseDateAsc:
        setState(() {
          _projectList.sort(
            (Project a, Project b) => a.createdAt.compareTo(b.createdAt),
          );
        });
        break;
      case sortByReleaseDateDesc:
        setState(() {
          _projectList.sort(
            (Project a, Project b) => b.createdAt.compareTo(a.createdAt),
          );
        });
        break;
    }
  }

  Widget _buildBody() {
    return SafeArea(
      child: WillPopScope(
        onWillPop: _onBackPressed,
        child: _projectList.isNotEmpty
            ? ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  8.0,
                  8.0,
                  8.0,
                  88.0,
                ),
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
                      decoration: const BoxDecoration(
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
                          const SizedBox(width: 8.0),
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
                        onLongPress: () => _showContent(index),
                      ),
                    ),
                  );
                },
              )
            : Center(
                child: Text(
                  emptyList,
                  style: TextStyle(fontSize: 24.0),
                ),
              ),
      ),
    );
  }

  Future<void> _navigateToEntry(int index) async {
    final result = await Navigator.pushNamed(
      context,
      projectPage,
      arguments: {
        'project': _projectList[index],
        'projectTitle': _projectList[index].title,
        'isFromCreateProjectPage': false,
        'isFromProjectPage': true,
        'isFromProjectSearchPage': false,
      },
    );

    if (result) await _loadProjectList();
  }

  void _showContent(int index) {
    const String createdAt = 'Erstellt am';

    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        ),
        contentPadding: const EdgeInsets.all(16.0),
        titlePadding: const EdgeInsets.only(left: 16.0),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 16.0),
                Text(
                  '$createdAt: '
                  '${_projectList[index].createdAt}',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),
              ],
            ),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        children: <Widget>[
          Text(
            '$title:',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            _projectList[index].title,
            style: TextStyle(fontSize: 16.0),
          ),
          const SizedBox(height: 32.0),
          Text(
            '$desc:',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            _projectList[index].description,
            style: TextStyle(fontSize: 16.0),
          ),
          const SizedBox(height: 8.0),
        ],
      ),
    );
  }

  Widget _buildSnackBar({@required String text}) {
    return SnackBar(
      backgroundColor: Colors.black87,
      duration: const Duration(seconds: 1),
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
        return true;
      });
    }

    final List projects = await _projectDb.getAllProjects();

    projects.forEach((project) {
      setState(() => _projectList.add(Project.map(project)));
    });

    _choiceSortOption(sortByReleaseDateDesc);
  }

  Future<void> _deleteProject(int index) async {
    await _projectDb.deleteProject(id: _projectList[index].id);

    if (_projectList.contains(_projectList[index])) {
      setState(() => _projectList.removeAt(index));
    }
  }

  Future<bool> _onBackPressed() async {
    if (widget.isFromCreateProjectPage) {
      Navigator.popUntil(
        context,
        ModalRoute.withName(routeHomePage),
      );
      /*} else if (widget.isFromProjectSearchPage) {
      Navigator.pop(context, 'fromEntry');*/
    } else {
      Navigator.pop(context, true);
    }
    return false;
  }
}
