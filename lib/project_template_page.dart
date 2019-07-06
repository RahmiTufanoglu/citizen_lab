import 'package:citizen_lab/projects/project.dart';
import 'package:citizen_lab/utils/date_formater.dart';
import 'package:citizen_lab/utils/utils.dart';
import 'package:flutter/material.dart';

import 'database/database_provider.dart';
import 'entries/note.dart';

class ProjectTemplatePage extends StatelessWidget {
  final _projectDb = DatabaseProvider.db;
  final List<String> _templateList = ['A', 'B', 'C', 'D', 'E'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('Projekt Vorlagen'),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context, true),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return WillPopScope(
      onWillPop: () {},
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
                  child: Text('...'),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => _createTemplateContent(
                      'Vorlage ${index + 1}',
                      'Vorlage Beschreibung ${index + 1}',
                    ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _createTemplateContent(String title, String desc) async {
    Project project = Project(
      title,
      Utils.getRandomNumber(),
      desc,
      dateFormatted(),
      '',
    );
    await _projectDb.insertProject(project: project);

    Note note = Note(
      project.random,
      'Text',
      'sdasadasd',
      'dfdsfdsgfdgfdgmf',
      '',
      dateFormatted(),
      dateFormatted(),
      0,
    );

    if (project != null) {
      _projectDb.insertNote(note: note);
    }
  }
}
