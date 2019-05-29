import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:citizen_lab/utils/date_formater.dart';
import 'package:citizen_lab/projects/project.dart';
import 'package:citizen_lab/database/project_database_provider.dart';
import 'package:citizen_lab/utils/route_generator.dart';

import 'package:citizen_lab/utils/constants.dart';

class CreateProjectPage extends StatefulWidget {
  @override
  _CreateProjectPageState createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<CreateProjectPage> {
  final _snackBarKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _titleEditingController = TextEditingController();
  final _descEditingController = TextEditingController();
  final _projectDb = ProjectDatabaseProvider();

  List<Project> _projectList = [];

  Color _buttonColor = Colors.white.withOpacity(0.8);
  Color _buttonIconColor = Colors.black;

  _CreateProjectPageState() {
    _titleEditingController.addListener(() => _checkTextsAreNotEmpty());
    _descEditingController.addListener(() => _checkTextsAreNotEmpty());
  }

  _checkTextsAreNotEmpty() {
    setState(() {
      if (_titleEditingController.text.isNotEmpty &&
          _descEditingController.text.isNotEmpty) {
        _buttonColor = Colors.green;
        _buttonIconColor = Colors.white;
      } else {
        _buttonColor = Colors.white;
        _buttonIconColor = Colors.black;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadProjectList();
  }

  _loadProjectList() async {
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
      body: _buildBody(context),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        tooltip: 'Zurück',
        icon: Icon(
          Icons.arrow_back,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        create_project,
      ),
      elevation: 4.0,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.info_outline),
          onPressed: () {
            //TODO: INFO
          },
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return Form(
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
                  '$title:',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextFormField(
                  controller: _titleEditingController,
                  keyboardType: TextInputType.text,
                  maxLength: 50,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: '$title_here.',
                    labelStyle: TextStyle(fontSize: 18.0),
                  ),
                  validator: (text) {
                    return text.isEmpty ? 'Bitte einen Titel eingeben' : null;
                  },
                ),
                SizedBox(height: 42.0),
                Text(
                  '$desc:',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextFormField(
                  controller: _descEditingController,
                  keyboardType: TextInputType.text,
                  maxLength: 500,
                  maxLines: 10,
                  validator: (text) {
                    return text.isEmpty ? enter_a_desc : null;
                  },
                  decoration: InputDecoration(hintText: '$desc_here.'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFab() {
    return AnimatedContainer(
      duration: Duration(seconds: 1),
      child: FloatingActionButton(
        backgroundColor: _buttonColor,
        child: Icon(
          Icons.check,
          color: _buttonIconColor,
        ),
        onPressed: () => _createProject(context),
      ),
    );
  }

  void _createProject(BuildContext context) async {
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
      _descEditingController.text,
      dateFormatted(),
      dateFormatted(),
    );

    if (_formKey.currentState.validate() && !_projectExists) {
      await _projectDb.insertProject(project: project);
      Navigator.pushNamed(
        context,
        RouteGenerator.entry,
        arguments: {
          'project': project,
          'projectTitle': _titleEditingController.text,
          'isFromCreateProjectPage': true,
          'isFromProjectPage': false,
        },
      );
    }
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
