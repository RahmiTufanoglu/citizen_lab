import 'dart:async';

import 'package:citizen_lab/entries/text/text_info_page_data.dart';
import 'package:citizen_lab/themes/theme.dart';
import 'package:citizen_lab/themes/theme_changer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:citizen_lab/utils/date_formater.dart';
import 'package:citizen_lab/database/project_database_provider.dart';
import 'package:citizen_lab/utils/route_generator.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:citizen_lab/entries/experiment_item.dart';
import 'package:citizen_lab/custom_widgets/no_yes_dialog.dart';
import 'package:citizen_lab/entries/note.dart';

class TextPage extends StatefulWidget {
  final Key key;
  final Note note;
  final String projectTitle;

  TextPage({
    this.key,
    @required this.note,
    @required this.projectTitle,
  }) : super(key: key);

  @override
  _TextPageState createState() => _TextPageState();
}

class _TextPageState extends State<TextPage> {
  final _globalKey = GlobalKey<ScaffoldState>();
  final _titleEditingController = TextEditingController();
  final _descEditingController = TextEditingController();
  final _noteDb = ProjectDatabaseProvider();

  ThemeChanger _themeChanger;
  bool _darkModeEnabled = false;
  Timer _timer;
  String _title;
  String _createdAt;
  String _timeString;

