import 'dart:io';

import 'package:citizen_lab/bloc/notes_bloc.dart';
import 'package:citizen_lab/custom_widgets/alarm_dialog.dart';
import 'package:citizen_lab/custom_widgets/dial_floating_action_button.dart';
import 'package:citizen_lab/custom_widgets/no_yes_dialog.dart';
import 'package:citizen_lab/custom_widgets/note_item.dart';
import 'package:citizen_lab/custom_widgets/simple_timer_dialog.dart';
import 'package:citizen_lab/database/database_provider.dart';
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
  final bool isFromCreateProjectPage;
  final bool isFromProjectPage;
  final bool isFromProjectSearchPage;
  final String projectTitle;
  final Project project;
  final Note note;

  EntryPage({
    @required this.isFromCreateProjectPage,
    @required this.isFromProjectPage,
    @required this.isFromProjectSearchPage,
    @required this.projectTitle,
    @required this.project,
    this.note,
  });

  @override
  _EntryPageState createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> with TickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _titleProjectController = TextEditingController();
  final _descProjectController = TextEditingController();
  final _textEditingController = TextEditingController();
  final _projectDb = DatabaseProvider.db;

  NotesBloc _notesBloc;
  ThemeChangerProvider _themeChanger;

  String _title;
  String _createdAt;

  AsyncSnapshot _snapshot;
  List<Note> _noteList = [];

  String createdAtDesc = 'created_at DESC';
  String createdAtAsc = 'created_at ASC';
  String titleDesc = 'title DESC';
  String titleAsc = 'title ASC';
  String _order = 'created_at DESC';

  @override
  void initState() {
    super.initState();

    _notesBloc = NotesBloc(
      random: widget.project.random,
      order: _order,
    );

    //_loadNoteList();

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
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _notesBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _themeChanger = Provider.of<ThemeChangerProvider>(context);

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      body: StreamBuilder(
        stream: _notesBloc.notes,
        builder: (context, snapshot) {
          _snapshot = snapshot;
          return _buildBody(snapshot);
        },
      ),
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
      actions: <Widget>[
        PopupMenuButton(
          icon: Icon(Icons.sort),
          elevation: 2.0,
          tooltip: sort_options,
          onSelected: _choiceSortOption,
          itemBuilder: (BuildContext context) => choices.map(
                (String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                },
              ).toList(),
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
    final String cancel =
        'Experiment abbrechen und zur Hauptseite zurückkehren?';

    await showDialog(
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
  }

  Widget _buildBody(AsyncSnapshot snapshot) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: _onBackPressed,
        //child: _noteList.isNotEmpty
        child: (snapshot.hasData)
            ? ListView.builder(
                //itemCount: _noteList.length,
                itemCount: snapshot.data.length,
                padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 88.0),
                itemBuilder: (context, index) {
                  //final note = _noteList[index];
                  final note = snapshot.data[index];
                  //_noteList.add(note);
                  final key = Key('${note.hashCode}');
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
                    //onDismissed: (_) => _deleteNote(index),
                    onDismissed: (_) {
                      //_notesBloc.delete(note.id);
                      _notesBloc.delete(note);
                      _deleteNote(snapshot, index);
                    },
                    //onDismissed: (_) => _notesBloc.delete(note.id),
                    //child: _buildItem(index),
                    child: _buildItem(snapshot, index),
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

  Widget _buildItem(AsyncSnapshot snapshot, int index) {
    final double screenHeight =
        MediaQuery.of(context).size.height - kToolbarHeight;

    //final _note = _noteList[index];
    final note = snapshot.data[index];
    return Container(
      height: MediaQuery.of(context).orientation == Orientation.portrait
          ? screenHeight / 8
          : screenHeight / 4,
      child: NoteItem(
        note: note,
        onTap: () => _openNotePage(note.type, note),
        //onLongPress: () => _showContent(index),
        onLongPress: () => _showContent(snapshot, index),
      ),
    );
  }

  Widget _buildFabs() {
    final String darkModus = 'Darkmodus';
    final String edit = 'Editieren';

    return Padding(
      padding: EdgeInsets.only(left: 32.0),
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
          DialFloatingActionButton(
            iconList: iconList,
            colorList: colorList,
            stringList: stringList,
            function: _openNotePage,
          ),
        ],
      ),
    );
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) => Container(
            width: 2000.0,
            child: SimpleTimerDialog(
              createdAt: _createdAt,
              textEditingController: _titleProjectController,
              descEditingController: _descProjectController,
              descExists: true,
              onPressedClose: () => Navigator.pop(context),
              onPressedClear: () {
                _titleProjectController.clear();
                _descProjectController.clear();
              },
              onPressedUpdate: () {
                _updateProject(widget.project);
                //_title = _titleProjectController.text;
                Navigator.pop(context);
              },
            ),
          ),
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
      builder: (BuildContext context) => ListView(
            shrinkWrap: true,
            children: experimentItemsWidgets,
          ),
    );
  }

  Widget _createTile(ExperimentItem experimentItem, bool centerIcon) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double tileHeight = screenHeight / 12;

    return Material(
      child: InkWell(
        child: Container(
          height: tileHeight,
          child: Stack(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(8.0),
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

  void _updateProject(Project project) async {
    Project updatedProject = Project.fromMap({
      DatabaseProvider.columnProjectId: project.id,
      DatabaseProvider.columnProjectRandom: project.random,
      DatabaseProvider.columnProjectTitle: _titleProjectController.text,
      DatabaseProvider.columnProjectDesc: _descProjectController.text,
      DatabaseProvider.columnProjectCreatedAt: project.dateCreated,
      DatabaseProvider.columnProjectUpdatedAt: dateFormatted(),
    });
    await _projectDb.updateProject(newProject: updatedProject);
  }

  void _openNotePage(String type, [Note note]) async {
    switch (type) {
      case 'Text':
        _updateList(note, RouteGenerator.textPage);
        break;
      case 'Tabelle':
        _updateList(note, RouteGenerator.tablePage);
        break;
      case 'Bild':
        _updateList(note, RouteGenerator.imagePage);
        break;
      case 'Verlinkung':
        _updateList(note, RouteGenerator.linkingPage);
        break;
    }
  }

  void _updateList(Note note, String route) async {
    final result = await Navigator.pushNamed(
      context,
      route,
      arguments: {
        'projectRandom': widget.project.random,
        'projectId': widget.project.id,
        'note': note,
      },
    ) as Note;

    bool exists;
    if (result != null && result.edited == 0) {
      exists = false;
    } else {
      exists = true;
    }

    !exists ? _notesBloc.add(result) : _notesBloc.update(result);
  }

  void _loadNoteList() async {
    /*for (int i = 0; i < _noteList.length; i++) {
      _noteList.removeWhere((element) {
        _noteList[i].id = _noteList[i].id;
      });
    }*/
    //List notes = await _noteDb.getAllNotes();

    //List notes = await _noteDb.getNotesOfProject(random: widget.project.random);
    //List notes = await _noteDb.getAllNotes();
    //List notes = await _noteDb.getNotesOfProject(id: widget.projectTitle);
    //List notes = await _noteDb.getNotesOfProject(id: widget.project.id);

    //List notes = await _noteDb.getNote(id: widget.projectTitle);
    //List notes = await _noteDb.getNotesOfProject(id: widget.project.id);
    //List notes = await _noteDb.getNotesOfProject(id: 0);
    //List notes = await _noteDb.getAllNotes(title: widget.projectTitle);

    //List notes = _notesBloc.getNotes(random: widget.project.random);

    /*notes.forEach((note) {
      setState(() {
        //_noteList.insert(0, Note.map(note));
        //_noteList.insert(0, note[notes]);
      });
    });*/

    //_choiceSortOption(sort_by_release_date_desc);
    _choiceSortOption(sort_by_release_date_asc);
  }

  void _deleteNote(AsyncSnapshot snapshot, int index) async {
    //await _noteDb.deleteNote(id: _noteList[index].id);
    //await _noteDb.deleteNote(id: _noteList[index].id);

    //if (_noteList[index].type == 'Tabelle') {
    if (snapshot.data[index].type == 'Tabelle') {
      //File file = File(_noteList[index].content);
      File file = File(snapshot.data[index].content);
      file.delete();
    }

    //if (_noteList[index].type == 'Bild') {
    if (snapshot.data[index].type == 'Bild') {
      //File file = File(_noteList[index].content);
      File file = File(snapshot.data[index].content);
      file.delete();
    }

    /*setState(() {
      _noteList.removeAt(index);
    });*/
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
                //final note = snapshot.data[index];

                //for (int i = 0; i < _noteList.length; i++) {}

                _notesBloc.deleteAllNotesFromProject(
                  //widget.note,
                  //_snapshot.data[index],
                  _noteList,
                  widget.project.random,
                );

                _scaffoldKey.currentState.showSnackBar(
                  _buildSnackBar(text: list_deleted),
                );
              } else {
                _scaffoldKey.currentState.showSnackBar(
                  _buildSnackBar(text: nothing_to_delete),
                );
              }

              Navigator.pop(context);
            },
          ),
    );
  }

  Future<bool> _deleteAllNotes2(BuildContext contextSnackBar) async {
    final String doYouWantToDeleteAllNotes =
        'Wollen sie alle Einträge löschen?';

    return await showDialog(
      context: context,
      builder: (context) => AlarmDialog(
            text: doYouWantToDeleteAllNotes,
            icon: Icons.warning,
            /*onTap: () {
              if (_noteList.isNotEmpty) {
                //_noteDb.deleteAllNotes();

                /*_noteDb.deleteAllNotesFromProject(
                    random: widget.project.random);*/
                //_notesBloc.deleteAllNotesFromProject(widget.project.random);

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
            },*/
          ),
    );
  }

  Widget _buildSnackBar({@required String text}) {
    return SnackBar(
      backgroundColor: Colors.black.withOpacity(0.5),
      duration: Duration(seconds: 1),
      content: Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  void _showContent(AsyncSnapshot snapshot, int index) {
    final String createdAt = 'Erstellt am';

    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            contentPadding: EdgeInsets.all(16.0),
            titlePadding: EdgeInsets.only(left: 16.0),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 16.0),
                    Text(
                      '$createdAt: '
                      //'${_noteList[index].dateCreated}',
                      '${snapshot.data[index].dateCreated}',
                      style: TextStyle(
                          fontSize: 14.0, fontWeight: FontWeight.bold),
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
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Text(
                  //_noteList[index].title,
                  snapshot.data[index].title,
                  style: TextStyle(fontSize: 16.0)),
              SizedBox(height: 32.0),
              Text(
                '$desc:',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Text(
                //_noteList[index].description,
                snapshot.data[index].description,
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 8.0),
            ],
          ),
    );
  }

  void _choiceSortOption(String choice) {
    switch (choice) {
      case sort_by_title_arc:
        /*setState(() {
          _noteList.sort(
            (Note a, Note b) =>
                a.title.toLowerCase().compareTo(b.title.toLowerCase()),
          );
        });*/
        //_notesBloc.sortByTitleArc(_noteList);
        break;
      case sort_by_title_desc:
        /*setState(() {
          _noteList.sort(
            (Note a, Note b) =>
                b.title.toLowerCase().compareTo(a.title.toLowerCase()),
          );
        });*/
        //_notesBloc.sortByTitleDesc(_noteList);
        break;
      case sort_by_release_date_asc:
        /*setState(() {
          _noteList.sort(
            (Note a, Note b) => a.dateCreated.compareTo(b.dateCreated),
          );
        });*/
        //_notesBloc.sortByReleaseDateArc(_noteList);
        break;
      case sort_by_release_date_desc:
        /*setState(() {
          _noteList.sort(
            (Note a, Note b) => b.dateCreated.compareTo(a.dateCreated),
          );
        });*/
        //_notesBloc.sortByReleaseDateDesc(_noteList);
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
