import 'package:citizen_lab/custom_widgets/alarm_dialog.dart';
import 'package:citizen_lab/custom_widgets/dial_floating_action_button.dart';
import 'package:citizen_lab/custom_widgets/feedback_dialog.dart';
import 'package:citizen_lab/database/database_provider.dart';
import 'package:citizen_lab/home/main_drawer.dart';
import 'package:citizen_lab/projects/project.dart';
import 'package:citizen_lab/projects/project_item.dart';
import 'package:citizen_lab/projects/project_search_page.dart';
import 'package:citizen_lab/themes/theme.dart';
import 'package:citizen_lab/themes/theme_changer_provider.dart';
import 'package:citizen_lab/utils/colors.dart';
import 'package:citizen_lab/utils/constants.dart';
import 'package:citizen_lab/utils/date_formater.dart';
import 'package:citizen_lab/utils/route_generator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../entry_fab_data.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animation;
  ThemeChangerProvider _themeChanger;
  bool _valueSwitch = false;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _projectDb = DatabaseProvider.db;
  final List<Project> _projectList = [];

  @override
  void initState() {
    super.initState();
    _loadProjectList(false);

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    _animation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);

    _animationController.forward();
  }

  void _checkIfDarkModeEnabled() {
    Theme.of(context).brightness == appDarkTheme().brightness
        ? _valueSwitch = true
        : _valueSwitch = false;

    print(_valueSwitch.toString());
  }

  @override
  Widget build(BuildContext context) {
    _themeChanger = Provider.of<ThemeChangerProvider>(context);
    _checkIfDarkModeEnabled();

    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: _buildBody(),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      title: GestureDetector(
        onPanStart: (_) => _themeChanger.setTheme(),
        child: Container(
          width: double.infinity,
          child: Tooltip(
            message: APP_TITLE,
            child: Text(APP_TITLE),
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
                reloadProjectList: () => _loadProjectList(false),
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
        /*Builder(
          builder: (contextSnackBar) {
            return IconButton(
              highlightColor: Colors.red.withOpacity(0.2),
              splashColor: Colors.red.withOpacity(0.8),
              icon: Icon(Icons.delete),
              onPressed: () => _deleteAllProjects(contextSnackBar),
            );
          },
        ),*/
      ],
    );
  }

  Widget _buildFab() {
    /*return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        Navigator.pushNamed(
          context,
          RouteGenerator.createProject,
        );
      },
    );*/
    return DialFloatingActionButton(
      iconList: projectIconList,
      //colorList: projectColorList,
      stringList: projectStringList,
      function: _createProject,
    );
  }

  void _createProject(String type, [Project project]) async {
    switch (type) {
      case 'Neues Projekt':
        //bool result = await Navigator.pushNamed(
        Project result = await Navigator.pushNamed(
          context,
          RouteGenerator.createProject,
          //) as bool;
        ) as Project;

        //if (result != null && result) {
        if (result != null) {
          _scaffoldKey.currentState.showSnackBar(
            //_buildSnackBar(text: 'Neues Projekt hinzugefügt.'),
            _buildSnackBar(text: 'Neues ${result.title} hinzugefügt.'),
          );

          _loadProjectList(true);
        }
        break;
      case 'Vorlagen':
        bool result = await Navigator.pushNamed(
          context,
          RouteGenerator.projectTemplatePage,
        ) as bool;

        if (result != null && result) {
          _scaffoldKey.currentState.showSnackBar(
            _buildSnackBar(text: 'Neues Projekt hinzugefügt.'),
          );

          _loadProjectList(true);
        }
        break;
    }
  }

  Future<bool> _deleteAllProjects(BuildContext context) async {
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
        setSortingOrder(sort_by_title_arc);
        break;
      case sort_by_title_desc:
        setState(() {
          _projectList.sort(
            (Project a, Project b) =>
                b.title.toLowerCase().compareTo(a.title.toLowerCase()),
          );
        });
        setSortingOrder(sort_by_title_desc);
        break;
      case sort_by_release_date_asc:
        setState(() {
          _projectList.sort(
            (Project a, Project b) => a.dateCreated.compareTo(b.dateCreated),
          );
        });
        setSortingOrder(sort_by_release_date_asc);
        break;
      case sort_by_release_date_desc:
        setState(() {
          _projectList.sort(
            (Project a, Project b) => b.dateCreated.compareTo(a.dateCreated),
          );
        });
        setSortingOrder(sort_by_release_date_desc);
        break;
      default:
        break;
    }
  }

  Widget _buildDrawer() {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double drawerHeaderHeight =
        (screenHeight / 3) - kToolbarHeight - statusBarHeight;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double drawerWidth = screenWidth / 1.5;
    final String about = 'Über';
    final String location = 'Dortmund';

    return MainDrawer(
      drawerWidth: drawerWidth,
      location: location,
      children: <Widget>[
        Container(
          height: drawerHeaderHeight,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0),
              ),
            ),
            margin: const EdgeInsets.all(0.0),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      APP_TITLE,
                      style: TextStyle(fontSize: 24.0),
                    ),
                    Spacer(),
                    Image(
                      image: AssetImage('assets/app_logo.png'),
                      height: 42.0,
                      width: 42.0,
                    ),
                    SizedBox(width: 16.0),
                  ],
                ),
              ),
            ),
          ),
        ),
        Column(
          children: <Widget>[
            SizedBox(height: 16.0),
            /*_buildDrawerItem(
              context: context,
              icon: Icons.border_color,
              title: createExperiment,
              onTap: () => _setNavigation(RouteGenerator.createProject),
            ),*/
            /*_buildDrawerItem(
              context: context,
              icon: Icons.assignment,
              title: openExperiment,
              onTap: () {
                Map map = Map<String, bool>();
                map['isFromCreateProjectPage'] = false;
                _setNavigation(RouteGenerator.projectPage, map);
              },
            ),*/
            _buildDrawerItem(
              context: context,
              icon: Icons.public,
              title: 'Citizen Science',
              onTap: () => _setNavigation(RouteGenerator.citizenSciencePage),
            ),
          ],
        ),
        Divider(
          color: Colors.black,
          height: 0.5,
        ),
        Builder(
          builder: (BuildContext context) {
            return ExpansionTile(
              title: null,
              //leading: Icon(Icons.settings),
              leading: Icon(
                Icons.settings,
                color: Theme.of(context).brightness == appDarkTheme().brightness
                    ? Colors.white
                    : Color(0xFF3B3B3B),
              ),
              children: <Widget>[
                _buildDrawerItem(
                  context: context,
                  icon: Icons.delete_forever,
                  title: 'Alles löschen',
                  onTap: () => _deleteAllProjects(context),
                ),
              ],
            );
          },
        ),
        Column(
          children: <Widget>[
            _buildDrawerItem(
              context: context,
              icon: Icons.feedback,
              title: feedback,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => FeedbackDialog(url: fraunhofer_umsicht_url),
                );
              },
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.info,
              title: about,
              onTap: () {
                Map map = Map<String, String>();
                map['title'] = 'Über';
                map['content'] = lorem;
                _setNavigation(RouteGenerator.aboutPage, map);
              },
            ),
          ],
        ),
        Divider(
          color: Colors.black,
          height: 0.5,
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Icon(Icons.brightness_2),
              Switch(
                inactiveTrackColor: Color(0xFF191919),
                activeTrackColor: Colors.white,
                inactiveThumbColor: Colors.white,
                activeColor: Color(0xFF191919),
                value: _valueSwitch,
                onChanged: (bool value) => _onChangedSwitch(value),
              ),
            ],
          ),
        ),
        SizedBox(height: 32.0),
      ],
    );
  }

  void _setNavigation(String route, [Object arguments]) {
    Navigator.pushNamed(
      context,
      route,
      arguments: arguments,
    );
  }

  void _onChangedSwitch(bool value) {
    _themeChanger.setTheme();
    _valueSwitch = value;
  }

  Widget _buildDrawerItem({
    BuildContext context,
    IconData icon,
    String title,
    Widget widget,
    @required GestureTapCallback onTap,
  }) {
    return Container(
      height: 60.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Icon(icon),
                Text(title),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () => SystemNavigator.pop(),
        child: FadeTransition(
          opacity: _animation,
          child: _projectList.isNotEmpty
              ? ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 88.0),
                  reverse: false,
                  itemCount: _projectList.length,
                  itemBuilder: (context, index) {
                    final project = _projectList[index];
                    final key = Key('${project.hashCode}');
                    return Dismissible(
                      key: key,
                      direction: DismissDirection.startToEnd,
                      background: Container(
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.arrow_forward, size: 28.0),
                            SizedBox(width: 8.0),
                            Icon(Icons.delete, size: 28.0),
                          ],
                        ),
                      ),
                      onDismissed: (direction) => _deleteProject(index),
                      child: Container(
                        width: double.infinity,
                        child: _buildItem(project, index),
                        /*child: NoteItem(
                          note: _projectList[index],
                          isNote: false,
                          isFromNoteSearchPage: false,
                          close: null,
                          noteFunction: () => _navigateToEntry(index),
                          onLongPress: () => _setCardColor(_project),
                        ),*/
                      ),
                    );
                  },
                )
              : /*Center(
                  child: Opacity(
                    opacity: 0.5,
                    child: Image(
                      image: AssetImage('assets/app_logo.png'),
                      width: 150.0,
                      height: 150.0,
                    ),
                  ),
                ),*/
              Container(),
        ),
      ),
    );
  }

  Widget _buildItem(Project project, int index) {
    final double screenHeight =
        MediaQuery.of(context).size.height - kToolbarHeight;
    final _note = _projectList[index];

    return Container(
      height: MediaQuery.of(context).orientation == Orientation.portrait
          ? screenHeight / 8
          : screenHeight / 4,
      child: ProjectItem(
        project: _projectList[index],
        onTap: () => _navigateToEntry(index),
        onLongPress: () => _setCardColor(project),
      ),
    );
    return ProjectItem(
      project: _projectList[index],
      onTap: () => _navigateToEntry(index),
      onLongPress: () => _setCardColor(project),
    );
  }

  void _setCardColor(Project project) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
            contentPadding: const EdgeInsets.all(0.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            children: <Widget>[
              Scrollbar(
                child: Container(
                  height: screenHeight / 2,
                  width: screenWidth / 2,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: cardColors.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                    ),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FloatingActionButton(
                          backgroundColor:
                              Color(cardColors[index].cardBackgroundColor),
                          onPressed: () {
                            _updateProject(
                              project,
                              cardColors[index].cardBackgroundColor,
                              cardColors[index].cardItemColor,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _updateProject(Project project, int cardColor, int cardTextColor) async {
    Project updatedProject = Project.fromMap({
      DatabaseProvider.columnProjectId: project.id,
      DatabaseProvider.columnProjectRandom: project.random,
      DatabaseProvider.columnProjectTitle: project.title,
      DatabaseProvider.columnProjectDesc: project.description,
      DatabaseProvider.columnProjectCreatedAt: project.dateCreated,
      DatabaseProvider.columnProjectUpdatedAt: dateFormatted(),
      DatabaseProvider.columnProjectCardColor: cardColor,
      DatabaseProvider.columnProjectCardTextColor: cardTextColor,
    });
    await _projectDb.updateProject(newProject: updatedProject);
    _loadProjectList(true);
    Navigator.pop(context, updatedProject);
  }

  void _navigateToEntry(int index) async {
    final result = await Navigator.pushNamed(
      context,
      RouteGenerator.entry,
      arguments: {
        'project': _projectList[index],
        'projectTitle': _projectList[index].title,
        'isFromProjectPage': true,
        'isFromProjectSearchPage': false,
      },
    );

    if (result) _loadProjectList(false);
  }

  void _showContent(int index) {
    final String createdAt = 'Erstellt am';

    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            contentPadding: EdgeInsets.all(16.0),
            titlePadding: EdgeInsets.only(left: 16.0),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 16.0),
                    Text(
                      '$createdAt: '
                      '${_projectList[index].dateCreated}',
                      style: TextStyle(
                          fontSize: 14.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16.0),
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
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Text(_projectList[index].title, style: TextStyle(fontSize: 16.0)),
              SizedBox(height: 32.0),
              Text(
                '$desc:',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Text(
                _projectList[index].description,
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 8.0),
            ],
          ),
    );
  }

  Widget _buildSnackBar({@required String text}) {
    return SnackBar(
      backgroundColor: Colors.black87,
      duration: Duration(seconds: 1),
      content: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  final String _kSortingOrderPrefs = 'sortOrder';

  Future<String> _getSortingOrder() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //return prefs.getString(_kSortingOrderPrefs) ?? sort_by_release_date_desc;
    final order = prefs.getString(_kSortingOrderPrefs);
    if (order == null) {
      return sort_by_release_date_desc;
    }
    return order;
  }

  Future<void> setSortingOrder(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_kSortingOrderPrefs, value);
  }

  Future<void> _loadProjectList(bool newProject) async {
    for (int i = 0; i < _projectList.length; i++) {
      _projectList.removeWhere((element) {
        _projectList[i].id = _projectList[i].id;
      });
    }

    List projects = await _projectDb.getAllProjects();

    /*for (int i = 0; i < projects.length; i++) {
      setState(() {
        _projectList.insert(i, projects[i]);
      });
    }*/

    projects.forEach((project) {
      setState(() {
        //_projectList.add(Project.map(project));
        _projectList.insert(0, Project.map(project));
      });
    });

    // Add new projects on top of the list without sorting the list
    //if (!newProject) _choiceSortOption(await _getSortingOrder());
    _choiceSortOption(await _getSortingOrder());
  }

  Future<void> _deleteProject(int index) async {
    await _projectDb.deleteProject(id: _projectList[index].id);

    _scaffoldKey.currentState.showSnackBar(
      _buildSnackBar(text: 'Projekt ${_projectList[index].title} gelöscht.'),
    );

    if (_projectList.contains(_projectList[index])) {
      setState(() {
        _projectList.removeAt(index);
      });
    }
  }
}
