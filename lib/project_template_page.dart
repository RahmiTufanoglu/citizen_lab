import 'package:citizen_lab/projects/project.dart';
import 'package:citizen_lab/utils/constants.dart';
import 'package:citizen_lab/utils/date_formatter.dart';
import 'package:citizen_lab/utils/utils.dart';
import 'package:flutter/material.dart';

import 'database/database_provider.dart';
import 'entries/note.dart';

class ProjectTemplatePage extends StatefulWidget {
  @override
  _ProjectTemplatePageState createState() => _ProjectTemplatePageState();
}

class _ProjectTemplatePageState extends State<ProjectTemplatePage> {
  final _projectDb = DatabaseHelper.db;
  final List<String> _templateList = ['A', 'B', 'C', 'D', 'E'];
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
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
                  child: Text('$loremShorter'),
                ),
              ),
              IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    _createTemplateContent(
                      'Vorlage ${index + 1}',
                      'Vorlage Beschreibung ${index + 1}',
                    );
                    _scaffoldKey.currentState.showSnackBar(
                      _buildSnackBar(text: 'Vorlage ${index + 1} hinzugefügt.'),
                    );
                  }),
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

  Future<void> _createTemplateContent(String title, String desc) async {
    final Project project = Project(
      title,
      //Utils.getRandomNumber(),
      Utils.generateRandomUuid(),
      desc,
      dateFormatted(),
      '',
      0xFFFFFFFF,
      0xFF000000,
    );
    await _projectDb.insertProject(project: project);

    final Note note = Note(
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

    if (project != null) {
      await _projectDb.insertNote(note: note);
    }
  }

  //Future<bool> _onWillPop() async => true;

  Future<void> _onBackPressed() async => Navigator.pop(context, true);
}
