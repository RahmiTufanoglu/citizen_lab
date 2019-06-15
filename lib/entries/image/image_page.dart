import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:citizen_lab/custom_widgets/no_yes_dialog.dart';
import 'package:citizen_lab/custom_widgets/set_title_widget.dart';
import 'package:citizen_lab/custom_widgets/simple_timer_dialog.dart';
import 'package:citizen_lab/database/project_database_helper.dart';
import 'package:citizen_lab/entries/note.dart';
import 'package:citizen_lab/themes/theme_changer_provider.dart';
import 'package:citizen_lab/utils/date_formater.dart';
import 'package:citizen_lab/utils/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

import 'image_info_page_data.dart';

class ImagePage extends StatefulWidget {
  final Key key;
  final Note note;
  final int projectRandom;

  ImagePage({
    this.key,
    this.note,
    this.projectRandom,
  }) : super(key: key);

  @override
  _ImagePageState createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _titleEditingController = TextEditingController();
  final _descEditingController = TextEditingController();
  final _noteDb = ProjectDatabaseHelper();

  ThemeChangerProvider _themeChanger;
  File _image;
  String _title;
  String _createdAt;

  @override
  void initState() {
    if (widget.note != null) {
      _titleEditingController.text = widget.note.title;
      _title = _titleEditingController.text;
      _descEditingController.text = widget.note.description;
      _image = File(widget.note.content);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _themeChanger = Provider.of<ThemeChangerProvider>(context);
    _themeChanger.checkIfDarkModeEnabled(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFabs(),
    );
  }

  Widget _buildAppBar() {
    final String back = 'Zurück';
    final String noteType = 'Bildnotiz';

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

  void _shareContent() {
    if (_image != null) {
      try {
        final channelName = 'rahmitufanoglu.citizenlab';
        final channel = MethodChannel('channel:$channelName.share/share');
        channel.invokeMethod('shareImage', '$_title');
      } catch (error) {
        print('Share error: $error');
        final String sharingNotPossible = 'Teilvorgang nicht möglich';
        _scaffoldKey.currentState
            .showSnackBar(_buildSnackBar('$sharingNotPossible.'));
      }
    } else {
      _scaffoldKey.currentState.showSnackBar(
        _buildSnackBarWithButton(
          text: 'Bitte ein Foto erstellen.\nFoto schießen?',
          onPressed: () => _createImage(),
        ),
      );
    }
  }

  void _setInfoPage() {
    Navigator.pushNamed(
      context,
      RouteGenerator.infoPage,
      arguments: {
        'title': 'Bild-Info',
        'tabLength': 2,
        'tabs': imageTabList,
        'tabChildren': imageSingleChildScrollViewList,
      },
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
    return SafeArea(
      child: Form(
        key: _formKey,
        autovalidate: true,
        child: WillPopScope(
          onWillPop: () => _saveNote(),
          child: Center(
            child: (_image != null && _image.path.isNotEmpty)
                ? PhotoView(
                    backgroundDecoration: BoxDecoration(),
                    minScale: PhotoViewComputedScale.contained * 0.5,
                    imageProvider: FileImage(_image),
                  )
                : Center(
                    child: Icon(
                      Icons.image,
                      color: Colors.grey,
                      size: 100.0,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildFabs() {
    final String editTitleAndDesc = 'Titel und Beschreibung editieren';
    final String getImage = 'Foto aus dem Ordner importieren';
    final String createImage = 'Foto erstellen';

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
          /*FloatingActionButton(
            heroTag: null,
            tooltip: '$getImage.',
            child: Icon(Icons.folder),
            onPressed: () async => await _getImage(false),
          ),*/
          FloatingActionButton(
            heroTag: null,
            tooltip: '$createImage.',
            child: Icon(Icons.camera_alt),
            onPressed: () => _createImage(),
          ),
        ],
      ),
    );
  }

  Future<void> _createImage() async {
    if (_image == null) {
      showDialog(
        context: context,
        builder: (_) {
          return SetTitleWidget(
            titleTextEditingController: _titleEditingController,
            onPressed: () async {
              Navigator.pop(context);
              await _getImage(true);
            },
          );
        },
      );
    } else {
      await _getImage(true);
    }
  }

  Future _getImage(bool isCamera) async {
    File image;

    isCamera
        ? image = await ImagePicker.pickImage(source: ImageSource.camera)
        : image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // using your method of getting an image
      //final File image = await ImagePicker.pickImage(source: imageSource);

      // getting a directory path for saving
      //final dir = await getApplicationDocumentsDirectory();

      // copy the file to a new path
      //final File newImage = await image.copy('${dir.path}/image1.png');

      //_test(image);
      // if image created ...

      setState(() {
        _image = image;
      });

      _createCachedImage();
    }
  }

  Future<void> _createCachedImage() async {
    final ByteData bytes = await rootBundle.load(_image.path);
    final Uint8List uint8List = bytes.buffer.asUint8List();
    final tempDir = await getTemporaryDirectory();
    File file = File('${tempDir.path}/$_title.jpg');
    //TODO
    //final dir = await getApplicationDocumentsDirectory();
    //filo = await image.copy('${dir.path}/image1.png');
    await file.create();
    file.writeAsBytesSync(uint8List);
  }

  Future<void> _saveNote() async {
    if (_titleEditingController.text.isNotEmpty && (_image != null)) {
      if (widget.note == null) {
        Note newNote = Note(
          //widget.projectTitle,
          widget.projectRandom,
          'Bild',
          _titleEditingController.text,
          _descEditingController.text,
          //(_image != null) ? _image.path : '',
          _image.path,
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
      ProjectDatabaseHelper.columnProjectRandom: note.projectRandom,
      //ProjectDatabaseHelper.columnNoteProject: note.project,
      ProjectDatabaseHelper.columnNoteType: note.type,
      ProjectDatabaseHelper.columnNoteTitle: _titleEditingController.text,
      ProjectDatabaseHelper.columnNoteDescription: _descEditingController.text,
      ProjectDatabaseHelper.columnNoteContent: _image.path,
      ProjectDatabaseHelper.columnNoteCreatedAt: note.dateCreated,
      ProjectDatabaseHelper.columnNoteUpdatedAt: dateFormatted(),
    });
    await _noteDb.updateNote(newNote: newNote);
  }

  Future<void> _showEditDialog() async {
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
              _createCachedImage();
              Navigator.pop(context);
            },
          );
        });
  }

  Widget _buildSnackBar(String text) {
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
            child: Text('Nein'),
            color: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
            ),
            onPressed: () => _scaffoldKey.currentState.hideCurrentSnackBar(),
          ),
          Spacer(flex: 1),
          RaisedButton(
            child: Text('Ja'),
            color: Colors.red,
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
