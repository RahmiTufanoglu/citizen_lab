import 'dart:ui';

import 'package:citizen_lab/app_locations.dart';
import 'package:citizen_lab/database/database_helper.dart';
import 'package:citizen_lab/projects/project.dart';
import 'package:citizen_lab/themes/theme_changer_provider.dart';
import 'package:citizen_lab/utils/constants.dart';
import 'package:citizen_lab/utils/date_formatter.dart';
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
  final _projectDb = DatabaseHelper.db;
  final List<Project> _projectList = [];

  Color _buttonColor = Colors.white;
  Color _iconColor = Colors.black;

  _CreateProjectPageState() {
    _titleEditingController.addListener(() => _checkTextsAreNotEmpty());
    _descEditingController.addListener(() => _checkTextsAreNotEmpty());
  }

  void _checkTextsAreNotEmpty() {
    setState(() {
      if (_titleEditingController.text.isNotEmpty && _descEditingController.text.isNotEmpty) {
        _buttonColor = Colors.green;
        _iconColor = Colors.white;
      } else {
        _buttonColor = Colors.white;
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
    final List projects = await _projectDb.getAllProjects();

    /*for (final project in projects) {
      project.forEach();
      _projectList.add(project);
    }*/

    projects.forEach((project) {
      //_projectList.add(Project.map(project));
      _projectList.add(project);
    });
  }

  @override
  void dispose() {
    _titleEditingController.dispose();
    _descEditingController.dispose();
    super.dispose();
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
    const String back = 'Zurück';
    const String createExperiment = 'Experiment erstellen';

    return AppBar(
      leading: IconButton(
        tooltip: back,
        icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: Consumer<ThemeChangerProvider>(
        builder: (
          BuildContext context,
          ThemeChangerProvider provider,
          Widget child,
        ) {
          return GestureDetector(
            onPanStart: (_) => provider.setTheme(),
            child: Container(
              width: double.infinity,
              child: Tooltip(
                message: AppLocalizations.of(context).translate('createProject'),
                child: const Text(createExperiment),
              ),
            ),
          );
        },
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
    Navigator.pushNamed(context, CustomRoute.aboutPage, arguments: {
      'title': 'Das Labornotizbuch',
      'content': Constants.labNotebook,
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
                  const SizedBox(height: 8.0),
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
                    validator: (text) => text.isEmpty ? 'Bitte einen Titel eingeben' : null,
                  ),
                  const Divider(color: Colors.black),
                  const SizedBox(height: 8.0),
                  Text(
                    'Beschreibung:',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
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
                    validator: (text) => text.isEmpty ? AppLocalizations.of(context).translate('enterADesc') : null,
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
            onPressed: () {
              _titleEditingController.clear();
              _descEditingController.clear();
            },
            child: Icon(Icons.remove),
          ),
          AnimatedContainer(
            curve: const ElasticOutCurve(),
            //height: _fabHeight,
            height: 56.0,
            //width: _fabWidth,
            width: 56.0,
            duration: const Duration(seconds: 1),
            child: FloatingActionButton(
              heroTag: null,
              backgroundColor: _buttonColor,
              /*child: FlareActor(
                'assets/ok.flr',
                fit: BoxFit.fill,
                animation: _animationChecked,
              ),*/
              onPressed: () {
                if (_titleEditingController.text.isNotEmpty && _descEditingController.text.isNotEmpty) {
                  _createProject(context);
                }
              },
              child: Icon(
                Icons.check,
                //size: _iconSize,
                color: _iconColor,
              ),
            ),
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
          _buildSnackBar('${AppLocalizations.of(context).translate('chooseAnotherTitle')}.'),
        );
        break;
      }
    }

    String randomUuid = generateRandomUuid();

    for (int i = 0; i < _projectList.length; i++) {
      while (_projectList[i].uuid == randomUuid) {
        randomUuid = generateRandomUuid();
      }
    }

    final Project project = Project(
      _titleEditingController.text,
      randomUuid,
      _descEditingController.text,
      dateFormatted(),
      dateFormatted(),
      0xFFFFFFFF,
      0xFF000000,
    );

    if (_formKey.currentState.validate() && !_projectExists) {
      await _projectDb.insertProject(project: project);
      Navigator.pop(context, project);
    }
  }

  Widget _buildSnackBar(String text) {
    return SnackBar(
      backgroundColor: Colors.black87,
      duration: const Duration(milliseconds: 500),
      content: Text(
        text,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
