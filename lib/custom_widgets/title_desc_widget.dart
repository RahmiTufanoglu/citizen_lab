import 'dart:async';

import 'package:citizen_lab/bloc/custom_expansion_tile.dart';
import 'package:citizen_lab/database/database_provider.dart';
import 'package:citizen_lab/entries/note.dart';
import 'package:citizen_lab/projects/project.dart';
import 'package:citizen_lab/themes/theme.dart';
import 'package:citizen_lab/utils/date_formatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../title_change_provider.dart';

class TitleDescWidget extends StatefulWidget {
  final uuid;
  final titleBloc;
  final TitleChangerProvider titleChanger;
  final String title;
  final String createdAt;
  final titleEditingController;
  final descEditingController;
  final Function onWillPop;
  final DatabaseHelper db;

  const TitleDescWidget({
    @required this.uuid,
    @required this.titleBloc,
    @required this.titleChanger,
    @required this.title,
    @required this.createdAt,
    @required this.titleEditingController,
    @required this.descEditingController,
    @required this.onWillPop,
    @required this.db,
  })  : assert(titleBloc != null),
        assert(createdAt != null),
        assert(titleEditingController != null),
        assert(descEditingController != null),
        assert(onWillPop != null);

  @override
  _TitleDescWidgetState createState() => _TitleDescWidgetState();
}

class _TitleDescWidgetState extends State<TitleDescWidget> {
  List<Note> noteList = [];
  List<Project> projectList = [];
  String noteTitle = '';
  String noteDesc = '';
  String projectTitle = '';
  String projectDesc = '';
  Timer _timer;
  String _timeString;

  @override
  void initState() {
    _timeString = dateFormatted();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _getTime());

    _getProjectsFromDb();
    _getNotesFromDb();

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
  Widget build(BuildContext context) {
    return _buildWidget();
  }

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
              margin: const EdgeInsets.fromLTRB(
                16.0,
                8.0,
                16.0,
                0.0,
              ),
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
              margin: const EdgeInsets.fromLTRB(
                16.0,
                8.0,
                16.0,
                0.0,
              ),
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
            /*Card(
              margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
              color: _checkIfDarkModeEnabled() ? Colors.black12 : Colors.white,
              child: CustomExpansionTile(
                title: Text(''),
                leading: Padding(
                  padding: EdgeInsets.only(left: (screenWith / 2) - 80.0),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.description),
                      SizedBox(width: 8.0),
                      Icon(Icons.compare_arrows),
                      SizedBox(width: 8.0),
                      Icon(Icons.description),
                    ],
                  ),
                ),
                children: <Widget>[
                  _getComparisonWidget(),
                ],
              ),
            ),*/
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
          margin: const EdgeInsets.fromLTRB(
            16.0,
            16.0,
            16.0,
            8.0,
          ),
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
                StreamBuilder(
                  stream: widget.titleBloc.title,
                  builder: (BuildContext context, AsyncSnapshot snapshot) =>
                      _buildTextField(
                    controller: widget.titleEditingController,
                    maxLength: 100,
                    maxLines: 1,
                    hintText: titleHere,
                    onChanged: widget.titleBloc.changeTitle,
                    snapshot: snapshot,
                  ),
                ),
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
                  onChanged: null,
                  snapshot: null,
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
                noteTitle = note.title;
                noteDesc = note.description;
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
            noteTitle,
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
            noteDesc,
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

  TextField _buildTextField({
    @required TextEditingController controller,
    @required int maxLines,
    @required int maxLength,
    @required String hintText,
    @required ValueChanged<String> onChanged,
    @required AsyncSnapshot snapshot,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.text,
      maxLines: maxLines,
      maxLength: maxLength,
      style: TextStyle(fontSize: 16.0),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: '...',
        errorText: (snapshot != null) ? snapshot.error : '',
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
