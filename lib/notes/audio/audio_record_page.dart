import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:citizen_lab/custom_widgets/simple_timer_dialog.dart';
import 'package:citizen_lab/database/database_helper.dart';
import 'package:citizen_lab/notes/image/image_info_page_data.dart';
import 'package:citizen_lab/notes/note.dart';
import 'package:citizen_lab/themes/theme_changer_provider.dart';
import 'package:citizen_lab/utils/date_formatter.dart';
import 'package:citizen_lab/utils/route_generator.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/ios_quality.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission/permission.dart';
import 'package:provider/provider.dart';

class AudioRecordPage extends StatefulWidget {
  final Note note;
  final String uuid;

  const AudioRecordPage({
    this.note,
    this.uuid,
  });

  @override
  _AudioRecordPageState createState() => _AudioRecordPageState();
}

class _AudioRecordPageState extends State<AudioRecordPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _titleEditingController = TextEditingController();
  final _descEditingController = TextEditingController();

  FlutterSound _flutterSound;

  String _audioPath = '';
  String _title = '';
  String _createdAt = '';

  Icon _iconBody = Icon(Icons.mic, size: 56.0);
  Icon _iconFab = Icon(Icons.play_arrow);
  bool _isRecording = false;
  bool _recordPlaying = false;

  @override
  void initState() {
    super.initState();
    //_setPermission();
    //Permission.openSettings();

    _flutterSound = FlutterSound();

    if (widget.note != null) {
      _titleEditingController.text = widget.note.title;
      _title = _titleEditingController.text;
      _descEditingController.text = widget.note.description;
      _audioPath = widget.note.filePath;
      _createdAt = widget.note.createdAt;
    } else {
      _titleEditingController.text = 'Audioaufzeichnung';
      _title = _titleEditingController.text;
      _createdAt = dateFormatted();
    }

    _setPlatformPath();

    _titleEditingController.addListener(() {
      setState(() => _title = _titleEditingController.text);
    });
  }

  Future<void> _setPlatformPath() async {
    /*if (Platform.isAndroid) {
      _audioPath = '/sdcard/$_title.mp3';
    } else if (Platform.isIOS) {
      _audioPath = '$_title.mp3';
    }*/

    _audioPath = await _localPath(_title);
  }

  Future<String> _localPath(String title) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$title.mp3';
    return path;
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
    const String back = 'Zurück';
    const String noteType = 'Audioaufzeichnung';

    return AppBar(
      leading: IconButton(
        tooltip: back,
        icon: Icon(Icons.arrow_back),
        onPressed: () => _saveNote(),
      ),
      title: Consumer<ThemeChangerProvider>(
        builder: (
          BuildContext context,
          ThemeChangerProvider themeChangerProvider,
          Widget child,
        ) {
          return GestureDetector(
            onPanStart: (_) => themeChangerProvider.setTheme(),
            child: Container(
              width: double.infinity,
              child: Tooltip(
                message: noteType,
                //child: Text(_title != null ? _title : noteType),
                child: Text(_title ?? noteType),
              ),
            ),
          );
        },
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
      ],
    );
  }

  Future<void> _shareContent() async {
    if (_audioPath.isNotEmpty) {
      final ByteData bytes = await rootBundle.load(_audioPath);
      final Uint8List uint8List = bytes.buffer.asUint8List();

      await Share.file(
        'audio',
        '$_title.mp3',
        uint8List,
        'audio/mp3',
        text: _title,
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
      CustomRoute.infoPage,
      arguments: {
        'title': 'Audio-Info',
        'tabLength': 2,
        'tabs': imageTabList,
        'tabChildren': imageSingleChildScrollViewList,
      },
    );
  }

  Widget _buildFabs() {
    const String editTitleAndDesc = 'Titel und Beschreibung editieren';
    return Padding(
      padding: const EdgeInsets.only(left: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FloatingActionButton(
            heroTag: null,
            tooltip: '$editTitleAndDesc.',
            onPressed: () => _showEditDialog(),
            child: Icon(Icons.description),
          ),
          FloatingActionButton(
            heroTag: null,
            tooltip: '',
            onPressed: () => _buildStartStopAudioButton(),
            child: _iconFab,
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
          onPressedUpdate: () {
            _setPlatformPath();
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Widget _buildBody() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 96.0,
              width: 96.0,
              child: FloatingActionButton(
                onPressed: _buildRecordButton,
                child: _iconBody,
              ),
            ),
            const SizedBox(height: 24.0),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                ),
                children: [
                  TextSpan(
                    text: 'Audioaufzeichnungsort:\n',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: _audioPath),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _buildStartStopAudioButton() {
    if (_audioPath.isNotEmpty) {
      if (_recordPlaying) {
        setState(() => _iconFab = Icon(Icons.play_arrow));
        _stopAudio();
      } else {
        setState(() => _iconFab = Icon(Icons.pause));
        _playAudio();
      }
      setState(() => _recordPlaying = !_recordPlaying);
    } else {
      _scaffoldKey.currentState.showSnackBar(
        _buildSnackBar(text: 'Keine Aufnahme vorhanden.'),
      );
    }
  }

  Future<void> _playAudio() async => await _flutterSound.startPlayer(_audioPath);

  Future<void> _stopAudio() async {
    try {
      await _flutterSound.stopPlayer();
    } on Exception catch (e) {
      print(e);
    }
  }

  List<Permissions> _permissions;

  Future<void> _setPermission() async {
    _permissions = await Permission.getPermissionsStatus([PermissionName.Microphone, PermissionName.Storage]);
    await Permission.requestPermissions([PermissionName.Microphone, PermissionName.Storage]);
  }

  Future<void> _buildRecordButton() async {
    //if (!await _checkIfFileExists()) {
    /*for (int i = 0; i < _permissions.length; i++) {
      print('====>>>>>>>>>>>> ${_permissions[i].toString()}');
    }*/
    //_setPermission();

    if (_isRecording) {
      setState(() {
        _iconBody = Icon(Icons.mic, size: 56.0);
      });
      await _stopRecord();
    } else {
      setState(() {
        _iconBody = Icon(Icons.mic_none, size: 56.0);
      });
      //_startRecord().then(null, onError: (e) {}).catchError(_setPermission);
      await _startRecord();
    }
    setState(() => _isRecording = !_isRecording);
    /*} else {
      _scaffoldKey.currentState.showSnackBar(
        _buildSnackBar(
          text:
              'Datei mit aktuellen Titel ist vergeben.\nBitte einen anderen Titel wählen.',
        ),
      );
    }*/
  }

  Future<bool> _checkIfFileExists() async {
    final File file = File(_audioPath);
    //if (await file.exists()) {
    return file.existsSync() ? true : false;
  }

  Future<void> _checkIfTitleIsAlreadyTaken2() async {
    //FileSystemEntity.typeSync(_audioPath) != FileSystemEntityType.notFound;
    final File file = File(_audioPath);
    int i = 2;
    while (file.existsSync()) {
      _title = '$_title ${i++}';
      //_title = _title + ' ' + '${i++}'.toString();
      if (!file.existsSync()) break;
    }
  }

  Random random = Random();

  int next(int min, int max) => min + random.nextInt(max - min);

  Future _startRecord() async {
    // TODO: catchError
    await _flutterSound.startRecorder(
      _audioPath,
      bitRate: 320,
      iosQuality: IosQuality.HIGH,
    );

    /*Future.delayed(Duration(milliseconds: 500), () {
      flutterSound.startRecorder(
        _audioPath,
        bitRate: 320,
        iosQuality: IosQuality.HIGH,
      );
    }).then((value) {
      //
    }).catchError((error) {
      //
    });*/
  }

  Future<void> _stopRecord() async {
    try {
      await _flutterSound.stopRecorder();
    } on RecorderStoppedException catch (e) {
      print(e);
    }
  }

  Future<void> _saveNote() async {
    if (_audioPath.isNotEmpty) {
      if (widget.note == null) {
        final Note note = Note(
          widget.uuid,
          'Audio',
          _titleEditingController.text,
          _descEditingController.text,
          _audioPath,
          _createdAt,
          dateFormatted(),
          0,
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
    final Note newNote = Note.fromMap({
      DatabaseHelper.columnNoteId: note.id,
      DatabaseHelper.columnProjectUuid: note.uuid,
      DatabaseHelper.columnNoteType: note.type,
      DatabaseHelper.columnNoteTitle: _titleEditingController.text,
      DatabaseHelper.columnNoteDescription: _descEditingController.text,
      DatabaseHelper.columnNoteContent: _audioPath,
      DatabaseHelper.columnNoteCreatedAt: note.createdAt,
      DatabaseHelper.columnNoteUpdatedAt: dateFormatted(),
      DatabaseHelper.columnNoteIsFirstTime: 1,
      DatabaseHelper.columnNoteIsEdited: 1,
      DatabaseHelper.columnNoteCardColor: note.cardColor,
      DatabaseHelper.columnNoteCardTextColor: note.cardTextColor,
    });
    Navigator.pop(context, newNote);
  }

  Widget _buildSnackBar({@required String text}) {
    return SnackBar(
      backgroundColor: Colors.black87,
      duration: const Duration(seconds: 3),
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
      duration: const Duration(seconds: 3),
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
          const SizedBox(width: 8.0),
          Expanded(
            flex: 1,
            child: _buildRaisedButton(
              onPressed: () => _scaffoldKey.currentState.hideCurrentSnackBar(),
              text: 'Nein',
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            flex: 1,
            child: _buildRaisedButton(
              onPressed: onPressed,
              text: 'Ja',
            ),
          ),
        ],
      ),
    );
  }
}

RaisedButton _buildRaisedButton({
  @required GestureTapCallback onPressed,
  @required String text,
}) {
  return RaisedButton(
    color: Colors.red,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
    ),
    onPressed: onPressed,
    child: Text(text),
  );
}

enum PermissionStatus { allow, deny, notDecided, notAgain, whenInUse, always }
