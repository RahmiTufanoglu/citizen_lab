import 'dart:io';

import 'package:citizen_lab/custom_widgets/alarm_dialog.dart';
import 'package:citizen_lab/custom_widgets/card_item.dart';
import 'package:citizen_lab/custom_widgets/no_yes_dialog.dart';
import 'package:citizen_lab/custom_widgets/simple_timer_dialog.dart';
import 'package:citizen_lab/custom_widgets/speed_dial_floating_action_button.dart';
import 'package:citizen_lab/database/project_database_helper.dart';
import 'package:citizen_lab/entries/note.dart';
import 'package:citizen_lab/projects/project.dart';
import 'package:citizen_lab/themes/theme_changer_provider.dart';
import 'package:citizen_lab/utils/constants.dart';
import 'package:citizen_lab/utils/date_formater.dart';
import 'package:citizen_lab/utils/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../entry_fab_data.dart';
import 'experiment_item.dart';

class EntryPage extends StatefulWidget {
  final Key key;
  final bool isFromCreateProjectPage;
  final bool isFromProjectPage;
  final bool isFromProjectSearchPage;
  final String projectTitle;
  final Project project;
  final Note note;

  EntryPage({
    this.key,
    @required this.isFromCreateProjectPage,
    @required this.isFromProjectPage,
    @required this.isFromProjectSearchPage,
    @required this.projectTitle,
    @required this.project,
    this.note,
  }) : super(key: key);

  @override
  _EntryPageState createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> with TickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _titleProjectController = TextEditingController();
  final _descProjectController = TextEditingController();
  final _textEditingController = TextEditingController();
  final _projectDb = ProjectDatabaseHelper();
  final _noteDb = ProjectDatabaseHelper();
  //final _databaseBloc = DatabaseBloc();

