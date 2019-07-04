import 'dart:async';

import 'package:citizen_lab/custom_widgets/no_yes_dialog.dart';
import 'package:citizen_lab/custom_widgets/simple_timer_dialog.dart';
import 'package:citizen_lab/custom_widgets/title_desc_widget.dart';
import 'package:citizen_lab/database/database_provider.dart';
import 'package:citizen_lab/themes/theme_changer_provider.dart';
import 'package:citizen_lab/utils/date_formater.dart';
import 'package:citizen_lab/utils/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../note.dart';

class WeblinkPage extends StatefulWidget {
  final Note note;
  final int projectRandom;

  WeblinkPage({
    @required this.note,
    @required this.projectRandom,
  });

  @override
  _WeblinkPageState createState() => _WeblinkPageState();
}

class _WeblinkPageState extends State<WeblinkPage> {
  static int _initialPage = 1;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _titleEditingController = TextEditingController();
  final _descEditingController = TextEditingController();
  final _pageController = PageController(initialPage: _initialPage);
  final _webViewController = Completer<WebViewController>();
  final _key = UniqueKey();
  final _noteDb = DatabaseProvider.db;

  ThemeChangerProvider _themeChanger;
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
        if (_titleEditingController.text.isNotEmpty) {
          _title = _titleEditingController.text;
        }
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _titleEditingController.dispose();
    _descEditingController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _themeChanger = Provider.of<ThemeChangerProvider>(context);
    //_themeChanger.checkIfDarkModeEnabled(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFabs(),
    );
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
        onPanStart: (_) => _themeChanger.setTheme(),
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
    final double screenWidth = MediaQuery.of(context).size.width;

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

  Widget _buildBody2() {
    final double screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: WillPopScope(
        onWillPop: () => _saveNote(),
        child: Stack(
          children: <Widget>[
            (_initialPage == 1)
                ? Positioned(
                    top: 0.0,
                    right: 0.0,
                    child: Container(
                      width: screenWidth / 2,
                      height: 2.0,
                      color: Colors.grey,
                    ),
                  )
                : Positioned(
                    top: 0.0,
                    left: 0.0,
                    child: Container(
                      width: screenWidth / 2,
                      height: 2.0,
                      color: Colors.grey,
                    ),
                  ),
            PageView(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _initialPage = page;
                });
              },
              children: <Widget>[
                TitleDescWidget(
                  title: _title,
                  createdAt: _createdAt,
                  titleEditingController: _titleEditingController,
                  descEditingController: _descEditingController,
                  onWillPop: () {},
                  titleChanger: null,
                  titleBloc: null,
                ),
                WebView(
                  key: _key,
                  javascriptMode: JavascriptMode.unrestricted,
                  initialUrl: _url,
                  onWebViewCreated: (WebViewController webViewController) {
                    _webViewController.complete(webViewController);
                  },
                ),
              ],
            ),
          ],
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
          /*FloatingActionButton(
            heroTag: null,
            child: Icon(Icons.content_copy),
            onPressed: () => _copyContent(),
          ),*/
          _buildWebView(),
        ],
      ),
    );
  }

  Widget _buildWebView() {
    return FutureBuilder<WebViewController>(
      future: _webViewController.future,
      builder: (
        BuildContext context,
        AsyncSnapshot<WebViewController> snapshot,
      ) {
        if (snapshot.hasData) {
          return FloatingActionButton(
            heroTag: null,
            child: Icon(Icons.content_copy),
            onPressed: () async {
              //var url = await _webViewController.data.currentUrl;
              _url = await snapshot.data.currentUrl();
              _copyContent();
            },
          );
        }
      },
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
    Clipboard.setData(ClipboardData(text: text));

    _scaffoldKey.currentState.showSnackBar(
      _buildSnackBar(text: snackText),
    );
  }

  Future<void> _showEditDialog() async {
    final String oldTitle = _title;

    await showDialog(
      context: context,
      builder: (context) => SimpleTimerDialog(
            createdAt: _createdAt,
            textEditingController: _titleEditingController,
            descEditingController: _descEditingController,
            descExists: true,
            onPressedClose: () {
              _titleEditingController.text = oldTitle;
              Navigator.pop(context);
            },
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
        Note note = Note(
          //widget.projectTitle,
          widget.projectRandom,
          'Verlinkung',
          _titleEditingController.text,
          _descEditingController.text,
          _url,
          _createdAt,
          dateFormatted(),
          0,
        );
        //await _noteDb.insertNote(note: newNote);
        Navigator.pop(context, note);
      } else {
        _updateNote(widget.note);
      }
      //Navigator.pop(context, true);
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
      DatabaseProvider.columnNoteId: note.id,
      //ProjectDatabaseHelper.columnProjectId: note.projectId,
      DatabaseProvider.columnProjectRandom: note.projectRandom,
      DatabaseProvider.columnNoteType: note.type,
      DatabaseProvider.columnNoteTitle: _titleEditingController.text,
      DatabaseProvider.columnNoteDescription: _descEditingController.text,
      DatabaseProvider.columnNoteContent: _url,
      DatabaseProvider.columnNoteCreatedAt: note.dateCreated,
      DatabaseProvider.columnNoteUpdatedAt: dateFormatted(),
      DatabaseProvider.columnNoteEdited: 1,
    });
    //await _noteDb.updateNote(newNote: newNote);
    Navigator.pop(context, newNote);
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
      backgroundColor: Colors.black87,
      duration: Duration(seconds: 3),
      content: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 8.0),
          Expanded(
            flex: 1,
            child: RaisedButton(
              color: Colors.green,
              child: Text(no),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
              ),
              onPressed: () => _scaffoldKey.currentState.hideCurrentSnackBar(),
            ),
          ),
          SizedBox(width: 8.0),
          Expanded(
            flex: 1,
            child: RaisedButton(
              color: Colors.red,
              child: Text(yes),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
              ),
              onPressed: onPressed,
            ),
          ),
        ],
      ),
    );
  }
}
