import 'dart:io';

import 'package:citizen_lab/custom_widgets/simple_timer_dialog.dart';
import 'package:citizen_lab/themes/theme.dart';
import 'package:citizen_lab/themes/theme_changer.dart';
import 'package:flutter/material.dart';
import 'package:citizen_lab/custom_widgets/alarm_dialog.dart';
import 'package:citizen_lab/utils/constants.dart';
import 'package:citizen_lab/entries/note.dart';
import 'package:citizen_lab/utils/date_formater.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:citizen_lab/projects/project.dart';
import 'package:citizen_lab/database/project_database_provider.dart';
import 'package:citizen_lab/utils/route_generator.dart';
import 'package:provider/provider.dart';

import 'package:citizen_lab/custom_widgets/card_item.dart';
import 'package:citizen_lab/custom_widgets/no_yes_dialog.dart';

class EntryPage extends StatefulWidget {
  final Key key;
  final bool isFromCreateProjectPage;
  final bool isFromProjectPage;
  final String projectTitle;
  final Project project;
  final Note note;

  EntryPage({
    this.key,
    @required this.isFromCreateProjectPage,
    @required this.isFromProjectPage,
    @required this.projectTitle,
    @required this.project,
    this.note,
  }) : super(key: key);

  @override
  _EntryPageState createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _titleProjectController = TextEditingController();
  final _descProjectController = TextEditingController();
  final _textEditingController = TextEditingController();
  final _projectDb = ProjectDatabaseProvider();
  final _noteDb = ProjectDatabaseProvider();

  ThemeChanger _themeChanger;
  List<Note> _noteList = [];
  bool _listLoaded = false;
  String _title;
  String _createdAt;
  bool _darkModeEnabled = false;

