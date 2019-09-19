import 'dart:io';

import 'package:citizen_lab/app_locations.dart';
import 'package:citizen_lab/custom_widgets/alarm_dialog.dart';
import 'package:citizen_lab/custom_widgets/dial_floating_action_button.dart';
import 'package:citizen_lab/custom_widgets/note_item.dart';
import 'package:citizen_lab/custom_widgets/simple_timer_dialog.dart';
import 'package:citizen_lab/database/database_helper.dart';
import 'package:citizen_lab/notes/note.dart';
import 'package:citizen_lab/projects/project.dart';
import 'package:citizen_lab/themes/theme_changer_provider.dart';
import 'package:citizen_lab/utils/app_colors.dart';
import 'package:citizen_lab/utils/constants.dart';
import 'package:citizen_lab/utils/date_formatter.dart';
import 'package:citizen_lab/utils/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:permission/permission.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../entry_fab_data.dart';
import 'note_search_page.dart';
import 'text/text_template_item.dart';

class NotePage extends StatefulWidget {
  final bool isFromProjectPage;
  final bool isFromProjectSearchPage;
  final String projectTitle;
  final Project project;
  final Note note;

  const NotePage({
    @required this.isFromProjectPage,
    @required this.isFromProjectSearchPage,
    @required this.projectTitle,
    @required this.project,
    this.note,
  });

  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> with TickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _titleProjectController = TextEditingController();
  final _descProjectController = TextEditingController();
  final _textEditingController = TextEditingController();
  final _projectDb = DatabaseHelper.db;
  final List<Note> _notes = [];

  String _title;
  String _createdAt;

