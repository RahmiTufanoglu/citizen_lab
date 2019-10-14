import 'package:citizen_lab/app_locations.dart';
import 'package:citizen_lab/custom_widgets/custom_widgets.dart';
import 'package:citizen_lab/database/database_helper.dart';
import 'package:citizen_lab/home/main_drawer.dart';
import 'package:citizen_lab/notes/text/text_template_item.dart';
import 'package:citizen_lab/projects/project.dart';
import 'package:citizen_lab/projects/project_item.dart';
import 'package:citizen_lab/projects/project_search_page.dart';
import 'package:citizen_lab/themes/theme.dart';
import 'package:citizen_lab/themes/theme_changer_provider.dart';
import 'package:citizen_lab/utils/app_colors.dart';
import 'package:citizen_lab/utils/constants.dart';
import 'package:citizen_lab/utils/date_formatter.dart';
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

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animation;
  bool _valueSwitch = false;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _projectDb = DatabaseHelper.db;
  final List<Project> _projects = [];
  final String _sortOrder = 'sortOrder';

  @override
  void initState() {
    super.initState();
    _loadProjectList();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _animation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeChangerProvider>(
      builder: (context, themeChanger, child) {
        return Scaffold(
          key: _scaffoldKey,
          appBar: _buildAppBar(themeChanger),
          drawer: _buildDrawer(themeChanger),
          body: _buildBody(),
          floatingActionButton: _buildFabs(),
        );
      },
    );
  }

  Widget _buildAppBar(ThemeChangerProvider themeData) {
    return AppBar(
      title: GestureDetector(
        onPanStart: (_) => themeData.setTheme(),
        child: Container(
          width: double.infinity,
          child: const Tooltip(
            message: Constants.appTitle,
            child: Text(Constants.appTitle),
          ),
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () => _setSearch(),
        ),
        PopupMenuButton(
          icon: Icon(Icons.sort),
          elevation: 2.0,
          tooltip: AppLocalizations.of(context).translate('sortOptions'),
          onSelected: _choiceSortOption,
          itemBuilder: (BuildContext context) {
            return Constants.choices.map(
              (String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              },
            ).toList();
          },
        ),
      ],
    );
  }

  void _setSearch() {
    showSearch(
      context: context,
      delegate: ProjectSearchPage(
        projectList: _projects,
        isFromProjectSearchPage: false,
        reloadProjectList: () => _loadProjectList(),
      ),
    );
  }

  Widget _buildFabs() {
    return Padding(
      padding: const EdgeInsets.only(left: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            heroTag: null,
            tooltip: '',
            onPressed: () => _openModalBottomSheet(),
            child: Icon(Icons.keyboard_arrow_up),
          ),
          DialFloatingActionButton(
            iconList: projectIcons,
            stringList: projectStrings,
            function: _createProject,
            isNoteCard: false,
          ),
        ],
      ),
    );
  }

  Future<void> _createProject(String type, [Project project]) async {
    switch (type) {
      case 'Neues Projekt':
        final Project result = await Navigator.pushNamed(
          context,
          CustomRoute.createProjectPage,
        ) as Project;

        if (result != null) {
          /*_scaffoldKey.currentState.showSnackBar(
            _buildSnackBar(text: 'Neues ${result.title} hinzugefügt.'),
          );*/
          await _loadProjectList();
        }

        break;
      case 'Vorlagen':
        final bool result = await Navigator.pushNamed(
          context,
          CustomRoute.projectTemplatePage,
        ) as bool;

        if (result != null && result) {
          _scaffoldKey.currentState.showSnackBar(
            _buildSnackBar(text: 'Neues Projekt hinzugefügt.'),
          );
          await _loadProjectList();
        }

        break;
    }
  }

  void _deleteAllProjects(BuildContext context) {
    const String deleteAllProjects = 'Alle Projekte löschen?';
    const String deleteProjects = 'Projekte gelöscht.';
    const String nothingDeleted = 'Nichts gelöscht.';

    showDialog(
      context: context,
      builder: (context) => AlarmDialog(
        text: deleteAllProjects,
        icon: Icons.warning,
        onTap: () {
          if (_projects.isNotEmpty) {
            _projectDb.deleteAllProjects();
            _scaffoldKey.currentState.showSnackBar(
              _buildSnackBar(text: deleteProjects),
            );
          } else {
            _scaffoldKey.currentState.showSnackBar(
              _buildSnackBar(text: nothingDeleted),
            );
          }

          setState(() => _projects.clear());

          Navigator.pop(context);
        },
      ),
    );
  }

  void _choiceSortOption(String choice) {
    switch (choice) {
      case Constants.sortByTitleArc:
        setState(() {
          _projects.sort(
            (Project a, Project b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
          );
        });
        _setSortingOrder(Constants.sortByTitleArc);
        break;
      case Constants.sortByTitleDesc:
        setState(() {
          _projects.sort(
            (Project a, Project b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()),
          );
        });
        _setSortingOrder(Constants.sortByTitleDesc);
        break;
      case Constants.sortByReleaseDateAsc:
        setState(() {
          _projects.sort(
            (Project a, Project b) => a.createdAt.compareTo(b.createdAt),
          );
        });
        _setSortingOrder(Constants.sortByReleaseDateAsc);
        break;
      case Constants.sortByReleaseDateDesc:
        setState(() {
          _projects.sort(
            (Project a, Project b) => b.createdAt.compareTo(a.createdAt),
          );
        });
        _setSortingOrder(Constants.sortByReleaseDateDesc);
        break;
    }
  }

  Widget _buildDrawer(ThemeChangerProvider theme) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double drawerHeaderHeight = (screenHeight / 3) - kToolbarHeight - statusBarHeight;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double drawerWidth = screenWidth / 1.5;
    const String about = 'Über';
    const String impressum = 'Impressum';
    const String location = 'Dortmund';
    const String deleteAll = 'Alles löschen';
    const String appLogoPath = 'assets/app_logo.png';

    _checkIfDarkModeEnabled();

    return MainDrawer(
      drawerWidth: drawerWidth,
      location: location,
      children: <Widget>[
        Container(
          height: drawerHeaderHeight,
          child: Card(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0),
              ),
            ),
            margin: const EdgeInsets.all(0.0),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  bottom: 8.0,
                ),
                child: Row(
                  children: <Widget>[
                    Text(
                      Constants.appTitle,
                      style: TextStyle(fontSize: 24.0),
                    ),
                    const Spacer(),
                    Image(
                      image: const AssetImage(appLogoPath),
                      height: 42.0,
                      width: 42.0,
                    ),
                    const SizedBox(width: 16.0),
                  ],
                ),
              ),
            ),
          ),
        ),
        Column(
          children: <Widget>[
            const SizedBox(height: 16.0),
            _buildDrawerItem(
              context: context,
              icon: Icons.public,
              title: Constants.appTitle,
              onTap: () => _setNavigation(CustomRoute.citizenSciencePage),
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.category,
              title: Constants.onboarding,
              onTap: () => _setNavigation(CustomRoute.onboardingPage),
            ),
          ],
        ),
        const Divider(
          color: Colors.black,
          height: 0.5,
        ),
        Builder(
          builder: (BuildContext context) {
            return ExpansionTile(
              title: const Text(''),
              leading: Icon(
                Icons.settings,
                color:
                    Theme.of(context).brightness == appDarkTheme().brightness ? Colors.white : const Color(0xFF3B3B3B),
              ),
              children: <Widget>[
                _buildDrawerItem(
                  context: context,
                  icon: Icons.delete_forever,
                  title: deleteAll,
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
              title: Constants.feedback,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => const FeedbackDialog(url: Constants.fraunhoferUmsichtUrl),
                );
              },
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.info,
              //title: about,
              title: AppLocalizations.of(context).translate('about'),
              onTap: () => _launchWeb(about, Constants.fraunhoferUmsichtPrivacyStatement),
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.info_outline,
              title: impressum,
              onTap: () => _launchWeb(impressum, Constants.fraunhoferUmsichtImpressum),
            ),
          ],
        ),
        const Divider(
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
                inactiveTrackColor: const Color(0xFF191919),
                activeTrackColor: Colors.white,
                inactiveThumbColor: Colors.white,
                activeColor: const Color(0xFF191919),
                value: _valueSwitch,
                onChanged: (bool value) => _onChangedSwitch(value, theme),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32.0),
      ],
    );
  }

  Future<void> _launchWeb(String title, String url) async {
    return Navigator.pushNamed(
      context,
      CustomRoute.webPage,
      arguments: {
        argTitle: title,
        argUrl: url,
      },
    );
  }

  void _checkIfDarkModeEnabled() {
    Theme.of(context).brightness == appDarkTheme().brightness ? _valueSwitch = true : _valueSwitch = false;
  }

  void _setNavigation(String route, [Object arguments]) {
    Navigator.pushNamed(
      context,
      route,
      arguments: arguments,
    );
  }

  void _onChangedSwitch(bool value, ThemeChangerProvider themeChanger) {
    themeChanger.setTheme();
    _valueSwitch = value;
  }

  Widget _buildDrawerItem({
    @required GestureTapCallback onTap,
    BuildContext context,
    IconData icon,
    String title,
    Widget widget,
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
          child: _projects.isNotEmpty
              ? ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 88.0),
                  reverse: false,
                  itemCount: _projects.length,
                  itemBuilder: (context, index) {
                    final project = _projects[index];
                    final key = Key('${project.hashCode}');
                    return _buildDismissible(key, project, index);
                  },
                )
              : Container(),
        ),
      ),
    );
  }

  Widget _buildDismissible(Key key, Project project, int index) {
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
            Icon(Icons.arrow_forward, size: 28.0),
            const SizedBox(width: 8.0),
            Icon(Icons.delete, size: 28.0),
          ],
        ),
      ),
      onDismissed: (_) => _deleteProject(index),
      child: _buildItem(project, index),
    );
  }

  Widget _buildItem(Project project, int index) {
    final double screenHeight = MediaQuery.of(context).size.height - kToolbarHeight;

    return Container(
      height: MediaQuery.of(context).orientation == Orientation.portrait ? screenHeight / 8 : screenHeight / 4,
      child: ProjectItem(
        project: project,
        onTap: () => _navigateToEntry(index),
        onLongPress: () => _setCardColor(project),
      ),
    );
  }

  void _setCardColor(Project project) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        contentPadding: const EdgeInsets.all(0.0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        children: <Widget>[
          Scrollbar(
            child: Container(
              height: screenHeight / 2,
              width: screenWidth / 2,
              child: GridView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: AppColors.cardColors.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FloatingActionButton(
                      backgroundColor: Color(AppColors.cardColors[index].cardBackgroundColor),
                      onPressed: () {
                        _updateProject(
                          project,
                          AppColors.cardColors[index].cardBackgroundColor,
                          AppColors.cardColors[index].cardItemColor,
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

  Future<void> _updateProject(Project project, int cardColor, int cardTextColor) async {
    final Project updatedProject = Project.fromMap({
      DatabaseHelper.columnProjectId: project.id,
      DatabaseHelper.columnProjectUuid: project.uuid,
      DatabaseHelper.columnProjectTitle: project.title,
      DatabaseHelper.columnProjectDesc: project.description,
      DatabaseHelper.columnProjectCreatedAt: project.createdAt,
      DatabaseHelper.columnProjectUpdatedAt: dateFormatted(),
      DatabaseHelper.columnProjectCardColor: cardColor,
      DatabaseHelper.columnProjectCardTextColor: cardTextColor,
    });
    await _projectDb.updateProject(newProject: updatedProject);
    await _loadProjectList();
    Navigator.pop(context, updatedProject);
  }

  Future<void> _navigateToEntry(int index) async {
    final result = await Navigator.pushNamed(
      context,
      CustomRoute.projectPage,
      arguments: {
        'project': _projects[index],
        'projectTitle': _projects[index].title,
        'isFromProjectPage': true,
        'isFromProjectSearchPage': false,
      },
    );

    if (result != null && result) await _loadProjectList();
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

  Future<String> _getSortingOrder() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final order = prefs.getString(_sortOrder);
    if (order == null) {
      return Constants.sortByReleaseDateDesc;
    }
    return order;
  }

  Future<void> _setSortingOrder(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sortOrder, value);
  }

  Future<void> _loadProjectList() async {
    for (int i = 0; i < _projects.length; i++) {
      _projects.removeWhere((element) {
        _projects[i].id = _projects[i].id;
        return true;
      });
    }

    final List projects = await _projectDb.getAllProjects();

    for (int i = 0; i < projects.length; i++) {
      setState(() => _projects.insert(0, projects[i]));
    }

    _choiceSortOption(await _getSortingOrder());
  }

  void _openModalBottomSheet() {
    final List<TextTemplateItem> experimentItems = [
      TextTemplateItem('', Icons.keyboard_arrow_down),
      TextTemplateItem('Rechner', Icons.straighten),
      TextTemplateItem('Stoppuhr', Icons.timer),
      TextTemplateItem('Ortsbestimmung', Icons.location_on),
    ];

    final List<Widget> experimentItemsWidgets = [];
    for (int i = 0; i < experimentItems.length; i++) {
      i == 0
          ? experimentItemsWidgets.add(_createTile(experimentItems[i], true))
          : experimentItemsWidgets.add(_createTile(experimentItems[i], false));
    }

    _buildMainBottomSheet(experimentItemsWidgets);
  }

  void _buildMainBottomSheet(List<Widget> experimentItemsWidgets) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView(
          shrinkWrap: true,
          children: experimentItemsWidgets,
        );
      },
    );
  }

  Widget _createTile(TextTemplateItem experimentItem, bool centerIcon) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double tileHeight = screenHeight / 12;

    return Material(
      child: InkWell(
        onTap: () {
          if (experimentItem.name.isEmpty) {
            Navigator.pop(context);
          } else if (experimentItem.name == 'Rechner') {
            Navigator.popAndPushNamed(context, CustomRoute.calculatorPage);
          } else if (experimentItem.name == 'Stoppuhr') {
            Navigator.popAndPushNamed(context, CustomRoute.stopwatchPage);
          } else if (experimentItem.name == 'Ortsbestimmung') {
            Navigator.popAndPushNamed(context, CustomRoute.locationPage);
          }
        },
        child: Container(
          height: tileHeight,
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: (!centerIcon)
                      ? Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                experimentItem.name,
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ),
                            Expanded(
                              child: Icon(experimentItem.icon, size: 24.0),
                            ),
                          ],
                        )
                      : Center(
                          child: Icon(experimentItem.icon, size: 24.0),
                        ),
                ),
              ),
              const Divider(height: 1.0, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteProject(int index) async {
    await _projectDb.deleteProject(id: _projects[index].id);

    _scaffoldKey.currentState.showSnackBar(
      _buildSnackBar(text: 'Projekt ${_projects[index].title} gelöscht.'),
    );

    if (_projects.contains(_projects[index])) {
      setState(() => _projects.removeAt(index));
    }
  }
}
