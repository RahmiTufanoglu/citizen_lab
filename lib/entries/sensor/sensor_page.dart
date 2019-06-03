import 'dart:async';

import 'package:citizen_lab/database/project_database_provider.dart';
import 'package:citizen_lab/entries/sensor/sensor_info_page_data.dart';
import 'package:citizen_lab/utils/route_generator.dart';
import 'package:citizen_lab/custom_widgets/simple_timer_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share/share.dart';
import 'package:citizen_lab/entries/note.dart';
import 'package:citizen_lab/utils/date_formater.dart';
import 'package:citizen_lab/custom_widgets/no_yes_dialog.dart';

class SensorPage extends StatefulWidget {
  final Key key;
  final Note note;
  final String projectTitle;

  SensorPage({
    this.key,
    @required this.note,
    @required this.projectTitle,
  }) : super(key: key);

  @override
  _SensorPageState createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _titleEditingController = TextEditingController();
  final _descEditingController = TextEditingController();
  final _noteDb = ProjectDatabaseProvider();
  final _geolocator = Geolocator();

  var _position = Position(latitude: 0.0, longitude: 0.0, accuracy: 0.0);
  AnimationController _animationController;
  Animation<double> _animation;
  Timer _timer;
  String _title;
  String _createdAt;
  String _content;

  @override
  void initState() {
    if (!mounted) return;

    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        _getLocation().then((position) => _position = position);
      });
    });

    _animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController)
      ..addListener(() {});

    _animationController.forward();

    if (widget.note != null) {
      _titleEditingController.text = widget.note.title;
      _title = _titleEditingController.text;
      _descEditingController.text = widget.note.description;
      _content = widget.note.content;
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
    _animationController.dispose();
    _timer.cancel();
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
    final String back = 'Zurück';
    final String noteType = 'Sensornotiz';
    final String sharingNotPossible = 'Teilvorgang nicht möglich.';

    return AppBar(
      elevation: 4.0,
      title: Tooltip(
        message: noteType,
        child: Text(_title != null ? _title : noteType),
      ),
      leading: IconButton(
        tooltip: back,
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          _position == null ? Navigator.pop(context, false) : _saveNote();
        },
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.share),
          onPressed: () {
            if (_position != null) {
              Share.share(_content);
            } else {
              _scaffoldKey.currentState.showSnackBar(
                _buildSnackBar(text: sharingNotPossible),
              );
            }
          },
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

  void _setInfoPage() {
    Navigator.pushNamed(
      context,
      RouteGenerator.infoPage,
      arguments: {
        'title': 'Text-Info',
        'tabLength': 2,
        'tabs': sensorTabList,
        'tabChildren': sensorSingleChildScrollViewList,
      },
    );
  }

  void _backToHomePage() async {
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
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () {
        _position == null ? Navigator.pop(context, false) : _saveNote();
      },
      child: Stack(
        children: <Widget>[
          (_position != null)
              ? Center(
                  child: Text(
                    'Latitude: ${_position.latitude.toString()}\nLongitude: ${_position.longitude.toString()}\nAccuracy: ${_position.accuracy.toString()}',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    'Sensor nicht aktiv.',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
          Center(
            child: AnimatedContainer(
              duration: Duration(seconds: 1),
              height: _animation.value * screenHeight,
              width: _animation.value * screenWidth,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _content != null ? 'Alte Location:\n$_content' : '',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
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
            onPressed: () => _showDialogEditImage(),
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

  Future<Position> _getLocation() async {
    Position currentPosition;
    try {
      currentPosition = await _geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
    } catch (error) {
      currentPosition = null;
    }
    return currentPosition;
  }

  Future<void> _showDialogEditImage() async {
    await showDialog(
      context: context,
      builder: (context) {
        return SimpleTimerDialog(
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
          onPressedUpdate: () {
            setState(() {
              _title = _titleEditingController.text;
            });

            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _copyContent() {
    final copyContent = 'Inhalt kopiert';
    final copyNotPossible = 'Kein Inhalt zum kopieren';

    if (_content != null) {
      _setClipboard(_content, '$copyContent.');
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

  Future<void> _saveNote() async {
    if (widget.note == null) {
      Note newNote = Note(
        widget.projectTitle,
        'Sensor',
        _titleEditingController.text.isEmpty
            ? 'Sensornotiz'
            : _titleEditingController.text,
        _descEditingController.text,
        'Latitude: ${_position.latitude.toString()}\nLongitude: ${_position.longitude.toString()}\nAccuracy: ${_position.accuracy.toString()}',
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
              ? 'Sensornotiz'
              : _titleEditingController.text,
      ProjectDatabaseProvider.columnNoteDescription:
          _descEditingController.text,
      ProjectDatabaseProvider.columnNoteContent:
          'Latitude: ${_position.latitude.toString()}\nLongitude: ${_position.longitude.toString()}\nAccuracy: ${_position.accuracy.toString()}',
      ProjectDatabaseProvider.columnNoteTableColumn: null,
      ProjectDatabaseProvider.columnNoteTableRow: null,
      ProjectDatabaseProvider.columnNoteCreatedAt: note.dateCreated,
      ProjectDatabaseProvider.columnNoteUpdatedAt: dateFormatted(),
    });
    await _noteDb.updateNote(newNote: newNote);
  }

  Widget _buildSnackBar({@required String text}) {
    return SnackBar(
      backgroundColor: Colors.black.withOpacity(0.5),
      duration: Duration(milliseconds: 500),
      content: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