  ThemeChangerProvider _themeChanger;
  List<Note> _noteList = [];
  bool _listLoaded = false;
  String _title;
  String _createdAt;

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
        if (_titleProjectController.text.isNotEmpty) {
          _title = _titleProjectController.text;
        }
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    //_databaseBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _themeChanger = Provider.of<ThemeChangerProvider>(context);
    _themeChanger.checkIfDarkModeEnabled(context);

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
      title: GestureDetector(
        onPanStart: (_) => _themeChanger.setTheme(),
        child: Container(
          width: double.infinity,
          child: Tooltip(
            message: _title,
            child: Text(_title),
          ),
        ),
      ),
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
          builder: (contextSnackBar) {
            return IconButton(
              highlightColor: Colors.red.withOpacity(0.2),
              splashColor: Colors.red.withOpacity(0.8),
              icon: Icon(Icons.delete),
              onPressed: () => _deleteAllNotes(contextSnackBar),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.home),
          onPressed: () => _backToHomePage(),
        ),
      ],
    );
  }

  Future<void> _backToHomePage() async {
    final String cancel = 'Notiz abbrechen und zur Hauptseite zurückkehren?';

    await showDialog(
      context: context,
      builder: (_) {
        return NoYesDialog(
          text: cancel,
          onPressed: () {
            Navigator.popUntil(
              context,
              ModalRoute.withName(RouteGenerator.routeHomePage),
            );
          },
        );
      },
    );
  }

  /*Widget _buildBody2() {
    return SafeArea(
      child: WillPopScope(
        onWillPop: _onBackPressed,
        child: _noteList.isNotEmpty
            ? StreamBuilder<List<Note>>(
                stream: _databaseBloc.notes,
                builder: (
                  BuildContext context,
                  AsyncSnapshot<List<Note>> snapshot,
                ) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      //itemCount: _noteList.length,
                      itemCount: snapshot.data.length,
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                            ),
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.arrow_forward, size: 28.0),
                                SizedBox(width: 8.0),
                                Icon(Icons.delete, size: 28.0),
                              ],
                            ),
                          ),
                          onDismissed: (_) => _deleteNote(index),
                          child: _buildItem(index),
                        );
                      },
                    );
                  }
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
  }*/

  Widget _buildBody() {
    return SafeArea(
      child: WillPopScope(
        onWillPop: _onBackPressed,
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
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.arrow_forward, size: 28.0),
                          SizedBox(width: 8.0),
                          Icon(Icons.delete, size: 28.0),
                        ],
                      ),
                    ),
                    onDismissed: (_) => _deleteNote(index),
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
        onTap: () => _openNotePage(_note.type, _note),
        onLongPress: () => _showContent(index),
      ),
    );
  }

  Widget _buildFabs() {
    final String darkModus = 'Darkmodus';
    final String edit = 'Editieren';

    return Padding(
      padding: const EdgeInsets.only(left: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            heroTag: null,
            child: Icon(Icons.description),
            tooltip: darkModus,
            onPressed: () => _showEditDialog(),
          ),
          FloatingActionButton(
            heroTag: null,
            child: Icon(Icons.keyboard_arrow_up),
            tooltip: edit,
            onPressed: () => _openModalBottomSheet(),
          ),
          SpeedDialFloatingActionButton(
            iconList: iconList,
            colorList: colorList,
            stringList: stringList,
            function: _openNotePage,
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog() async {
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
            //_title = _titleProjectController.text;
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _openModalBottomSheet() {
    List<ExperimentItem> experimentItems = [
      ExperimentItem('', Icons.keyboard_arrow_down),
      ExperimentItem('Rechnen', Icons.straighten),
      ExperimentItem('Stoppuhr', Icons.timer),
      ExperimentItem('Ortsbestimmung', Icons.location_on),
    ];

    List<Widget> experimentItemsWidgets = [];
    for (int i = 0; i < experimentItems.length; i++) {
      if (i == 0) {
        experimentItemsWidgets.add(_createTile(experimentItems[i], true));
      } else {
        experimentItemsWidgets.add(_createTile(experimentItems[i], false));
      }
    }

    _buildMainBottomSheet(experimentItemsWidgets);
  }

  void _buildMainBottomSheet(List<Widget> experimentItemsWidgets) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView(
          shrinkWrap: true,
          children: experimentItemsWidgets,
        );
      },
    );
  }

  Widget _createTile(ExperimentItem experimentItem, bool centerIcon) {
    return Material(
      child: InkWell(
        child: Container(
          height: 50.0,
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: (!centerIcon)
                      ? Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                experimentItem.name,
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ),
                            Expanded(
                              child: Icon(experimentItem.icon, size: 24.0),
                            ),
                          ],
                        )
                      : Center(
                          child: Icon(experimentItem.icon, size: 24.0),
                        ),
                ),
              ),
              Divider(height: 1.0, color: Colors.black),
            ],
          ),
        ),
        onTap: () {
          if (experimentItem.name.isEmpty) {
            Navigator.pop(context);
          } else if (experimentItem.name == 'Rechnen') {
            Navigator.popAndPushNamed(context, RouteGenerator.calculatorPage);
          } else if (experimentItem.name == 'Stoppuhr') {
            Navigator.popAndPushNamed(context, RouteGenerator.stopwatchPage);
          } else if (experimentItem.name == 'Ortsbestimmung') {
            Navigator.popAndPushNamed(context, RouteGenerator.sensorPage);
          }
        },
      ),
    );
  }

  Future<void> _updateProject(Project project) async {
    Project updatedProject = Project.fromMap({
      ProjectDatabaseHelper.columnProjectId: project.id,
      ProjectDatabaseHelper.columnProjectRandom: project.random,
      ProjectDatabaseHelper.columnProjectTitle: _titleProjectController.text,
      ProjectDatabaseHelper.columnProjectDesc: _descProjectController.text,
      ProjectDatabaseHelper.columnProjectCreatedAt: project.dateCreated,
      ProjectDatabaseHelper.columnProjectUpdatedAt: dateFormatted(),
    });
    await _projectDb.updateProject(newProject: updatedProject);
  }

  /*_buildSpeedDialFab() {
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
          'Text',
        ),
        _buildSpeedDialChild(
          Icon(Icons.table_chart),
          Colors.indigoAccent,
          'Tabelle',
        ),
        _buildSpeedDialChild(
          Icon(Icons.camera_alt),
          Colors.deepOrange,
          'Bild',
        ),
        _buildSpeedDialChild(
          Icon(Icons.link),
          Colors.purple,
          'Verlinkung',
        ),
      ],
    );
  }*/

  /*SpeedDialChild _buildSpeedDialChild(
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
      label: '${type}notiz hinzufügen',
      onTap: () => _openNotePage(type),
    );
  }*/

  _openNotePage(String type, [Note note]) async {
    switch (type) {
      case 'Text':
        final result = await Navigator.pushNamed(
          context,
          RouteGenerator.textPage,
          arguments: {
            'projectRandom': widget.project.random,
            'projectId': widget.project.id,
            'note': note,
          },
        );

        if (result != null && result) _loadNoteList();
        break;
      case 'Tabelle':
        final result = await Navigator.pushNamed(
          context,
          RouteGenerator.tablePage,
          arguments: {
            'projectRandom': widget.project.random,
            'projectId': widget.project.id,
            'note': note,
          },
        );

        if (result != null && result) _loadNoteList();
        break;
      case 'Bild':
        final result = await Navigator.pushNamed(
          context,
          RouteGenerator.imagePage,
          arguments: {
            'projectRandom': widget.project.random,
            'projectId': widget.project.id,
            'note': note,
          },
        );

        if (result != null && result) _loadNoteList();
        break;
      case 'Wetter':
        final result = await Navigator.pushNamed(
          context,
          RouteGenerator.audioRecordPage,
          arguments: {
            'note': note,
          },
        );

        if (result != null && result) _loadNoteList();
        break;
      case 'Verlinkung':
        final result = await Navigator.pushNamed(
          context,
          RouteGenerator.linkingPage,
          arguments: {
            'projectRandom': widget.project.random,
            'projectId': widget.project.id,
            'note': note,
          },
        );

        if (result != null && result) _loadNoteList();
        break;
      default:
        break;
    }
  }

  void _loadNoteList() async {
    for (int i = 0; i < _noteList.length; i++) {
      _noteList.removeWhere((element) {
        _noteList[i].id = _noteList[i].id;
      });
    }

    //List notes = await _noteDb.getAllNotes();

    //List notes = await _noteDb.getAllNotes();
    //List notes = await _noteDb.getNotesOfProject(id: widget.projectTitle);
    List notes = await _noteDb.getNotesOfProject(random: widget.project.random);
    //List notes = await _noteDb.getNotesOfProject(id: widget.project.id);

    //List notes = await _noteDb.getNote(id: widget.projectTitle);
    //List notes = await _noteDb.getNotesOfProject(id: widget.project.id);
    //List notes = await _noteDb.getNotesOfProject(id: 0);
    //List notes = await _noteDb.getAllNotes(title: widget.projectTitle);

    notes.forEach((note) {
      setState(() {
        _noteList.insert(0, Note.map(note));
      });

      _choiceSortOption(sort_by_release_date_desc);
    });
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

  Future<bool> _deleteAllNotes(BuildContext contextSnackBar) async {
    final String doYouWantToDeleteAllNotes =
        'Wollen sie alle Einträge löschen?';

    return await showDialog(
      context: context,
      builder: (context) => AlarmDialog(
            text: doYouWantToDeleteAllNotes,
            icon: Icons.warning,
            onTap: () {
              if (_noteList.isNotEmpty) {
                //_noteDb.deleteAllNotes();

                _noteDb.deleteAllNotesFromProject(
                    random: widget.project.random);

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
          titlePadding: const EdgeInsets.only(left: 16.0),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 16.0),
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
              _noteList[index].description,
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
      /*} else if (widget.isFromProjectSearchPage) {
      Navigator.pop(context, 'fromEntry');*/
    } else {
      Navigator.pop(context, true);
    }

    return false;
  }
}