  @override
  void initState() {
    if (!_listLoaded) {
      _loadNoteList();
      _listLoaded = true;
    }

    _titleProjectController.text = widget.project.title;
    _descProjectController.text = widget.project.description;
    _title = widget.projectTitle;
    _createdAt = widget.project.dateCreated;

    _titleProjectController.addListener(() {
      setState(() {
        _title = _titleProjectController.text;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
  }

  void _checkIfDarkModeEnabled() {
    final ThemeData theme = Theme.of(context);
    theme.brightness == appDarkTheme().brightness
        ? _darkModeEnabled = true
        : _darkModeEnabled = false;
  }

  @override
  Widget build(BuildContext context) {
    _themeChanger = Provider.of<ThemeChanger>(context);

    _checkIfDarkModeEnabled();

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFabs(),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        tooltip: back,
        icon: Icon(Icons.arrow_back),
        onPressed: () => _onBackPressed(),
      ),
      title: Text(_title),
      elevation: 4.0,
      actions: <Widget>[
        PopupMenuButton(
          icon: Icon(Icons.sort),
          elevation: 2.0,
          tooltip: sort_options,
          onSelected: _choiceSortOption,
          itemBuilder: (BuildContext context) {
            return choices.map(
              (String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              },
            ).toList();
          },
        ),
        Builder(
          builder: (contextSnackBar) => IconButton(
                highlightColor: Colors.red.withOpacity(0.2),
                splashColor: Colors.red.withOpacity(0.8),
                icon: Icon(Icons.delete),
                onPressed: () => _deleteAllNotes(contextSnackBar),
              ),
        ),
        IconButton(
          icon: Icon(Icons.home),
          onPressed: () {
            final String cancel = 'Zur Hauptseite zurückkehren?';

            showDialog(
              context: context,
              builder: (_) => NoYesDialog(
                    text: cancel,
                    onPressed: () {
                      Navigator.popUntil(
                        context,
                        ModalRoute.withName(RouteGenerator.routeHomePage),
                      );
                    },
                  ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: SafeArea(
        child: _noteList.isNotEmpty
            ? ListView.builder(
                itemCount: _noteList.length,
                padding: const EdgeInsets.only(
                  top: 8.0,
                  bottom: 88.0,
                  left: 8.0,
                  right: 8.0,
                ),
                itemBuilder: (context, index) {
                  final _note = _noteList[index];
                  final key = Key('${_note.hashCode}');
                  return Dismissible(
                    key: key,
                    direction: DismissDirection.startToEnd,
                    background: Container(
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.arrow_forward,
                            size: 28.0,
                          ),
                          SizedBox(width: 8.0),
                          Icon(
                            Icons.delete,
                            size: 28.0,
                          ),
                        ],
                      ),
                    ),
                    onDismissed: (direction) => _deleteNote(index),
                    child: _buildItem(index),
                  );
                },
              )
            : Center(
                child: Text(
                  empty_list,
                  style: TextStyle(fontSize: 24.0),
                ),
              ),
      ),
    );
  }

  Widget _buildItem(int index) {
    final _note = _noteList[index];
    return Container(
      height: 80.0,
      child: CardItem(
        note: _note,
        onTap: () => _openNotePage(
              _note.type,
              _note,
            ),
        onLongPress: () => _showContent(index),
      ),
    );
  }

  Widget _buildFabs() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final String desc = 'Editieren';

    return Stack(
      children: <Widget>[
        Positioned(
          bottom: 0.0,
          left: ((screenWidth + 32.0) / 2) - 28.0,
          child: FloatingActionButton(
            heroTag: null,
            child: Icon(Icons.description),
            tooltip: desc,
            onPressed: _showDialogEditProject,
          ),
        ),
        Positioned(
          bottom: 0.0,
          left: 32.0,
          child: Row(
            children: <Widget>[
              FloatingActionButton(
                heroTag: null,
                child: Icon(Icons.lightbulb_outline),
                tooltip: 'Darkmodus',
                onPressed: () {
                  _darkModeEnabled
                      ? _themeChanger.setTheme(appLightTheme())
                      : _themeChanger.setTheme(appDarkTheme());
                },
              ),
            ],
          ),
        ),
        _buildSpeedDialFab(),
      ],
    );
  }

  _showDialogEditProject() async {
    final title = _title;

    await showDialog(
      context: context,
      builder: (context) {
        return SimpleTimerDialog(
          createdAt: _createdAt,
          textEditingController: _titleProjectController,
          descEditingController: _descProjectController,
          descExists: true,
          onPressedClose: () => Navigator.pop(context),
          onPressedClear: () {
            if (_titleProjectController.text.isNotEmpty) {
              _titleProjectController.clear();
            }

            if (_descProjectController.text.isNotEmpty) {
              _descProjectController.clear();
            }
          },
          onPressedUpdate: () {
            _updateProject(widget.project);

            setState(() {
              _title = _titleProjectController.text;
            });

            Navigator.pop(context);
          },
        );
      },
    );
  }

  _updateProject(Project project) async {
    Project updatedProject = Project.fromMap({
      ProjectDatabaseProvider.columnProjectId: project.id,
      ProjectDatabaseProvider.columnProjectTitle: _titleProjectController.text,
      ProjectDatabaseProvider.columnProjectDesc: _descProjectController.text,
      ProjectDatabaseProvider.columnProjectCreatedAt: project.dateCreated,
      ProjectDatabaseProvider.columnProjectUpdatedAt: dateFormatted(),
    });

    await _projectDb.updateProject(newProject: updatedProject);
  }

  _buildSpeedDialFab() {
    return SpeedDial(
      tooltip: 'Eintragsart auswählen',
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      elevation: 4.0,
      foregroundColor: Colors.black,
      animatedIcon: AnimatedIcons.menu_arrow,
      curve: Curves.elasticOut,
      children: [
        _buildSpeedDialChild(
          Icon(Icons.create),
          Colors.green,
          text,
        ),
        _buildSpeedDialChild(
          Icon(Icons.brush),
          Colors.blue,
          sketch,
        ),
        _buildSpeedDialChild(
          Icon(Icons.table_chart),
          Colors.deepOrange,
          table,
        ),
        _buildSpeedDialChild(
          Icon(Icons.camera_alt),
          Colors.purple,
          image,
        ),
        _buildSpeedDialChild(
          Icon(Icons.location_on),
          Colors.brown,
          sensor,
        ),
      ],
    );
  }

  SpeedDialChild _buildSpeedDialChild(
    Icon icon,
    Color backgroundColor,
    String type,
  ) {
    return SpeedDialChild(
      child: icon,
      backgroundColor: backgroundColor,
      foregroundColor: Colors.white,
      labelStyle: TextStyle(color: Colors.black),
      elevation: 4.0,
      label: '$type hinzufügen',
      onTap: () => _openNotePage(type),
    );
  }

  _openNotePage(String type, [Note note]) async {
    switch (type) {
      case 'Text':
        final result = await Navigator.pushNamed(
          context,
          RouteGenerator.textPage,
          arguments: {
            'project': widget.projectTitle,
            'note': note,
          },
        );

        if (result != null && result) {
          _loadNoteList();
          _scaffoldKey.currentState.showSnackBar(
            _buildSnackBar(text: 'Notiz hinzugefügt.'),
          );
        }
        break;
      case 'Zeichnung':
        Navigator.pushNamed(
          context,
          RouteGenerator.sketchPage,
        );
        break;
      case 'Tabelle':
        final result = await Navigator.pushNamed(
          context,
          RouteGenerator.tablePage,
          arguments: {
            'project': widget.projectTitle,
            'note': note,
          },
        );

        if (result != null) {
          _loadNoteList();
          _scaffoldKey.currentState.showSnackBar(
            _buildSnackBar(text: 'Notiz $result.'),
          );
        }
        break;
      case 'Bild':
        final result = await Navigator.pushNamed(
          context,
          RouteGenerator.imagePage,
          arguments: {
            'projectImagePage': widget.projectTitle,
            'note': note,
          },
        );

        if (result != null && result) {
          _loadNoteList();
          _scaffoldKey.currentState.showSnackBar(
            _buildSnackBar(text: 'Notiz hinzugefügt.'),
          );
        }
        break;
      case 'Sensor':
        final result = await Navigator.pushNamed(
          context,
          RouteGenerator.sensorPage,
          arguments: {
            'project': widget.projectTitle,
            'note': note,
          },
        );

        if (result != null && result) {
          _loadNoteList();
          _scaffoldKey.currentState.showSnackBar(
            _buildSnackBar(text: 'Notiz hinzugefügt.'),
          );
        }
        break;
      default:
        break;
    }
  }

  void _deleteNote(int index) async {
    await _noteDb.deleteNote(id: _noteList[index].id);

    if (_noteList[index].type == 'Tabelle') {
      File file = File(_noteList[index].content);
      file.delete();
    }

    if (_noteList[index].type == 'Bild') {
      File file = File(_noteList[index].content);
      file.delete();
    }

    setState(() {
      _noteList.removeAt(index);
    });
  }

  void _loadNoteList() async {
    for (int i = 0; i < _noteList.length; i++) {
      _noteList.removeWhere((element) {
        _noteList[i].id = _noteList[i].id;
      });
    }

    List notes = await _noteDb.getAllNotes();

    notes.forEach((note) {
      setState(() {
        _noteList.insert(0, Note.map(note));
      });

      _choiceSortOption(sort_by_release_date_desc);
    });
  }

  Future<bool> _deleteAllNotes(BuildContext contextSnackBar) async {
    return await showDialog(
      context: context,
      builder: (context) => AlarmDialog(
            text: do_you_want_to_delete_all,
            icon: Icons.warning,
            onTap: () {
              if (_noteList.isNotEmpty) {
                _noteDb.deleteAllNotes();
                _scaffoldKey.currentState.showSnackBar(
                  _buildSnackBar(text: list_deleted),
                );
              } else {
                _scaffoldKey.currentState.showSnackBar(
                  _buildSnackBar(text: nothing_to_delete),
                );
              }

              setState(() {
                _noteList.clear();
              });

              Navigator.pop(context);
            },
          ),
    );
  }

  Widget _buildSnackBar({@required String text}) {
    return SnackBar(
      backgroundColor: Colors.black.withOpacity(0.5),
      duration: Duration(seconds: 1),
      content: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showContent(int index) {
    final String createdAt = 'Erstellt am';

    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8.0),
            ),
          ),
          contentPadding: const EdgeInsets.all(16.0),
          titlePadding: const EdgeInsets.all(0.0),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 16.0),
                    Text(
                      'TEST',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      '$createdAt: '
                      '${_noteList[index].dateCreated}',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.0),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          children: <Widget>[
            Text(
              '$title:',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              _noteList[index].title,
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 32.0),
            Text(
              '$desc:',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              _noteList[index].content,
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 8.0),
          ],
        );
      },
    );
  }

  void _choiceSortOption(String choice) {
    switch (choice) {
      case sort_by_title_arc:
        setState(() {
          _noteList.sort(
            (Note a, Note b) =>
                a.title.toLowerCase().compareTo(b.title.toLowerCase()),
          );
        });
        break;
      case sort_by_title_desc:
        setState(() {
          _noteList.sort(
            (Note a, Note b) =>
                b.title.toLowerCase().compareTo(a.title.toLowerCase()),
          );
        });
        break;
      case sort_by_release_date_asc:
        setState(() {
          _noteList.sort(
            (Note a, Note b) => a.dateCreated.compareTo(b.dateCreated),
          );
        });
        break;
      case sort_by_release_date_desc:
        setState(() {
          _noteList.sort(
            (Note a, Note b) => b.dateCreated.compareTo(a.dateCreated),
          );
        });
        break;
      default:
        break;
    }
  }

  Future<bool> _onBackPressed() async {
    if (widget.isFromCreateProjectPage) {
      Navigator.popUntil(
        context,
        ModalRoute.withName(RouteGenerator.routeHomePage),
      );
    } else {
      Navigator.pop(context, true);
    }
    return false;
  }
}
