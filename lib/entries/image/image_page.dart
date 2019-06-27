import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:citizen_lab/custom_widgets/no_yes_dialog.dart';
import 'package:citizen_lab/custom_widgets/set_title_widget.dart';
import 'package:citizen_lab/custom_widgets/simple_timer_dialog.dart';
import 'package:citizen_lab/custom_widgets/title_desc_widget.dart';
import 'package:citizen_lab/database/database_provider.dart';
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

import '../experiment_item.dart';
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
  static int _initialPage = 1;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _titleEditingController = TextEditingController();
  final _descEditingController = TextEditingController();
  final _pageController = PageController(initialPage: _initialPage);
  final _noteDb = DatabaseProvider();

  ThemeChangerProvider _themeChanger;
  File _image;
  String _title;
  String _createdAt;

  //Timer _timer;
  //String _timeString;

  @override
  void initState() {
    //_timeString = dateFormatted();
    //_timer = Timer.periodic(Duration(seconds: 1), (_) => _getTime());

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
    _pageController.dispose();
    //_timer.cancel();
    super.dispose();
  }

  /*void _getTime() {
    final String formattedDateTime = dateFormatted();
    setState(() {
      _timeString = formattedDateTime;
    });
  }*/

  @override
  Widget build(BuildContext context) {
    _themeChanger = Provider.of<ThemeChangerProvider>(context);
    _themeChanger.checkIfDarkModeEnabled(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      body: _buildBody(),
      //floatingActionButton: _setFabs(),
      floatingActionButton: _buildFabs(),
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
          /*FloatingActionButton(
            heroTag: null,
            child: Icon(Icons.remove),
            onPressed: () => _refreshTextFormFields(),
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

  Widget _setFabs() {
    if (_initialPage == 1) {
      return _buildFabImage();
    } else {
      return _buildFabsContent();
    }
  }

  Widget _buildFabImage() {
    final String editTitleAndDesc = 'Titel und Beschreibung editieren';
    final String getImage = 'Foto aus dem Ordner importieren';
    final String createImage = 'Foto erstellen';

    return FloatingActionButton(
      tooltip: '$createImage.',
      child: Icon(Icons.camera_alt),
      onPressed: () => _createImage(),
    );
  }

  Widget _buildFabsContent() {
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
            tooltip: '$createImage.',
            child: Icon(Icons.keyboard_arrow_up),
            onPressed: () => _openModalBottomSheet(),
          ),
          FloatingActionButton(
            heroTag: null,
            tooltip: '$createImage.',
            child: Icon(Icons.remove),
            onPressed: () => _refreshTextFormFields(),
          ),
          FloatingActionButton(
            heroTag: null,
            tooltip: '$createImage.',
            child: Icon(Icons.content_copy),
            onPressed: () => _copyContent(),
          ),
        ],
      ),
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
            .showSnackBar(_buildSnackBar(text: '$sharingNotPossible.'));
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

  Widget _buildBody2() {
    final double screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Form(
        key: _formKey,
        autovalidate: true,
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
                  //_buildForm(),
                  TitleDescWidget(
                    title: _title,
                    createdAt: _createdAt,
                    titleEditingController: _titleEditingController,
                    descEditingController: _descEditingController,
                  ),
                  Center(
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    final created = 'Erstellt am';
    final title = 'Titel';
    final titleHere = 'Titel hier';
    final content = 'Inhalt';
    final contentHere = 'Inhalt hier';
    final String plsEnterATitle = 'Bitte einen Titel eingeben';

    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 8.0, bottom: 88.0),
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(8.0),
            decoration: ShapeDecoration(
              shape: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    //_timeString,
                    '',
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextField(
                  controller: _titleEditingController,
                  keyboardType: TextInputType.text,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: '$titleHere.',
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    //errorText: _titleValidate ? plsEnterATitle : null,
                  ),
                  onChanged: (String changed) => _title = changed,
                  //validator: (text) => text.isEmpty ? plsEnterATitle : null,
                ),
                SizedBox(height: 42.0),
                TextField(
                  controller: _descEditingController,
                  keyboardType: TextInputType.text,
                  maxLines: 20,
                  style: TextStyle(fontSize: 16.0),
                  decoration: InputDecoration(
                    hintText: '$contentHere.',
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                  ),
                ),
              ],
            ),
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

  String operation;

  Future<void> _saveNote() async {
    if (_titleEditingController.text.isNotEmpty && (_image != null)) {
      if (widget.note == null) {
        Note note = Note(
          //widget.projectTitle,
          widget.projectRandom,
          'Bild',
          _titleEditingController.text,
          _descEditingController.text,
          //(_image != null) ? _image.path : '',
          _image.path,
          _createdAt,
          dateFormatted(),
          0,
        );
        //operation = 'save';
        //await _noteDb.insertNote(note: newNote);
        Navigator.pop(context, note);
      } else {
        _updateNote(widget.note);
        //operation = 'update';
      }
      //Navigator.pop(context, true);
      //Navigator.pop(context, operation);
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
      DatabaseProvider.columnProjectRandom: note.projectRandom,
      //ProjectDatabaseHelper.columnNoteProject: note.project,
      DatabaseProvider.columnNoteType: note.type,
      DatabaseProvider.columnNoteTitle: _titleEditingController.text,
      DatabaseProvider.columnNoteDescription: _descEditingController.text,
      DatabaseProvider.columnNoteContent: _image.path,
      DatabaseProvider.columnNoteCreatedAt: note.dateCreated,
      DatabaseProvider.columnNoteUpdatedAt: dateFormatted(),
      DatabaseProvider.columnNoteEdited: 1,
    });
    //await _noteDb.updateNote(newNote: newNote);
    Navigator.pop(context, newNote);
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
            //_title = _titleEditingController.text;
            Navigator.pop(context);
          },
        );
      },
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

    _scaffoldKey.currentState.showSnackBar(
      _buildSnackBar(text: '$textDeleted.'),
    );
  }

  void _copyContent() {
    final String copyContent = 'Inhalt kopiert';
    final String copyNotPossible = 'Kein Inhalt zum kopieren';

    if (_titleEditingController.text.isNotEmpty &&
        _descEditingController.text.isNotEmpty) {
      String fullContent =
          _titleEditingController.text + '\n' + _descEditingController.text;
      _setClipboard(fullContent, '$copyContent.');
    } else {
      _scaffoldKey.currentState.showSnackBar(
        _buildSnackBar(text: '$copyNotPossible.'),
      );
    }
  }

  void _openModalBottomSheet() {
    List<ExperimentItem> experimentItems = [
      ExperimentItem('', Icons.keyboard_arrow_down),
      ExperimentItem('AAA', Icons.add),
      ExperimentItem('BBB', Icons.add),
      ExperimentItem('CCC', Icons.add),
      ExperimentItem('DDD', Icons.add),
      ExperimentItem('EEE', Icons.add),
      ExperimentItem('FFF', Icons.add),
      ExperimentItem('GGG', Icons.add),
      ExperimentItem('HHH', Icons.add),
      ExperimentItem('III', Icons.add),
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

    _scaffoldKey.currentState.showSnackBar(
      _buildSnackBar(text: snackText),
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

  Widget _buildSnackBarWithButton({
    @required String text,
    @required GestureTapCallback onPressed,
  }) {
    return SnackBar(
      backgroundColor: Colors.black.withOpacity(0.8),
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
              child: Text('Ja'),
              color: Colors.red,
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
