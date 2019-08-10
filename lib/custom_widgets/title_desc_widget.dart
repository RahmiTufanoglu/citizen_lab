import 'dart:async';

import 'package:citizen_lab/bloc/custom_expansion_tile.dart';
import 'package:citizen_lab/database/database_helper.dart';
import 'package:citizen_lab/entries/note.dart';
import 'package:citizen_lab/projects/project.dart';
import 'package:citizen_lab/themes/theme.dart';
import 'package:citizen_lab/utils/date_formatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TitleDescWidget extends StatefulWidget {
  final String uuid;
  final String title;
  final String createdAt;
  final TextEditingController titleEditingController;
  final TextEditingController descEditingController;
  final Function onWillPop;
  final DatabaseHelper db;

  const TitleDescWidget({
    @required this.uuid,
    @required this.title,
    @required this.createdAt,
    @required this.titleEditingController,
    @required this.descEditingController,
    @required this.onWillPop,
    @required this.db,
  })  : assert(createdAt != null),
        assert(titleEditingController != null),
        assert(descEditingController != null),
        assert(onWillPop != null);

  @override
  _TitleDescWidgetState createState() => _TitleDescWidgetState();
}

class _TitleDescWidgetState extends State<TitleDescWidget> {
  final _titleEditingController = TextEditingController();
  List<Note> noteList = [];
  List<Project> projectList = [];
  String _noteTitle = '';
  String _noteDesc = '';
  String _projectTitle = '';
  Timer _timer;
  String _timeString;

  @override
  void initState() {
    _timeString = dateFormatted();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _getTime());

    _getProjectsFromDb();
    _getNotesFromDb();

    _titleEditingController.addListener(() {
      setState(() => _projectTitle = _titleEditingController.text);
    });

    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _getTime() {
    final String formattedDateTime = dateFormatted();
    setState(() => _timeString = formattedDateTime);
  }

  @override
  Widget build(BuildContext context) => _buildWidget();

  bool _checkIfDarkModeEnabled() {
    final ThemeData theme = Theme.of(context);
    return theme.brightness == appDarkTheme().brightness ? true : false;
  }

  Widget _buildWidget() {
    final double screenWith = MediaQuery.of(context).size.width;

    return SafeArea(
      child: WillPopScope(
        onWillPop: () => widget.onWillPop(),
        child: ListView(
          padding: const EdgeInsets.only(top: 8.0, bottom: 88.0),
          children: <Widget>[
            Card(
              margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
              color: _checkIfDarkModeEnabled() ? Colors.black12 : Colors.white,
              child: CustomExpansionTile(
                title: const Text(''),
                leading: Padding(
                  padding: EdgeInsets.only(left: (screenWith / 2) - 40.0),
                  child: Icon(Icons.access_time),
                ),
                children: <Widget>[_getTimeWidget()],
              ),
            ),
            _getTextWidget(),
            Card(
              margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
              color: _checkIfDarkModeEnabled() ? Colors.black12 : Colors.white,
              child: CustomExpansionTile(
                title: const Text(''),
                leading: Padding(
                  padding: EdgeInsets.only(left: (screenWith / 2) - 40.0),
                  child: const Icon(
                    IconData(
                      0xe92d,
                      fontFamily: 'comparison',
                    ),
                  ),
                ),
                children: <Widget>[_getComparisonWidget()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getTimeWidget() {
    const created = 'Erstellt am';
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: ShapeDecoration(
        shape: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          borderSide: BorderSide(
            color: Colors.grey,
            width: 2.0,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              _timeString,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              '$created: ${widget.createdAt}',
              style: TextStyle(
                fontSize: 14.0,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getTextWidget() {
    const String titleHere = 'Titel hier';
    const String contentHere = 'Inhalt hier';
    return Column(
      children: <Widget>[
        Card(
          margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
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
                _buildTextField(
                    controller: widget.titleEditingController,
                    maxLength: 100,
                    maxLines: 1,
                    hintText: titleHere,
                    errorText: 'Bitte einen Titel eingeben'),
                const Divider(color: Colors.black),
                Text(
                  'Beschreibung:',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                _buildTextField(
                  controller: widget.descEditingController,
                  maxLength: 500,
                  maxLines: 10,
                  hintText: contentHere,
                  errorText: 'Bitte eine Beschreiung eingeben',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _getComparisonWidget() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          DropdownButton<Project>(
            items: projectList
                .map((project) => DropdownMenuItem(
                      value: project,
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        width: double.infinity,
                        child: Text(
                          project.title,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ))
                .toList(),
            onChanged: (Project project) {
              setState(() {
                //projectTitle = project.title;
                //projectDesc = project.description;
              });
            },
            isExpanded: true,
            hint: Text(
              'Projekt auswählen.',
              style: TextStyle(
                color: _checkIfDarkModeEnabled() ? Colors.white : Colors.black,
              ),
            ),
          ),
          //
          DropdownButton<Note>(
            items: noteList
                .map((note) => DropdownMenuItem(
                      value: note,
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        width: double.infinity,
                        child: Text(
                          note.title,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ))
                .toList(),
            onChanged: (Note note) {
              setState(() {
                _noteTitle = note.title;
                _noteDesc = note.description;
              });
            },
            isExpanded: true,
            hint: Text(
              'Notiz zum Vergleich abrufen.',
              style: TextStyle(
                color: _checkIfDarkModeEnabled() ? Colors.white : Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          Text(
            'Titel:',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            _noteTitle,
            style: TextStyle(fontSize: 16.0),
          ),
          const SizedBox(height: 24.0),
          Text(
            'Beschreibung:',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            _noteDesc,
            style: TextStyle(fontSize: 16.0),
          ),
        ],
      ),
    );
  }

  Future<void> _getProjectsFromDb() async {
    projectList = await widget.db.getAllProjects();

    for (int i = 0; i < projectList.length; i++) {
      print('$i: ${projectList[i].title}');
    }
  }

  Future<void> _getNotesFromDb() async {
    noteList = await widget.db.getNotesOfProject(uuid: widget.uuid);

    for (int i = 0; i < noteList.length; i++) {
      print('$i: ${noteList[i].title}');
    }
  }

  Widget _buildTextField({
    @required TextEditingController controller,
    @required int maxLines,
    @required int maxLength,
    @required String hintText,
    @required String errorText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.text,
      maxLines: maxLines,
      maxLength: maxLength,
      style: TextStyle(fontSize: 16.0),
      decoration: InputDecoration(
        hintText: '...',
        errorText: controller.text.isEmpty ? errorText : null,
        focusedErrorBorder: _buildUnderlineInputBorder(),
        errorBorder: _buildUnderlineInputBorder(),
        enabledBorder: _buildUnderlineInputBorder(),
        focusedBorder: _buildUnderlineInputBorder(),
      ),
    );
  }

  UnderlineInputBorder _buildUnderlineInputBorder() =>
      UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent));
}
