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
import 'package:citizen_lab/utils/constants.dart';
import 'package:citizen_lab/utils/date_formater.dart';
import 'package:citizen_lab/utils/route_generator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../card_colors.dart';
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
    _loadProjectList();

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
    //_themeChanger.getTheme;

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
        bool result = await Navigator.pushNamed(
          context,
          RouteGenerator.createProject,
        ) as bool;

        if (result) _loadProjectList();
        break;
      case 'Vorlagen':
        bool result = await Navigator.pushNamed(
          context,
          RouteGenerator.projectTemplatePage,
        ) as bool;

        if (result) _loadProjectList();
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
                  padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 88.0),
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
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
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
                          //onLongPress: () => _showContent(index),
                          onLongPress: () => _setCardColor(_project),
                        ),
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

  void _setCardColor(Project project) {
    List<CardColors> cardColors = [
      CardColors(0xFF61BD6D, 0xFF000000),
      CardColors(0xFF1ABC9C, 0xFF000000),
      CardColors(0xFF54ACD2, 0xFF000000),
      CardColors(0xFF2C82C9, 0xFFFFFFFF),
      CardColors(0xFF41A85F, 0xFFFFFFFF),
      CardColors(0xFF00A885, 0xFF000000),
      CardColors(0xFF3D8EB9, 0xFF000000),
      CardColors(0xFF2969B0, 0xFFFFFFFF),
      CardColors(0xFFF7DA64, 0xFF000000),
      CardColors(0xFFFBA026, 0xFF000000),
      CardColors(0xFFEB6B56, 0xFFFFFFFF),
      CardColors(0xFFE14938, 0xFFFFFFFF),
      CardColors(0xFFFAC51C, 0xFF000000),
      CardColors(0xFFF37934, 0xFF000000),
      CardColors(0xFFD14841, 0xFFFFFFFF),
      CardColors(0xFFB8312F, 0xFFFFFFFF),
      CardColors(0xFF9365B8, 0xFFFFFFFF),
      CardColors(0xFF553982, 0xFFFFFFFF),
      CardColors(0xFF475577, 0xFFFFFFFF),
      CardColors(0xFF28324E, 0xFFFFFFFF),
      CardColors(0xFFA38F84, 0xFF000000),
      CardColors(0xFF75706B, 0xFFFFFFFF),
      CardColors(0xFFD1D5D8, 0xFF000000),
      CardColors(0xFFEFEFEF, 0xFF000000),
    ];

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
    _loadProjectList();
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

    if (result) _loadProjectList();
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

  Future<void> _loadProjectList() async {
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

/*Widget _buildBody2() {
    final Color topColor1 = Color(0xFFBFDFCF);
    final Color topColor2 = Color(0xFF009FE3);
    final Color bottomColor1 = Color(0xFFF1CF7F);
    final Color bottomColor2 = Color(0xFFE7F7C0);

    final String createExperiment = 'Experiment erstellen';
    final String openExperiment = 'Experiment öffnen';

    return SafeArea(
      child: WillPopScope(
        onWillPop: () => SystemNavigator.pop(),
        child: FadeTransition(
          opacity: _animation,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: MediaQuery.of(context).orientation == Orientation.portrait
                ? Column(
                    children: <Widget>[
                      Expanded(
                        child: CardImageWithText(
                          asset: 'assets/images/stadtgärtnern_oberhausen.jpg',
                          title: createExperiment,
                          gradientColor1: topColor1,
                          gradientColor2: topColor2,
                          onTap: () =>
                              _setNavigation(RouteGenerator.createProject),
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Expanded(
                        child: CardImageWithText(
                          asset: 'assets/images/aquaponik_anlage.jpg',
                          title: openExperiment,
                          gradientColor1: bottomColor2,
                          gradientColor2: bottomColor1,
                          onTap: () {
                            Map map = Map<String, bool>();
                            map['isFromCreateProjectPage'] = false;
                            _setNavigation(RouteGenerator.projectPage, map);
                          },
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: <Widget>[
                      Expanded(
                        child: CardImageWithText(
                          asset: 'assets/images/stadtgärtnern_oberhausen.jpg',
                          title: createExperiment,
                          gradientColor1: topColor1,
                          gradientColor2: topColor2,
                          shadow1OffsetX: 16.0,
                          shadow2OffsetX: 16.0,
                          shadow1OffsetY: 84.0,
                          shadow2OffsetY: 84.0,
                          onTap: () =>
                              _setNavigation(RouteGenerator.createProject),
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Expanded(
                        child: CardImageWithText(
                          asset: 'assets/images/aquaponik_anlage.jpg',
                          title: openExperiment,
                          gradientColor1: bottomColor2,
                          gradientColor2: bottomColor1,
                          shadow1OffsetX: 16.0,
                          shadow2OffsetX: 16.0,
                          shadow1OffsetY: 84.0,
                          shadow2OffsetY: 84.0,
                          onTap: () {
                            Map map = Map<String, bool>();
                            map['isFromCreateProjectPage'] = false;
                            _setNavigation(RouteGenerator.projectPage, map);
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }*/
}
