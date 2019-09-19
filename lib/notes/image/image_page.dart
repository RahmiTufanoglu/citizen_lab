import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:citizen_lab/custom_widgets/no_yes_dialog.dart';
import 'package:citizen_lab/custom_widgets/set_title_widget.dart';
import 'package:citizen_lab/custom_widgets/simple_timer_dialog.dart';
import 'package:citizen_lab/database/database_helper.dart';
import 'package:citizen_lab/notes/note.dart';
import 'package:citizen_lab/themes/theme_changer_provider.dart';
import 'package:citizen_lab/utils/date_formatter.dart';
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

  const ImagePage({
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

  File _image;
  String _title;
  String _createdAt = '';

  @override
  void initState() {
    super.initState();

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
    const String noteType = 'Bildnotiz';

    return AppBar(
      leading: IconButton(
        tooltip: back,
        icon: Icon(Icons.arrow_back),
        onPressed: () => _saveNote(),
      ),
      title: Consumer(
        builder: (BuildContext context, ThemeChangerProvider provider, Widget child) {
          return GestureDetector(
            onPanStart: (_) => provider.setTheme(),
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

  Future _shareContent() async {
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
      CustomRoute.infoPage,
      arguments: {
        argTitle: 'Bild-Info',
        argTabLength: 2,
        argTabs: imageTabList,
        argTabChildren: imageSingleChildScrollViewList,
      },
    );
  }

  Widget _buildFabs() {
    const String editTitleAndDesc = 'Titel und Beschreibung editieren';
    const String createImage = 'Foto erstellen';

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
            elevation: 4.0,
            highlightElevation: 16.0,
            onPressed: () async {
              await _getImage(false);
            },
            child: Icon(Icons.folder),
          ),
          FloatingActionButton(
            heroTag: null,
            tooltip: '$createImage.',
            onPressed: () => _createImage(),
            child: Icon(Icons.camera_alt),
          ),
        ],
      ),
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
                    backgroundDecoration: const BoxDecoration(),
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
      await showDialog(
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

  Future<void> _getImage(bool isCamera) async {
    File image;

    isCamera
        ? image = await ImagePicker.pickImage(source: ImageSource.camera)
        : image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _image = image);
      await _createCachedImage();
    }
  }

  Future<void> _createCachedImage() async {
    final ByteData bytes = await rootBundle.load(_image.path);
    final Uint8List uint8List = bytes.buffer.asUint8List();
    final tempDir = await getTemporaryDirectory();
    final File file = File('${tempDir.path}/$_title.jpg');
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
        final Note note = Note(
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
    final Note newNote = Note.fromMap({
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
            _titleEditingController.clear();
            _descEditingController.clear();
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
            child: RaisedButton(
              color: Colors.green,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
              onPressed: () => _scaffoldKey.currentState.hideCurrentSnackBar(),
              child: const Text('Nein'),
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            flex: 1,
            child: RaisedButton(
              color: Colors.red,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
              onPressed: onPressed,
              child: const Text('Ja'),
            ),
          ),
        ],
      ),
    );
  }
}