  @override
  void initState() {
    _timeString = dateFormatted();
    _timer = Timer.periodic(Duration(seconds: 1), (_) => _getTime());

    if (widget.note != null) {
      _titleEditingController.text = widget.note.title;
      _title = _titleEditingController.text;
      _descEditingController.text = widget.note.description;
      _createdAt = widget.note.dateCreated;
    } else {
      _createdAt = dateFormatted();
    }

    _titleEditingController.addListener(() {
      setState(() {
        _title = _titleEditingController.text;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _titleEditingController.dispose();
    _descEditingController.dispose();
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
    _themeChanger = Provider.of<ThemeChanger>(context);
    _checkIfDarkModeEnabled();

    return Scaffold(
      key: _globalKey,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFabs(),
    );
  }

  Widget _buildAppBar() {
    final back = 'Zurück';
    final noteType = 'Textnotiz';

    return AppBar(
      elevation: 4.0,
      leading: IconButton(
        tooltip: back,
        icon: Icon(Icons.arrow_back),
        onPressed: () => _saveNote(),
      ),
      title: GestureDetector(
        onDoubleTap: () => _enableDarkMode(),
        child: Tooltip(
          message: noteType,
          child: Text((_title != null) ? _title : noteType),
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.share),
          onPressed: () => _shareContent(),
        ),
        IconButton(
          icon: Icon(Icons.info_outline),
          onPressed: () => _setInfoPage(),
        ),
        IconButton(
          icon: Icon(Icons.home),
          onPressed: () => _backToHomePage(),
        ),
      ],
    );
  }

  void _checkIfDarkModeEnabled() {
    final ThemeData theme = Theme.of(context);
    theme.brightness == appDarkTheme().brightness
        ? _darkModeEnabled = true
        : _darkModeEnabled = false;
  }

  void _enableDarkMode() {
    _darkModeEnabled
        ? _themeChanger.setTheme(appLightTheme())
        : _themeChanger.setTheme(appDarkTheme());
  }

  void _shareContent() {
    String fullContent =
        _titleEditingController.text + '\n' + _descEditingController.text;
    Share.share(fullContent);
  }

  void _backToHomePage() {
    final String cancel = 'Notiz abbrechen und zur Hauptseite zurückkehren?';

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
  }

  void _setInfoPage() {
    Navigator.pushNamed(
      context,
      RouteGenerator.infoPage,
      arguments: {
        'title': 'Text-Info',
        'tabLength': 3,
        'tabs': textTabList,
        'tabChildren': textSingleChildScrollViewList,
      },
    );
  }

  Widget _buildBody() {
    final created = 'Erstellt am';
    final title = 'Titel';
    final titleHere = 'Titel hier';
    final content = 'Inhalt';
    final contentHere = 'Inhalt hier';

    return WillPopScope(
      onWillPop: () => _saveNote(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 88.0),
        child: Column(
          children: <Widget>[
            Card(
              margin: const EdgeInsets.only(
                top: 8.0,
                left: 8.0,
                right: 8.0,
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
                      '$created: $_createdAt',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8.0),
            Card(
              margin: const EdgeInsets.only(
                bottom: 8.0,
                left: 8.0,
                right: 8.0,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '$title:',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextFormField(
                      controller: _titleEditingController,
                      keyboardType: TextInputType.text,
                      maxLength: 50,
                      maxLines: 2,
                      style: TextStyle(fontSize: 16.0),
                      decoration: InputDecoration(
                        hintText: '$titleHere.',
                      ),
                    ),
                    SizedBox(height: 42.0),
                    Text(
                      '$content:',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextFormField(
                      controller: _descEditingController,
                      keyboardType: TextInputType.text,
                      maxLength: 500,
                      maxLines: 20,
                      style: TextStyle(fontSize: 16.0),
                      decoration: InputDecoration(
                        hintText: '$contentHere.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _saveNote() async {
    if (widget.note == null) {
      Note newNote = Note(
        widget.projectTitle,
        'Text',
        _titleEditingController.text.isEmpty
            ? 'Textnotiz'
            : _titleEditingController.text,
        _descEditingController.text,
        '',
        null,
        null,
        _createdAt,
        dateFormatted(),
      );
      await _noteDb.insertNote(note: newNote);
    } else {
      _updateNote(widget.note);
    }
    Navigator.pop(context, true);
  }

  void _updateNote(Note note) async {
    Note newNote = Note.fromMap({
      ProjectDatabaseProvider.columnNoteId: note.id,
      ProjectDatabaseProvider.columnNoteProject: note.project,
      ProjectDatabaseProvider.columnNoteType: note.type,
      ProjectDatabaseProvider.columnNoteTitle:
          _titleEditingController.text.isEmpty
              ? 'Textnotiz'
              : _titleEditingController.text,
      ProjectDatabaseProvider.columnNoteDescription:
          _descEditingController.text,
      ProjectDatabaseProvider.columnNoteContent: '',
      ProjectDatabaseProvider.columnNoteTableColumn: null,
      ProjectDatabaseProvider.columnNoteTableRow: null,
      ProjectDatabaseProvider.columnNoteCreatedAt: note.dateCreated,
      ProjectDatabaseProvider.columnNoteUpdatedAt: dateFormatted(),
    });
    await _noteDb.updateNote(newNote: newNote);
  }

  Widget _buildFabs() {
    return Padding(
      padding: const EdgeInsets.only(left: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FloatingActionButton(
            heroTag: null,
            child: Icon(Icons.keyboard_arrow_up),
            onPressed: () => _openModalBottomSheet(),
          ),
          FloatingActionButton(
            heroTag: null,
            child: Icon(Icons.remove),
            onPressed: () => _refreshTextFormFields(),
          ),
          FloatingActionButton(
            heroTag: null,
            child: Icon(Icons.content_copy),
            onPressed: () => _copyContent(),
          ),
        ],
      ),
    );
  }

  void _refreshTextFormFields() {
    final String textDeleted = 'Text gelöscht';

    if (_titleEditingController.text.isNotEmpty) {
      _titleEditingController.clear();
    }

    if (_descEditingController.text.isNotEmpty) {
      _descEditingController.clear();
    }

    _globalKey.currentState.showSnackBar(
      _buildSnackBar(text: '$textDeleted.'),
    );
  }

  void _copyContent() {
    final copyContent = 'Inhalt kopiert';
    final copyNotPossible = 'Kein Inhalt zum kopieren';

    if (_titleEditingController.text.isNotEmpty &&
        _descEditingController.text.isNotEmpty) {
      String fullContent =
          _titleEditingController.text + '\n' + _descEditingController.text;
      _setClipboard(fullContent, '$copyContent.');
    } else {
      _globalKey.currentState.showSnackBar(
        _buildSnackBar(text: '$copyNotPossible.'),
      );
    }
  }

  void _openModalBottomSheet() {
    List<ExperimentItem> experimentItems = [
      ExperimentItem('', Icons.keyboard_arrow_down),
      ExperimentItem('A', Icons.add),
      ExperimentItem('B', Icons.add),
      ExperimentItem('C', Icons.add),
      ExperimentItem('E', Icons.add),
      ExperimentItem('F', Icons.add),
      ExperimentItem('G', Icons.add),
      ExperimentItem('H', Icons.add),
      ExperimentItem('I', Icons.add),
      ExperimentItem('J', Icons.add),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              experimentItem.name,
                              style: TextStyle(fontSize: 16.0),
                            ),
                            Icon(experimentItem.icon, size: 20.0),
                          ],
                        )
                      : Center(
                          child: Icon(experimentItem.icon, size: 28.0),
                        ),
                ),
              ),
              Divider(height: 1.0, color: Colors.black),
            ],
          ),
        ),
        onTap: () {
          if (experimentItem.name.isNotEmpty) {
            _descEditingController.text += experimentItem.name;
          }
          Navigator.pop(context);
        },
      ),
    );
  }

  void _setClipboard(String text, String snackText) {
    Clipboard.setData(
      ClipboardData(text: text),
    );

    _globalKey.currentState.showSnackBar(
      _buildSnackBar(text: snackText),
    );
  }

  Widget _buildSnackBar({@required String text}) {
    return SnackBar(
      backgroundColor: Colors.black.withOpacity(0.5),
      duration: Duration(milliseconds: 500),
      content: Text(
        text,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
