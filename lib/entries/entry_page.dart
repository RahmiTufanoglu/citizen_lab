import 'dart:io';

import 'package:citizen_lab/custom_widgets/alarm_dialog.dart';
import 'package:citizen_lab/custom_widgets/dial_floating_action_button.dart';
import 'package:citizen_lab/custom_widgets/note_item.dart';
import 'package:citizen_lab/custom_widgets/simple_timer_dialog.dart';
import 'package:citizen_lab/database/database_provider.dart';
import 'package:citizen_lab/entries/note.dart';
import 'package:citizen_lab/projects/project.dart';
import 'package:citizen_lab/themes/theme_changer_provider.dart';
import 'package:citizen_lab/utils/colors.dart';
import 'package:citizen_lab/utils/constants.dart';
import 'package:citizen_lab/utils/date_formatter.dart';
import 'package:citizen_lab/utils/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:permission/permission.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../entry_fab_data.dart';
import '../note_search_page.dart';
import 'formulation_item.dart';

class EntryPage extends StatefulWidget {
  final bool isFromProjectPage;
  final bool isFromProjectSearchPage;
  final String projectTitle;
  final Project project;
  final Note note;

  EntryPage({
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
  final _projectDb = DatabaseHelper.db;

  //NotesBloc _notesBloc;
  ThemeChangerProvider _themeChanger;

  String _title;
  String _createdAt;

  //AsyncSnapshot _snapshot;
  List<Note> _noteList = [];

  String createdAtDesc = 'created_at DESC';
  String createdAtAsc = 'created_at ASC';
  String titleDesc = 'title DESC';
  String titleAsc = 'title ASC';

  @override
  void initState() {
    super.initState();

    /*_notesBloc = NotesBloc(
      random: widget.project.random,
      order: _order,
    );*/

    _loadNoteList();

    _titleProjectController.text = widget.project.title;
    _descProjectController.text = widget.project.description;
    _title = widget.projectTitle;
    _createdAt = widget.project.createdAt;

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
    //_notesBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _themeChanger = Provider.of<ThemeChangerProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFabs(),
    );
    /*return Scaffold(
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
    );*/
  }

  Widget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        tooltip: back,
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context, true);
        },
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
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            showSearch(
              context: context,
              delegate: NoteSearchPage(
                noteList: _noteList,
                isFromNoteSearchPage: false,
                reloadNoteList: () => _loadNoteList(),
                openNotePage: _openNotePage,
              ),
            );
          },
        ),
        PopupMenuButton(
          icon: Icon(Icons.sort),
          elevation: 2.0,
          tooltip: sortOptions,
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
          builder: (contextSnackBar) => IconButton(
            highlightColor: Colors.red.withOpacity(0.2),
            splashColor: Colors.red.withOpacity(0.8),
            icon: Icon(Icons.delete),
            onPressed: () => _deleteAllNotes(contextSnackBar),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: WillPopScope(
        //onWillPop: () async => Navigator.pop(context, true),
        onWillPop: () {
          Navigator.pop(context, true);
        },
        child: _noteList.isNotEmpty
            ? ListView.builder(
                itemCount: _noteList.length,
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 88.0),
                itemBuilder: (context, index) {
                  final note = _noteList[index];
                  final key = Key('${note.hashCode}');
                  return _buildDismissible(key, note, index);
                },
              )
            : Center(
                child: Text(
                  emptyList,
                  style: TextStyle(fontSize: 24.0),
                ),
              ),
      ),
    );
  }

  Widget _buildDismissible(Key key, Note note, int index) {
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
      child: _buildItem(note, index),
    );
  }

  /*Widget _buildBody2(AsyncSnapshot snapshot) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: _onBackPressed,
        //child: _noteList.isNotEmpty
        child: (snapshot.hasData)
            ? Container(
                child: ListView.builder(
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
                ),
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

  Widget _buildItem(Note note, int index) {
    final double screenHeight =
        MediaQuery.of(context).size.height - kToolbarHeight;

    return Container(
      height: MediaQuery.of(context).orientation == Orientation.portrait
          ? screenHeight / 8
          : screenHeight / 4,
      child: NoteItem(
        note: note,
        isFromNoteSearchPage: false,
        close: null,
        noteFunction: () => _openNotePage(note.type, note),
        onLongPress: () => _setCardColor(note),
      ),
    );
  }

  void _setCardColor(Note note) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        contentPadding: const EdgeInsets.all(0.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        children: <Widget>[
          Scrollbar(
            child: Container(
              height: screenHeight / 2,
              width: screenWidth / 2,
              child: GridView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: cardColors.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                ),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FloatingActionButton(
                      backgroundColor:
                          Color(cardColors[index].cardBackgroundColor),
                      onPressed: () {
                        _updateNote(
                          note,
                          cardColors[index].cardBackgroundColor,
                          cardColors[index].cardItemColor,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateNote(Note note, int cardColor, int cardTextColor) async {
    Note newNote = Note.fromMap({
      DatabaseHelper.columnNoteId: note.id,
      DatabaseHelper.columnProjectUuid: note.uuid,
      DatabaseHelper.columnNoteType: note.type,
      DatabaseHelper.columnNoteTitle: note.title,
      DatabaseHelper.columnNoteDescription: note.description,
      DatabaseHelper.columnNoteContent: note.filePath,
      DatabaseHelper.columnNoteCreatedAt: note.createdAt,
      DatabaseHelper.columnNoteUpdatedAt: note.updatedAt,
      DatabaseHelper.columnNoteIsFirstTime: 1,
      DatabaseHelper.columnNoteIsEdited: note.isEdited,
      DatabaseHelper.columnNoteCardColor: cardColor,
      DatabaseHelper.columnNoteCardTextColor: cardTextColor,
    });
    await _projectDb.updateNote(newNote: newNote);
    await _loadNoteList();
    Navigator.pop(context, newNote);
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
            tooltip: darkModus,
            onPressed: () => _showEditDialog(),
            child: Icon(Icons.assignment),
          ),
          FloatingActionButton(
            heroTag: null,
            tooltip: edit,
            onPressed: () => _openModalBottomSheet(),
            child: Icon(Icons.keyboard_arrow_up),
          ),
          DialFloatingActionButton(
            iconList: entryIconList,
            //colorList: entryColorList,
            stringList: entryStringList,
            function: _openNotePage,
          ),
        ],
      ),
    );
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) => SimpleTimerDialog(
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
    );
  }

  void _openModalBottomSheet() {
    List<FormulationItem> experimentItems = [
      FormulationItem('', Icons.keyboard_arrow_down),
      FormulationItem('Rechner', Icons.straighten),
      FormulationItem('Stoppuhr', Icons.timer),
      FormulationItem('Ortsbestimmung', Icons.location_on),
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

  Widget _createTile(FormulationItem experimentItem, bool centerIcon) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double tileHeight = screenHeight / 12;

    return Material(
      child: InkWell(
        onTap: () {
          if (experimentItem.name.isEmpty) {
            Navigator.pop(context);
          } else if (experimentItem.name == 'Rechner') {
            Navigator.popAndPushNamed(context, RouteGenerator.calculatorPage);
          } else if (experimentItem.name == 'Stoppuhr') {
            Navigator.popAndPushNamed(context, RouteGenerator.stopwatchPage);
          } else if (experimentItem.name == 'Ortsbestimmung') {
            Navigator.popAndPushNamed(context, RouteGenerator.sensorPage);
          }
        },
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
      ),
    );
  }

  Future<void> _updateProject(Project project) async {
    Project updatedProject = Project.fromMap({
      DatabaseHelper.columnProjectId: project.id,
      DatabaseHelper.columnProjectUuid: project.uuid,
      DatabaseHelper.columnProjectTitle: _titleProjectController.text,
      DatabaseHelper.columnProjectDesc: _descProjectController.text,
      DatabaseHelper.columnProjectCreatedAt: project.createdAt,
      DatabaseHelper.columnProjectUpdatedAt: dateFormatted(),
      DatabaseHelper.columnProjectCardColor: project.cardColor,
      DatabaseHelper.columnProjectCardTextColor: project.cardTextColor,
    });
    await _projectDb.updateProject(newProject: updatedProject);
  }

  void _openNotePage(String type, [Note note]) {
    switch (type) {
      case 'Text':
        _setList(note, RouteGenerator.textPage);
        break;
      case 'Tabelle':
        _setList(note, RouteGenerator.tablePage);
        break;
      case 'Bild':
        _setList(note, RouteGenerator.imagePage);
        break;
      case 'Verlinkung':
        _setList(note, RouteGenerator.linkingPage);
        break;
      case 'Audio':
        //_setPermission();
        _setList(note, RouteGenerator.audioRecordPage);
        break;
    }
  }

  Future<void> _setPermission() async {
    var _permissions = await Permission.getPermissionsStatus(
        [PermissionName.Microphone, PermissionName.Storage]);
    await Permission.requestPermissions(
        [PermissionName.Microphone, PermissionName.Storage]);
  }

  Future<void> _setList(Note note, String route) async {
    final result = await Navigator.pushNamed(
      context,
      route,
      arguments: {
        RouteGenerator.projectUuid: widget.project.uuid,
        //RouteGenerator.project: widget.project.id,
        RouteGenerator.note: note,
      },
    ) as Note;

    bool exists;
    result != null && result.isFirstTime == 0 ? exists = false : exists = true;

    //!exists ? _notesBloc.add(result) : _notesBloc.update(result);
    if (!exists) {
      await _projectDb.insertNote(note: result);
    } else {
      if (result != null) await _projectDb.updateNote(newNote: result);
    }

    if (result != null) {
      _scaffoldKey.currentState.showSnackBar(
        _buildSnackBar(text: 'Neues ${result.title} hinzugefügt.'),
      );
    }

    await _loadNoteList();
  }

  final String _sortingOrderPrefs = 'sortNotes';

  Future<String> _getSortingOrder() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //return prefs.getString(_kSortingOrderPrefs) ?? sort_by_release_date_desc;
    final order = prefs.getString(_sortingOrderPrefs);
    if (order == null) {
      return sortByReleaseDateDesc;
    }
    return order;
  }

  Future<void> setSortingOrder(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sortingOrderPrefs, value);
  }

  Future<void> _loadNoteList() async {
    for (int i = 0; i < _noteList.length; i++) {
      _noteList.removeWhere((element) {
        _noteList[i].id = _noteList[i].id;
        return true;
      });
    }

    List notes = await _projectDb.getNotesOfProject(uuid: widget.project.uuid);

    for (int i = 0; i < notes.length; i++) {
      setState(() => _noteList.insert(0, notes[i]));
    }

    _choiceSortOption(await _getSortingOrder());
  }

  //void _deleteNote(AsyncSnapshot snapshot, int index) async {
  Future<void> _deleteNote(int index) async {
    await _projectDb.deleteNote(id: _noteList[index].id);
    //await _noteDb.deleteNote(id: _noteList[index].id);

    if (_noteList[index].type == 'Tabelle') {
      //if (snapshot.data[index].type == 'Tabelle') {
      File file = File(_noteList[index].filePath);
      //File file = File(snapshot.data[index].content);
      await file.delete();
    }

    if (_noteList[index].type == 'Bild') {
      //if (snapshot.data[index].type == 'Bild') {
      File file = File(_noteList[index].filePath);
      //File file = File(snapshot.data[index].content);
      await file.delete();
    }

    if (_noteList[index].type == 'Audio') {
      File file = File(_noteList[index].filePath);
      await file.delete();
    }

    _scaffoldKey.currentState.showSnackBar(
      _buildSnackBar(text: 'Projekt ${_noteList[index].title} gelöscht.'),
    );

    setState(() {
      _noteList.removeAt(index);
    });
  }

  void _deleteAllNotes(BuildContext contextSnackBar) {
    final String doYouWantToDeleteAllNotes =
        'Wollen sie alle Einträge löschen?';

    showDialog(
      context: context,
      builder: (context) => AlarmDialog(
        text: doYouWantToDeleteAllNotes,
        icon: Icons.warning,
        onTap: () {
          if (_noteList.isNotEmpty) {
            //final note = snapshot.data[index];

            //for (int i = 0; i < _noteList.length; i++) {}

            _projectDb.deleteAllNotesFromProject(uuid: widget.project.uuid);

            /*_notesBloc.deleteAllNotesFromProject(
                  //widget.note,
                  //_snapshot.data[index],
                  _noteList,
                  widget.project.random,
                );*/

            _scaffoldKey.currentState.showSnackBar(
              _buildSnackBar(text: listDeleted),
            );
          } else {
            _scaffoldKey.currentState.showSnackBar(
              _buildSnackBar(text: nothingToDelete),
            );
          }

          _loadNoteList();
          Navigator.pop(context);
        },
      ),
    );
  }

  /*Future<bool> _deleteAllNotes2(BuildContext contextSnackBar) async {
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
  }*/

  Widget _buildSnackBar({@required String text}) {
    return SnackBar(
      backgroundColor: Colors.black.withOpacity(0.5),
      duration: Duration(seconds: 1),
      content: Text(text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          )),
    );
  }

  void _choiceSortOption(String choice) {
    switch (choice) {
      case sortByTitleArc:
        setState(() {
          _noteList.sort(
            (Note a, Note b) =>
                a.title.toLowerCase().compareTo(b.title.toLowerCase()),
          );
        });
        setSortingOrder(sortByTitleArc);
        break;
      case sortByTitleDesc:
        setState(() {
          _noteList.sort(
            (Note a, Note b) =>
                b.title.toLowerCase().compareTo(a.title.toLowerCase()),
          );
        });
        setSortingOrder(sortByTitleDesc);
        break;
      case sortByReleaseDateAsc:
        setState(() {
          _noteList.sort(
            (Note a, Note b) => a.createdAt.compareTo(b.createdAt),
          );
        });
        setSortingOrder(sortByReleaseDateAsc);
        break;
      case sortByReleaseDateDesc:
        setState(() {
          _noteList.sort(
            (Note a, Note b) => b.createdAt.compareTo(a.createdAt),
          );
        });
        setSortingOrder(sortByReleaseDateDesc);
        break;
    }
  }
}
