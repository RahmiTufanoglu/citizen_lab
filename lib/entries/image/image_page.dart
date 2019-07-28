import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:citizen_lab/custom_widgets/no_yes_dialog.dart';
import 'package:citizen_lab/custom_widgets/set_title_widget.dart';
import 'package:citizen_lab/custom_widgets/simple_timer_dialog.dart';
import 'package:citizen_lab/database/database_provider.dart';
import 'package:citizen_lab/entries/note.dart';
import 'package:citizen_lab/themes/theme_changer_provider.dart';
import 'package:citizen_lab/utils/date_formater.dart';
import 'package:citizen_lab/utils/route_generator.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

import 'image_info_page_data.dart';

class ImagePage extends StatefulWidget {
  final Note note;
  final String uuid;

  ImagePage({
    this.note,
    this.uuid,
  });

  @override
  _ImagePageState createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _titleEditingController = TextEditingController();
  final _descEditingController = TextEditingController();

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
      _image = File(widget.note.filePath);
      _createdAt = widget.note.createdAt;
    } else {
      _createdAt = dateFormatted();
    }

    _titleEditingController.addListener(() {
      setState(() => _title = _titleEditingController.text);
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

  // TODO: Fehler wird nicht angezeigt
  void _shareContent() async {
    if (_image != null) {
      /*try {
        final channelName = 'rahmitufanoglu.citizenlab';
        final channel = MethodChannel('channel:$channelName.share/share');
        channel.invokeMethod('shareImage', '$_title');
      } catch (error) {
        print('Share error: $error');
        final String sharingNotPossible = 'Teilvorgang nicht möglich';
        _scaffoldKey.currentState
            .showSnackBar(_buildSnackBar(text: '$sharingNotPossible.'));
      }*/
      final ByteData bytes = await rootBundle.load(_image.path);
      final Uint8List uint8List = bytes.buffer.asUint8List();
      await Share.file(
        'image',
        '$_title.png',
        uint8List,
        'image/png',
        text: _title,
      );
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
          FloatingActionButton(
            heroTag: null,
            tooltip: '',
            elevation: 4.0,
            highlightElevation: 16.0,
            child: Icon(Icons.folder),
            onPressed: () async {
              await _getImage(false);
            },
          ),
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

  Widget _buildBody() {
    final double screenWidth = MediaQuery.of(context).size.width;

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

      setState(() => _image = image);

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

  //String operation;

  Future<void> _saveNote() async {
    if (_titleEditingController.text.isNotEmpty && (_image != null)) {
      if (widget.note == null) {
        Note note = Note(
          widget.uuid,
          'Bild',
          _titleEditingController.text,
          _descEditingController.text,
          _image.path,
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
    Note newNote = Note.fromMap({
      DatabaseHelper.columnNoteId: note.id,
      DatabaseHelper.columnProjectUuid: note.uuid,
      //ProjectDatabaseHelper.columnNoteProject: note.project,
      DatabaseHelper.columnNoteType: note.type,
      DatabaseHelper.columnNoteTitle: _titleEditingController.text,
      DatabaseHelper.columnNoteDescription: _descEditingController.text,
      DatabaseHelper.columnNoteContent: _image.path,
      DatabaseHelper.columnNoteCreatedAt: note.createdAt,
      DatabaseHelper.columnNoteUpdatedAt: dateFormatted(),
      DatabaseHelper.columnNoteIsEdited: 0,
      DatabaseHelper.columnNoteIsFirstTime: 1,
      DatabaseHelper.columnNoteCardColor: note.cardColor,
      DatabaseHelper.columnNoteCardTextColor: note.cardTextColor,
    });
    //await _noteDb.updateNote(newNote: newNote);
    Navigator.pop(context, newNote);
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
            if (_titleEditingController.text.isNotEmpty) {
              _titleEditingController.clear();
            }

            if (_descEditingController.text.isNotEmpty) {
              _descEditingController.clear();
            }
          },
          onPressedUpdate: () {
            _createCachedImage();
            //_title = _titleEditingController.text;
            Navigator.pop(context);
          },
        );
      },
    );
  }

  /*Widget _buildSnackBar(String text) {
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
  }*/

  Widget _buildSnackBar({@required String text}) {
    return SnackBar(
      backgroundColor: Colors.black87,
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
