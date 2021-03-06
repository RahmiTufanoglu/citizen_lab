import 'package:citizen_lab/projects/project.dart';
import 'package:citizen_lab/utils/date_formatter.dart';
import 'package:citizen_lab/utils/utils.dart';
import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../notes/note.dart';

class ProjectTemplatePage extends StatefulWidget {
  @override
  _ProjectTemplatePageState createState() => _ProjectTemplatePageState();
}

class _ProjectTemplatePageState extends State<ProjectTemplatePage> {
  final _projectDb = DatabaseHelper.db;
  final _templateList = ['A', 'B', 'C', 'D'];
  final _contentList = [
    '3x Text',
    '5x Text',
    '10x Text',
    '15x Text',
  ];
  final _textCounts = [3, 5, 10, 15];
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _projectList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
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
      _projectList.add(project);
    });
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Projekt Vorlagen'),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context, true),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onBackPressed(),
      child: ListView.builder(
        itemCount: _templateList.length,
        itemBuilder: (context, index) {
          return ExpansionTile(
            title: Text('Vorlage ${index + 1}'),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(_contentList[index]),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  _createTemplateContent(
                    'Vorlage ${index + 1}',
                    'Vorlage Beschreibung ${index + 1}',
                    _textCounts[index],
                  );
                  _scaffoldKey.currentState.showSnackBar(
                    _buildSnackBar(text: 'Vorlage ${index + 1} hinzugefügt.'),
                  );
                },
              ),
            ],
          );
        },
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

  Future<void> _createTemplateContent(String title, String desc, int textCount) async {
    String randomUuid = generateRandomUuid();

    for (int i = 0; i < _projectList.length; i++) {
      while (_projectList[i].uuid == randomUuid) {
        randomUuid = generateRandomUuid();
      }
    }

    final project = Project(
      title,
      randomUuid,
      desc,
      dateFormatted(),
      '',
      0xFFFFFFFF,
      0xFF000000,
    );
    await _projectDb.insertProject(project: project);

    final note = Note(
      project.uuid,
      'Text',
      'Vorlage Titel',
      'Vorlage Beschreibung',
      '',
      dateFormatted(),
      dateFormatted(),
      0,
      0,
      0xFFFFFFFF,
      0xFF000000,
    );

    for (int i = 0; i < textCount; i++) {
      if (project != null) {
        await _projectDb.insertNote(note: note);
      }
    }
  }

  Future<void> _onBackPressed() async => Navigator.pop(context, true);
}
