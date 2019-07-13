import 'dart:io';

import 'package:citizen_lab/themes/theme_changer_provider.dart';
import 'package:citizen_lab/utils/date_formater.dart';
import 'package:citizen_lab/utils/route_generator.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:provider/provider.dart';

import 'custom_widgets/no_yes_dialog.dart';
import 'custom_widgets/simple_timer_dialog.dart';
import 'database/database_provider.dart';
import 'entries/image/image_info_page_data.dart';
import 'entries/note.dart';

class AudioRecordPage extends StatefulWidget {
  final Note note;
  final int projectRandom;

  AudioRecordPage({
    this.note,
    this.projectRandom,
  });

  @override
  _AudioRecordPageState createState() => _AudioRecordPageState();
}

class _AudioRecordPageState extends State<AudioRecordPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _titleEditingController = TextEditingController();
  final _descEditingController = TextEditingController();
  final flutterSound = FlutterSound();

  ThemeChangerProvider _themeChanger;

  String _audioPath = '';
  String _title;
  String _createdAt;

  Icon _icon = Icon(Icons.mic, size: 56.0);
  Icon _icon2 = Icon(Icons.play_arrow);
  bool _isRecording = false;
  bool _recordFinished = false;
  bool _recordPlaying = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleEditingController.text = widget.note.title;
      _title = _titleEditingController.text;
      _descEditingController.text = widget.note.description;
      _audioPath = widget.note.content;
      _createdAt = widget.note.dateCreated;
    } else {
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
    _themeChanger = Provider.of<ThemeChangerProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFabs(),
    );
  }

  Widget _buildAppBar() {
    final String back = 'Zurück';
    final String noteType = 'Audioaufzeichnung';

    return AppBar(
      leading: IconButton(
        tooltip: back,
        icon: Icon(Icons.arrow_back),
        onPressed: () => _saveNote(),
      ),
      title: GestureDetector(
        onPanStart: (_) => _themeChanger.setTheme(),
        child: Container(
          width: double.infinity,
          child: Tooltip(
            message: noteType,
            child: Text(_title != null ? _title : noteType),
          ),
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

  void _shareContent() async {
    if (_audioPath.isNotEmpty) {
      String title = _titleEditingController.text.isEmpty
          ? 'Audioaufzeichnung'
          : _titleEditingController.text;

      final ByteData bytes = await rootBundle.load(_audioPath);

      await Share.file(
        'audio',
        '$title.mp3',
        bytes.buffer.asUint8List(),
        'audio/mp3',
        text: title,
      );
    } else {
      _scaffoldKey.currentState.showSnackBar(
        _buildSnackBar(text: 'Bitte eine Audioaufnahme erstellen.'),
      );
    }
  }

  void _setInfoPage() {
    Navigator.pushNamed(
      context,
      RouteGenerator.infoPage,
      arguments: {
        'title': 'Audio-Info',
        'tabLength': 2,
        'tabs': imageTabList,
        'tabChildren': imageSingleChildScrollViewList,
      },
    );
  }

  void _backToHomePage() {
    final String cancel = 'Notiz abbrechen und zur Hauptseite zurückkehren?';
    showDialog(
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

  Widget _buildFabs() {
    final String editTitleAndDesc = 'Titel und Beschreibung editieren';
    return Padding(
      padding: const EdgeInsets.only(left: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FloatingActionButton(
            heroTag: null,
            tooltip: '$editTitleAndDesc.',
            child: Icon(Icons.description),
            onPressed: () => _showEditDialog(),
          ),
          FloatingActionButton(
            heroTag: null,
            tooltip: '',
            child: _icon2,
            onPressed: () {
              _buildStartStopAudioButton();
            },
          ),
        ],
      ),
    );
  }

  void _showEditDialog() {
    final String oldTitle = _title;
    showDialog(
      context: context,
      builder: (context) {
        return SimpleTimerDialog(
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
        );
      },
    );
  }

  Widget _buildBody() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        //child: _setInfoWidgets(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 96.0,
              width: 96.0,
              child: FloatingActionButton(
                child: _icon,
                onPressed: _buildRecordButton,
              ),
            ),
            SizedBox(height: 42.0),
            _audioPath.isNotEmpty
                ? Text(
                    'Audioaufzeichnungsort:\n$_audioPath',
                    style: TextStyle(fontSize: 16.0),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget _setInfoWidgets() {
    if (_recordFinished) {
      return Text('Aufzeichnungsort: $_audioPath');
    } else {
      return Container(
        height: 100.0,
        width: 100.0,
        child: FloatingActionButton(
          child: _icon,
          onPressed: _buildRecordButton,
        ),
      );
    }
  }

  void _buildStartStopAudioButton() {
    if (_audioPath.isNotEmpty) {
      if (_recordPlaying) {
        setState(() {
          _icon2 = Icon(Icons.play_arrow);
        });
        _stopAudio();
      } else {
        setState(() {
          _icon2 = Icon(Icons.pause);
        });
        _playAudio();
      }
      setState(() => _recordPlaying = !_recordPlaying);
    } else {
      _scaffoldKey.currentState.showSnackBar(
        _buildSnackBar(text: 'Keine Aufnahme vorhanden.'),
      );
    }
  }

  void _playAudio() async => await flutterSound.startPlayer(_audioPath);

  void _stopAudio() async => await flutterSound.stopPlayer();

  void _buildRecordButton() {
    if (_isRecording) {
      setState(() {
        _icon = Icon(Icons.mic, size: 56.0);
      });
      _stopRecord();
      _recordFinished = true;
    } else {
      setState(() {
        _icon = Icon(Icons.mic_none, size: 56.0);
      });
      _startRecord();
    }
    setState(() => _isRecording = !_isRecording);
  }

  void _startRecord() async {
    final String title = _titleEditingController.text.isEmpty
        ? 'Audioaufnahme'
        : _titleEditingController.text;

    if (Platform.isAndroid) {
      _audioPath = '/sdcard/$title.mp3';
    } else if (Platform.isIOS) {
      _audioPath = '$title.mp3';
    }
    await flutterSound.startRecorder(_audioPath);
  }

  void _stopRecord() async {
    await flutterSound.stopRecorder();
  }

  Future<void> _saveNote() async {
    if (_audioPath.isNotEmpty) {
      if (widget.note == null) {
        Note note = Note(
          widget.projectRandom,
          'Audio',
          _titleEditingController.text.isEmpty
              ? 'Audioaufnahme'
              : _titleEditingController.text,
          _descEditingController.text,
          _audioPath,
          _createdAt,
          dateFormatted(),
          0,
          0xFFFFFFFF,
          0xFF000000,
        );
        Navigator.pop(context, note);
      } else {
        _updateNote(widget.note);
      }
    } else {
      _scaffoldKey.currentState.showSnackBar(
        _buildSnackBarWithButton(
          text: 'Bitte einen Titel eingeben\nNotiz abbrechen?',
          onPressed: () => Navigator.pop(context),
        ),
      );
    }
  }

  void _updateNote(Note note) {
    Note newNote = Note.fromMap({
      DatabaseProvider.columnNoteId: note.id,
      DatabaseProvider.columnProjectRandom: note.projectRandom,
      DatabaseProvider.columnNoteType: note.type,
      DatabaseProvider.columnNoteTitle: _titleEditingController.text,
      DatabaseProvider.columnNoteDescription: _descEditingController.text,
      DatabaseProvider.columnNoteContent: _audioPath,
      DatabaseProvider.columnNoteCreatedAt: note.dateCreated,
      DatabaseProvider.columnNoteUpdatedAt: dateFormatted(),
      DatabaseProvider.columnNoteEdited: 1,
      DatabaseProvider.columnNoteCardColor: note.cardColor,
      DatabaseProvider.columnNoteCardTextColor: note.cardTextColor,
    });
    Navigator.pop(context, newNote);
  }

  Widget _buildSnackBar({@required String text}) {
    return SnackBar(
      backgroundColor: Colors.black87,
      duration: Duration(seconds: 3),
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
              child: Text('Nein'),
              color: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
              onPressed: () => _scaffoldKey.currentState.hideCurrentSnackBar(),
            ),
          ),
          SizedBox(width: 8.0),
          Expanded(
            flex: 1,
            child: RaisedButton(
              child: Text('Ja'),
              color: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
              onPressed: onPressed,
            ),
          ),
        ],
      ),
    );
  }
}