  @override
  void initState() {
    super.initState();

    _loadNoteList();

    _titleProjectController.text = widget.project.title;
    _descProjectController.text = widget.project.description;
    _title = widget.projectTitle;
    _createdAt = widget.project.createdAt;

    _titleProjectController.addListener(() {
      setState(() => _title = _titleProjectController.text);
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        tooltip: AppLocalizations.of(context).translate('back'),
        icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context, true),
      ),
      title: Consumer<ThemeChangerProvider>(
        builder: (BuildContext context, ThemeChangerProvider provider, Widget child) {
          return GestureDetector(
            onPanStart: (_) => provider.setTheme(),
            child: Container(
              width: double.infinity,
              child: Tooltip(
                message: _title,
                child: Text(_title),
              ),
            ),
          );
        },
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () => _setSearch(),
        ),
        PopupMenuButton(
          icon: Icon(Icons.sort),
          elevation: 2.0,
          tooltip: AppLocalizations.of(context).translate('sortOptions'),
          onSelected: _choiceSortOption,
          itemBuilder: (BuildContext context) => Constants.choices.map(
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

  void _setSearch() {
    showSearch(
      context: context,
      delegate: NoteSearchPage(
        noteList: _notes,
        isFromNoteSearchPage: false,
        reloadNoteList: () => _loadNoteList(),
        openNotePage: _openNotePage,
      ),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () => _handleBackPressed(),
        /*onWillPop: () async {
          Navigator.pop(context);
          return false;
        },*/
        child: _notes.isNotEmpty
            ? ListView.builder(
                itemCount: _notes.length,
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 88.0),
                itemBuilder: (context, index) {
                  final note = _notes[index];
                  final key = Key('${note.hashCode}');
                  return _buildDismissible(key, note, index);
                },
              )
            : Center(
                child: Text(
                  AppLocalizations.of(context).translate('emptyList'),
                  style: TextStyle(fontSize: 24.0),
                ),
              ),
      ),
    );
  }

  Future<bool> _handleBackPressed() async {
    Navigator.pop(context);
    return false;
  }

  Widget _buildDismissible(Key key, Note note, int index) {
    return Dismissible(
      key: key,
      direction: DismissDirection.startToEnd,
      background: Container(
        alignment: Alignment.centerLeft,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(Icons.arrow_forward, size: 28.0),
            const SizedBox(width: 8.0),
            Icon(Icons.delete, size: 28.0),
          ],
        ),
      ),
      onDismissed: (_) => _deleteNote(index),
      child: _buildItem(note, index),
    );
  }

  Widget _buildItem(Note note, int index) {
    final double screenHeight = MediaQuery.of(context).size.height - kToolbarHeight;

    return Container(
      height: MediaQuery.of(context).orientation == Orientation.portrait ? screenHeight / 8 : screenHeight / 4,
      child: NoteItem(
        note: note,
        isFromNoteSearchPage: false,
        close: null,
        noteFunction: () => _openNotePage(note.type, true, note),
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
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        children: <Widget>[
          Scrollbar(
            child: Container(
              height: screenHeight / 2,
              width: screenWidth / 2,
              child: GridView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: AppColors.cardColors.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FloatingActionButton(
                      backgroundColor: Color(AppColors.cardColors[index].cardBackgroundColor),
                      onPressed: () {
                        _updateNote(
                          note,
                          AppColors.cardColors[index].cardBackgroundColor,
                          AppColors.cardColors[index].cardItemColor,
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
    final Note newNote = Note.fromMap({
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
    const String darkModus = 'Darkmodus';
    const String edit = 'Editieren';

    return Padding(
      padding: const EdgeInsets.only(left: 32.0),
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
            iconList: entryIcons,
            stringList: entryStrings,
            function: _openNotePage,
            isNoteCard: true,
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
    final List<TextTemplateItem> experimentItems = [
      TextTemplateItem('', Icons.keyboard_arrow_down),
      TextTemplateItem('Rechner', Icons.straighten),
      TextTemplateItem('Stoppuhr', Icons.timer),
      TextTemplateItem('Ortsbestimmung', Icons.location_on),
    ];

    final List<Widget> experimentItemsWidgets = [];
    for (int i = 0; i < experimentItems.length; i++) {
      i == 0
          ? experimentItemsWidgets.add(_createTile(experimentItems[i], true))
          : experimentItemsWidgets.add(_createTile(experimentItems[i], false));
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

  Widget _createTile(TextTemplateItem experimentItem, bool centerIcon) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double tileHeight = screenHeight / 12;

    return Material(
      child: InkWell(
        onTap: () {
          if (experimentItem.name.isEmpty) {
            Navigator.pop(context);
          } else if (experimentItem.name == 'Rechner') {
            Navigator.popAndPushNamed(context, CustomRoute.calculatorPage);
          } else if (experimentItem.name == 'Stoppuhr') {
            Navigator.popAndPushNamed(context, CustomRoute.stopwatchPage);
          } else if (experimentItem.name == 'Ortsbestimmung') {
            Navigator.popAndPushNamed(context, CustomRoute.locationPage);
          }
        },
        child: Container(
          height: tileHeight,
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
              const Divider(height: 1.0, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateProject(Project project) async {
    final Project updatedProject = Project.fromMap({
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

  void _openNotePage(String type, bool cardPressed, [Note note]) {
    switch (type) {
      case 'Text':
        _setList(note, CustomRoute.textPage);
        break;
      case 'Tabelle':
        _setList(note, CustomRoute.tablePage);
        break;
      case 'Bild':
        _setList(note, CustomRoute.imagePage);
        break;
      case 'Audio':
        _setList(note, CustomRoute.audioRecordPage);
        break;
      case 'Verlinkung':
        if (cardPressed) {
          _setList(note, CustomRoute.webLinkPage);
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return SimpleDialog(
                contentPadding: const EdgeInsets.all(0.0),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                children: <Widget>[
                  _searchEngineButton(note, 'Google', 'https://www.google.de/?hl=de'),
                  _searchEngineButton(note, 'DuckDuckGo', 'https://duckduckgo.com/'),
                  _searchEngineButton(note, 'Ecosia', 'https://www.ecosia.org/'),
                  _searchEngineButton(note, 'Qwant', 'https://www.qwant.com/?l=de'),
                ],
              );
            },
          );
        }
        break;
    }
  }

  Widget _searchEngineButton(Note note, String title, String url) {
    return RaisedButton(
      elevation: 0.0,
      highlightElevation: 0.0,
      onPressed: () {
        Navigator.pop(context);
        _setList(note, CustomRoute.webLinkPage, url);
      },
      child: Text(title),
    );
  }

  Future<void> _setPermission() async {
    final _permissions = await Permission.getPermissionsStatus([PermissionName.Microphone, PermissionName.Storage]);
    await Permission.requestPermissions([PermissionName.Microphone, PermissionName.Storage]);
  }

  Future<void> _setList(Note note, String route, [String searchEngine]) async {
    final result = await Navigator.pushNamed(
      context,
      route,
      arguments: {
        argProjectUuid: widget.project.uuid,
        //RouteGenerator.project: widget.project.id,
        argNote: note,
        argSearchEngine: searchEngine ?? searchEngine,
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

    await _loadNoteList();
  }

  final String _sortingOrderPrefs = 'sortNotes';

  Future<String> _getSortingOrder() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //return prefs.getString(_kSortingOrderPrefs) ?? sort_by_release_date_desc;
    final order = prefs.getString(_sortingOrderPrefs);
    if (order == null) {
      return AppLocalizations.of(context).translate('sortByReleaseDateDesc');
    }
    return order;
  }

  Future<void> setSortingOrder(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sortingOrderPrefs, value);
  }

  Future<void> _loadNoteList() async {
    for (int i = 0; i < _notes.length; i++) {
      _notes.removeWhere((element) {
        _notes[i].id = _notes[i].id;
        return true;
      });
    }

    final List notes = await _projectDb.getNotesOfProject(uuid: widget.project.uuid);

    for (int i = 0; i < notes.length; i++) {
      setState(() => _notes.insert(0, notes[i]));
    }

    _choiceSortOption(await _getSortingOrder());
  }

  //void _deleteNote(AsyncSnapshot snapshot, int index) async {
  Future<void> _deleteNote(int index) async {
    await _projectDb.deleteNote(id: _notes[index].id);
    //await _noteDb.deleteNote(id: _noteList[index].id);

    if (_notes[index].type == 'Tabelle') {
      //if (snapshot.data[index].type == 'Tabelle') {
      final File file = File(_notes[index].filePath);
      //File file = File(snapshot.data[index].content);
      await file.delete();
    }

    if (_notes[index].type == 'Bild') {
      //if (snapshot.data[index].type == 'Bild') {
      final File file = File(_notes[index].filePath);
      //File file = File(snapshot.data[index].content);
      await file.delete();
    }

    if (_notes[index].type == 'Audio') {
      final File file = File(_notes[index].filePath);
      await file.delete();
    }

    setState(() => _notes.removeAt(index));
  }

  void _deleteAllNotes(BuildContext contextSnackBar) {
    const String doYouWantToDeleteAllNotes = 'Wollen sie alle Einträge löschen?';

    showDialog(
      context: context,
      builder: (context) => AlarmDialog(
        text: doYouWantToDeleteAllNotes,
        icon: Icons.warning,
        onTap: () {
          if (_notes.isNotEmpty) {
            //final note = snapshot.data[index];

            //for (int i = 0; i < _noteList.length; i++) {}

            _projectDb.deleteAllNotesFromProject(uuid: widget.project.uuid);

            /*_notesBloc.deleteAllNotesFromProject(
                  //widget.note,
                  //_snapshot.data[index],
                  _noteList,
                  widget.project.random,
                );*/
          } else {}

          _loadNoteList();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _choiceSortOption(String choice) {
    switch (choice) {
      case Constants.sortByTitleArc:
        setState(() {
          _notes.sort(
            (Note a, Note b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
          );
        });
        setSortingOrder(Constants.sortByTitleArc);
        break;
      case Constants.sortByTitleDesc:
        setState(() {
          _notes.sort(
            (Note a, Note b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()),
          );
        });
        setSortingOrder(Constants.sortByTitleDesc);
        break;
      case Constants.sortByReleaseDateAsc:
        setState(() {
          _notes.sort(
            (Note a, Note b) {
              final parsedDate1 = DateTime.parse(a.createdAt);
              final parsedDate2 = DateTime.parse(b.createdAt);
              return parsedDate1.compareTo(parsedDate2);
            },
          );
        });
        setSortingOrder(Constants.sortByReleaseDateAsc);
        break;
      case Constants.sortByReleaseDateDesc:
        setState(() {
          _notes.sort(
            (Note a, Note b) {
              final parsedDate1 = DateTime.parse(a.createdAt);
              final parsedDate2 = DateTime.parse(b.createdAt);
              return parsedDate2.compareTo(parsedDate1);
            },
          );
        });
        setSortingOrder(Constants.sortByReleaseDateDesc);
        break;
    }
  }
}
