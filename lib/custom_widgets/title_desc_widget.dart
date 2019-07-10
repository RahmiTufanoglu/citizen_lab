import 'dart:async';

import 'package:citizen_lab/database/database_provider.dart';
import 'package:citizen_lab/entries/note.dart';
import 'package:citizen_lab/themes/theme.dart';
import 'package:citizen_lab/utils/date_formater.dart';
import 'package:flutter/material.dart';

import '../title_change_provider.dart';

class TitleDescWidget extends StatefulWidget {
  final titleBloc;
  final TitleChangerProvider titleChanger;
  final String title;
  final String createdAt;
  final titleEditingController;
  final descEditingController;
  final Function onWillPop;
  final DatabaseProvider db;

  TitleDescWidget({
    @required this.titleBloc,
    @required this.titleChanger,
    @required this.title,
    @required this.createdAt,
    @required this.titleEditingController,
    @required this.descEditingController,
    @required this.onWillPop,
    @required this.db,
  });

  @override
  _TitleDescWidgetState createState() => _TitleDescWidgetState();
}

class _TitleDescWidgetState extends State<TitleDescWidget> {
  List<Note> notelist = [];
  String noteTitle = '';
  String noteDesc = '';
  Timer _timer;
  String _timeString;

  @override
  void initState() {
    _timeString = dateFormatted();
    _timer = Timer.periodic(Duration(seconds: 1), (_) => _getTime());

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
    setState(() {
      _timeString = formattedDateTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildWidget();
  }

  bool _checkIfDarkModeEnabled() {
    final ThemeData theme = Theme.of(context);
    if (theme.brightness == appDarkTheme().brightness) {
      return true;
    } else {
      return false;
    }
  }

  Widget _buildWidget() {
    final title = 'Titel';
    final titleHere = 'Titel hier';
    final content = 'Inhalt';
    final contentHere = 'Inhalt hier';
    final String plsEnterATitle = 'Bitte einen Titel eingeben';
    String pageTitle = widget.title;

    final double screenWith = MediaQuery.of(context).size.width;

    return SafeArea(
      child: WillPopScope(
        onWillPop: () => widget.onWillPop(),
        child: ListView(
          padding: EdgeInsets.only(top: 8.0, bottom: 88.0),
          children: <Widget>[
            Container(
              color: _checkIfDarkModeEnabled() ? Colors.black12 : Colors.white,
              child: ExpansionTile(
                title: Text(''),
                leading: Padding(
                  padding: EdgeInsets.only(left: (screenWith / 2) - 24.0),
                  child: Icon(Icons.access_time),
                ),
                children: <Widget>[_topWidget()],
              ),
            ),
            _bottomWidget(),
          ],
        ),
      ),
    );
  }

  Widget _topWidget() {
    final created = 'Erstellt am';
    return Container(
      margin: EdgeInsets.all(16.0),
      decoration: ShapeDecoration(
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
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
            SizedBox(height: 8.0),
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

  Widget _bottomWidget() {
    final String titleHere = 'Titel hier';
    final String contentHere = 'Inhalt hier';
    return Column(
      children: <Widget>[
        Card(
          margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
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
                Divider(color: Colors.black),
                Text(
                  'Beschreibung:',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
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
        Container(
          width: double.infinity,
          child: Card(
            margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  DropdownButton<Note>(
                    items: notelist
                        .map((note) => DropdownMenuItem(
                              child: Container(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      width: 1.0,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  note.title,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              value: note,
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
                        color: _checkIfDarkModeEnabled()
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    'Titel:',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    noteTitle,
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 24.0),
                  Text(
                    'Beschreibung:',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    noteDesc,
                    style: TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _getNotesFromDb() async {
    notelist = await widget.db.getAllNotes();

    for (int i = 0; i < notelist.length; i++) {
      print('$i: ${notelist[i].title}');
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
