import 'dart:ui';

import 'package:citizen_lab/database/database_provider.dart';
import 'package:citizen_lab/projects/project.dart';
import 'package:citizen_lab/themes/theme_changer_provider.dart';
import 'package:citizen_lab/utils/constants.dart';
import 'package:citizen_lab/utils/date_formater.dart';
import 'package:citizen_lab/utils/route_generator.dart';
import 'package:citizen_lab/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class CreateProjectPage extends StatefulWidget {
  @override
  _CreateProjectPageState createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<CreateProjectPage> {
  final _snackBarKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _titleEditingController = TextEditingController();
  final _descEditingController = TextEditingController();
  final _projectDb = DatabaseProvider.db;

  ThemeChangerProvider _themeChanger;
  List<Project> _projectList = [];

  Color _buttonColor = Colors.white;

  //double _fabHeight = 16.0;
  //double _fabWidth = 16.0;
  double _iconSize = 0.0;

  IconData _fabIcon = Icons.close;
  Color _iconColor = Colors.black;

  //String _animationChecked = '';

  _CreateProjectPageState() {
    _titleEditingController.addListener(() => _checkTextsAreNotEmpty());
    _descEditingController.addListener(() => _checkTextsAreNotEmpty());
  }

  void _checkTextsAreNotEmpty() {
    setState(() {
      if (_titleEditingController.text.isNotEmpty &&
          _descEditingController.text.isNotEmpty) {
        //_fabHeight = 56.0;
        //_fabWidth = 56.0;
        //_iconSize = 24.0;
        _buttonColor = Colors.green;
        //_animationChecked = 'ok';
        _iconColor = Colors.white;
      } else {
        //_fabHeight = 16.0;
        //_fabWidth = 16.0;
        //_iconSize = 0.0;
        _buttonColor = Colors.white;
        //_animationChecked = '';
        _iconColor = Colors.black;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadProjectList();
  }

  Future<void> _loadProjectList() async {
    List projects = await _projectDb.getAllProjects();
    projects.forEach((project) {
      _projectList.add(Project.map(project));
    });
  }

  @override
  void dispose() {
    super.dispose();
    _titleEditingController.dispose();
    _descEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _snackBarKey,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFabs(),
    );
  }

  Widget _buildAppBar() {
    _themeChanger = Provider.of<ThemeChangerProvider>(context);
    return AppBar(
      leading: IconButton(
        tooltip: 'Zurück',
        icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: GestureDetector(
        onPanStart: (_) => _themeChanger.setTheme(),
        child: Container(
          width: double.infinity,
          child: Tooltip(
            message: create_project,
            child: Text('Experiment erstellen'),
          ),
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.info_outline),
          onPressed: () => _setInfoPage(),
        ),
      ],
    );
  }

  void _setInfoPage() {
    /*Navigator.pushNamed(
      context,
      RouteGenerator.infoPage,
      arguments: {
        'title': 'Text-Info',
        'tabLength': 1,
        'tabs': createProjectTabList,
        'tabChildren': createProjectSingleChildScrollViewList,
      },
    );*/
    Navigator.pushNamed(context, RouteGenerator.aboutPage, arguments: {
      'title': 'Das Labornotizbuch',
      'content': lab_notebook,
    });
  }

  Widget _buildBody() {
    return SafeArea(
      child: Form(
        key: _formKey,
        autovalidate: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Titel:',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  TextFormField(
                    controller: _titleEditingController,
                    keyboardType: TextInputType.text,
                    maxLength: 50,
                    maxLines: 1,
                    decoration: InputDecoration.collapsed(
                      //hintText: '$title_here.',
                      hintText: '...',
                      hasFloatingPlaceholder: true,
                    ),
                    /*buildCounter: (
                      BuildContext context, {
                      int currentLength,
                      int maxLength,
                      bool isFocused,
                    }) {
                      return null;
                    },*/
                    validator: (text) =>
                        text.isEmpty ? 'Bitte einen Titel eingeben' : null,
                  ),
                  Divider(color: Colors.black),
                  SizedBox(height: 8.0),
                  Text(
                    'Beschreibung:',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  TextFormField(
                    controller: _descEditingController,
                    keyboardType: TextInputType.text,
                    maxLength: 250,
                    maxLines: 10,
                    decoration: InputDecoration.collapsed(
                      //hintText: '$desc_here.',
                      hintText: '...',
                    ),
                    /*buildCounter: (
                      BuildContext context, {
                      int currentLength,
                      int maxLength,
                      bool isFocused,
                    }) {
                      return null;
                    },*/
                    validator: (text) => text.isEmpty ? enter_a_desc : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFabs() {
    return Padding(
      padding: const EdgeInsets.only(left: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FloatingActionButton(
            heroTag: null,
            child: Icon(Icons.remove),
            onPressed: () {
              _titleEditingController.clear();
              _descEditingController.clear();
            },
          ),
          AnimatedContainer(
            curve: ElasticOutCurve(),
            //height: _fabHeight,
            height: 56.0,
            //width: _fabWidth,
            width: 56.0,
            duration: Duration(seconds: 1),
            child: FloatingActionButton(
                heroTag: null,
                backgroundColor: _buttonColor,
                child: Icon(
                  Icons.check,
                  //size: _iconSize,
                  color: _iconColor,
                ),
                /*child: FlareActor(
                'assets/ok.flr',
                fit: BoxFit.fill,
                animation: _animationChecked,
              ),*/
                onPressed: () {
                  if (_titleEditingController.text.isNotEmpty &&
                      _descEditingController.text.isNotEmpty) {
                    _createProject(context);
                  }
                }),
          ),
        ],
      ),
    );
  }

  Future<void> _createProject(BuildContext context) async {
    bool _projectExists = false;
    for (int i = 0; i < _projectList.length; i++) {
      if (_projectList[i].title == _titleEditingController.text) {
        _projectExists = true;
        _snackBarKey.currentState.showSnackBar(
          _buildSnackBar('$choose_another_title.'),
        );
        break;
      }
    }

    Project project = Project(
      _titleEditingController.text,
      Utils.getRandomNumber(),
      _descEditingController.text,
      dateFormatted(),
      '',
    );

    if (_formKey.currentState.validate() && !_projectExists) {
      await _projectDb.insertProject(project: project);
      // TODO: WORKAROUND
      //_navigateToEntry(project);
      return Navigator.pushNamed(
        context,
        RouteGenerator.projectPage,
        arguments: {
          'isFromCreateProjectPage': true,
        },
      );
    }
  }

  void _navigateToEntry(Project project) {
    Navigator.pushNamed(
      context,
      RouteGenerator.entry,
      arguments: {
        'project': project,
        'projectTitle': project.title,
        'isFromCreateProjectPage': true,
        'isFromProjectPage': false,
        'isFromProjectSearchPage': false,
      },
    );
  }

  Widget _buildSnackBar(String text) {
    return SnackBar(
      backgroundColor: Colors.black87,
      duration: Duration(milliseconds: 500),
      content: Text(
        text,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
