import 'dart:async';

import 'package:citizen_lab/custom_widgets/simple_timer_dialog.dart';
import 'package:citizen_lab/database/database_helper.dart';
import 'package:citizen_lab/themes/theme_changer_provider.dart';
import 'package:citizen_lab/utils/constants.dart';
import 'package:citizen_lab/utils/date_formatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../app_locations.dart';
import '../note.dart';

class WeblinkPage extends StatefulWidget {
  final Key key;
  final Note note;
  final String uuid;
  final String searchEngine;

  const WeblinkPage({
    @required this.note,
    @required this.uuid,
    @required this.searchEngine,
    this.key,
  }) : super(key: key);

  @override
  _WeblinkPageState createState() => _WeblinkPageState();
}

class _WeblinkPageState extends State<WeblinkPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _titleEditingController = TextEditingController();
  final _descEditingController = TextEditingController();
  final _webViewController = Completer<WebViewController>();
  final _uniqueKey = UniqueKey();

  String _url = '';
  String _title = '';
  String _createdAt = '';

  @override
  void initState() {
    super.initState();

    if (widget.note != null) {
      _titleEditingController.text = widget.note.title;
      _title = _titleEditingController.text;
      _descEditingController.text = widget.note.description;
      _url = widget.note.filePath;
      _createdAt = widget.note.createdAt;
    } else {
      _url = widget.searchEngine;
      _createdAt = dateFormatted();
    }

    _titleEditingController.addListener(() {
      setState(() => _title = _titleEditingController.text);
    });
  }

  @override
  void dispose() {
    _titleEditingController.dispose();
    _descEditingController.dispose();
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
  }

  Widget _buildAppBar() {
    return AppBar(
      leading: _saveOnBackWidget(),
      title: Consumer<ThemeChangerProvider>(
        builder: (
          BuildContext context,
          ThemeChangerProvider provider,
          Widget child,
        ) {
          return GestureDetector(
            onPanStart: (_) => provider.setTheme(),
            child: Container(
              width: double.infinity,
              child: Tooltip(
                message: Constants.webLink,
                child: const Text(Constants.webLink),
              ),
            ),
          );
        },
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.share),
          onPressed: () => Share.share(_url),
        ),
      ],
    );
  }

  Widget _saveOnBackWidget() {
    return FutureBuilder<WebViewController>(
      future: _webViewController.future,
      builder: (
        BuildContext context,
        AsyncSnapshot<WebViewController> snapshot,
      ) {
        return IconButton(
          tooltip: AppLocalizations.of(context).translate('back'),
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            _url = await snapshot.data.currentUrl();
            await _saveNote();
          },
        );
      },
    );
  }

  Widget _buildBody() {
    return FutureBuilder<WebViewController>(
      future: _webViewController.future,
      builder: (
        BuildContext context,
        AsyncSnapshot<WebViewController> snapshot,
      ) {
        return SafeArea(
          child: WillPopScope(
            onWillPop: () async {
              _url = await snapshot.data.currentUrl();
              await _saveNote();
              return false;
            },
            child: _buildWebView(),
          ),
        );
      },
    );
  }

  Widget _buildWebView() {
    return WebView(
      key: _uniqueKey,
      initialUrl: _url,
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController) {
        _webViewController.complete(webViewController);
      },
      onPageFinished: (String url) {
        debugPrint('$url finished loading.');
      },
    );
  }

  Widget _buildSnackBar({@required String text}) {
    return SnackBar(
      backgroundColor: Colors.black87,
      duration: const Duration(milliseconds: 500),
      content: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
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
            onPressed: () => _showEditDialog(),
            child: Icon(Icons.description),
          ),
          _buildPreviousUrlFab(),
          _buildCopyCurrentLinkFab(),
        ],
      ),
    );
  }

  Widget _buildPreviousUrlFab() {
    return FutureBuilder<WebViewController>(
      future: _webViewController.future,
      builder: (
        BuildContext context,
        AsyncSnapshot<WebViewController> snapshot,
      ) {
        return FloatingActionButton(
          heroTag: null,
          onPressed: () => _navigateToPreviousUrl(context, snapshot.data, goBack: true),
          child: Icon(Icons.arrow_back),
        );
      },
    );
  }

  Future<void> _navigateToPreviousUrl(
    BuildContext context,
    WebViewController controller, {
    bool goBack = false,
  }) async {
    final bool canNavigate = goBack ? await controller.canGoBack() : await controller.canGoForward();
    if (canNavigate) {
      goBack ? await controller.goBack() : await controller.goForward();
    } else {
      await controller.loadUrl(Constants.googleUrl);
    }
  }

  Widget _buildCopyCurrentLinkFab() {
    return FutureBuilder<WebViewController>(
      future: _webViewController.future,
      builder: (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
        if (snapshot.hasData) {
          return FloatingActionButton(
            heroTag: null,
            onPressed: () async {
              _url = await snapshot.data.currentUrl();
              _copyContent();
            },
            child: Icon(Icons.content_copy),
          );
        } else {
          return Container();
        }
      },
    );
  }

  void _copyContent() {
    const String copyContent = 'Inhalt kopiert';
    const String copyNotPossible = 'Kein Inhalt zum kopieren';

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

  void _showEditDialog() {
    final String oldTitle = _title;

    showDialog(
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
          _titleEditingController.clear();
          _descEditingController.clear();
        },
        onPressedUpdate: () => Navigator.pop(context),
      ),
    );
  }

  Future<void> _saveNote() async {
    if (_url.isNotEmpty) {
      if (widget.note == null) {
        final Note note = Note(
          widget.uuid,
          'Verlinkung',
          _titleEditingController.text.isEmpty ? 'Weblink' : _titleEditingController.text,
          _descEditingController.text,
          _url,
          _createdAt,
          dateFormatted(),
          0,
          0,
          0xFFFFFFFF,
          0xFF000000,
        );
        Navigator.pop(context, note);
      } else {
        await _updateNote(widget.note);
      }
    } else {
      /*_scaffoldKey.currentState.showSnackBar(
        _buildSnackBarWithButton(
          text: 'Bitte einen Titel eingeben\nNotiz abbrechen?',
          onPressed: () => Navigator.pop(context),
        ),
      );*/
    }
  }

  Future<void> _updateNote(Note note) async {
    final Note newNote = Note.fromMap({
      DatabaseHelper.columnNoteId: note.id,
      DatabaseHelper.columnProjectUuid: note.uuid,
      DatabaseHelper.columnNoteType: note.type,
      DatabaseHelper.columnNoteTitle: _titleEditingController.text,
      DatabaseHelper.columnNoteDescription: _descEditingController.text,
      DatabaseHelper.columnNoteContent: _url,
      DatabaseHelper.columnNoteCreatedAt: note.createdAt,
      DatabaseHelper.columnNoteUpdatedAt: dateFormatted(),
      DatabaseHelper.columnNoteIsFirstTime: 1,
      DatabaseHelper.columnNoteIsEdited: 0,
      DatabaseHelper.columnNoteCardColor: note.cardColor,
      DatabaseHelper.columnNoteCardTextColor: note.cardTextColor,
    });
    //await _noteDb.updateNote(newNote: newNote);
    Navigator.pop(context, newNote);
  }
}
