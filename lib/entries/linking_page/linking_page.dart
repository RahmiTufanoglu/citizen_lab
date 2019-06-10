import 'dart:async';

import 'package:citizen_lab/custom_widgets/no_yes_dialog.dart';
import 'package:citizen_lab/custom_widgets/simple_timer_dialog.dart';
import 'package:citizen_lab/database/project_database_helper.dart';
import 'package:citizen_lab/themes/theme.dart';
import 'package:citizen_lab/themes/theme_changer.dart';
import 'package:citizen_lab/utils/date_formater.dart';
import 'package:citizen_lab/utils/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../note.dart';

class LinkingPage extends StatefulWidget {
  final key;
  final Note note;
  final String projectTitle;

  LinkingPage({
    this.key,
    @required this.note,
    @required this.projectTitle,
  }) : super(key: key);

  @override
  _LinkingPageState createState() => _LinkingPageState();
}

class _LinkingPageState extends State<LinkingPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _titleEditingController = TextEditingController();
  final _descEditingController = TextEditingController();
  final _webViewController = Completer<WebViewController>();
  final _key = UniqueKey();
  final _noteDb = ProjectDatabaseHelper();

  ThemeChanger _themeChanger;
  bool _darkModeEnabled = false;
  String _url = 'https://www.google.de';
  String _title;
  String _createdAt;

  @override
  void initState() {
    if (widget.note != null) {
      _titleEditingController.text = widget.note.title;
      _title = _titleEditingController.text;
      _descEditingController.text = widget.note.description;
      _url = widget.note.content;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _checkIfDarkModeEnabled();

    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFabs(),
    );
  }

  void _checkIfDarkModeEnabled() {
    _themeChanger = Provider.of<ThemeChanger>(context);
    final ThemeData theme = Theme.of(context);
    theme.brightness == appDarkTheme().brightness
        ? _darkModeEnabled = true
        : _darkModeEnabled = false;
  }

  Widget _buildAppBar() {
    final String back = 'Zurück';
    final String linking = 'Linking';

    return AppBar(
      leading: IconButton(
        tooltip: back,
        icon: Icon(Icons.arrow_back),
        onPressed: _saveNote,
      ),
      title: GestureDetector(
        onPanStart: (_) => _enableDarkMode(),
        child: Container(
          width: double.infinity,
          child: Tooltip(
            message: linking,
            child: Text(linking),
          ),
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.share),
          onPressed: () => Share.share(_url),
        ),
        IconButton(
          icon: Icon(Icons.home),
          onPressed: () => _backToHomePage(),
        ),
      ],
    );
  }

  void _enableDarkMode() {
    _darkModeEnabled
        ? _themeChanger.setTheme(appLightTheme())
        : _themeChanger.setTheme(appDarkTheme());
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

  Widget _buildBody() {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () => _saveNote(),
        child: WebView(
          key: _key,
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: _url,
          onWebViewCreated: (WebViewController webViewController) {
            _webViewController.complete(webViewController);
          },
        ),
      ),
    );
  }

  Widget _buildFabs() {
    return Padding(
      padding: const EdgeInsets.only(left: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FloatingActionButton(
            heroTag: null,
            child: Icon(Icons.description),
            onPressed: () => _showEditDialog(),
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

  void _copyContent() {
    final String copyContent = 'Inhalt kopiert';
    final String copyNotPossible = 'Kein Inhalt zum kopieren';

    if (_url.isNotEmpty) {
      _setClipboard(_url, '$copyContent.');
    } else {
      _scaffoldKey.currentState.showSnackBar(
        _buildSnackBar(text: '$copyNotPossible.'),
      );
    }
  }

  void _setClipboard(String text, String snackText) {
    Clipboard.setData(
      ClipboardData(text: text),
    );

    _scaffoldKey.currentState.showSnackBar(
      _buildSnackBar(text: snackText),
    );
  }

  Future<void> _showEditDialog() async {
    await showDialog(
      context: context,
      builder: (context) => SimpleTimerDialog(
            createdAt: _createdAt,
            textEditingController: _titleEditingController,
            descEditingController: _descEditingController,
            descExists: true,
            onPressedClose: () => Navigator.pop(context),
            onPressedClear: () {
              if (_titleEditingController.text.isNotEmpty) {
                _titleEditingController.clear();
              }

              if (_descEditingController.text.isNotEmpty) {
                _descEditingController.clear();
              }
            },
            onPressedUpdate: () => Navigator.pop(context),
          ),
    );
  }

  Future<void> _saveNote() async {
    if (_titleEditingController.text.isNotEmpty && _url.isNotEmpty) {
      if (widget.note == null) {
        Note newNote = Note(
          widget.projectTitle,
          'Verlinkung',
          _titleEditingController.text,
          _descEditingController.text,
          _url,
          _createdAt,
          dateFormatted(),
        );
        await _noteDb.insertNote(note: newNote);
      } else {
        _updateNote(widget.note);
      }
      Navigator.pop(context, true);
    } else {
      _scaffoldKey.currentState.showSnackBar(
        _buildSnackBarWithButton(
          text: 'Bitte einen Titel eingeben\nNotiz abbrechen?',
          onPressed: () => Navigator.pop(context),
        ),
      );
    }
  }

  Future<void> _updateNote(Note note) async {
    Note newNote = Note.fromMap({
      ProjectDatabaseHelper.columnNoteId: note.id,
      ProjectDatabaseHelper.columnNoteProject: note.project,
      ProjectDatabaseHelper.columnNoteType: note.type,
      ProjectDatabaseHelper.columnNoteTitle: _titleEditingController.text,
      ProjectDatabaseHelper.columnNoteDescription: _descEditingController.text,
      ProjectDatabaseHelper.columnNoteContent: _url,
      ProjectDatabaseHelper.columnNoteCreatedAt: note.dateCreated,
      ProjectDatabaseHelper.columnNoteUpdatedAt: dateFormatted(),
    });
    await _noteDb.updateNote(newNote: newNote);
  }

  Widget _buildSnackBar({@required String text}) {
    return SnackBar(
      backgroundColor: Colors.black.withOpacity(0.5),
      duration: Duration(seconds: 1),
      content: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSnackBarWithButton({
    @required String text,
    @required GestureTapCallback onPressed,
  }) {
    final String yes = 'Ja';
    final String no = 'Nein';

    return SnackBar(
      backgroundColor: Colors.black.withOpacity(0.5),
      duration: Duration(seconds: 3),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(flex: 1),
          RaisedButton(
            color: Colors.green,
            child: Text(no),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
            ),
            onPressed: () => _scaffoldKey.currentState.hideCurrentSnackBar(),
          ),
          Spacer(flex: 1),
          RaisedButton(
            color: Colors.red,
            child: Text(yes),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
            ),
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}
