import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:citizen_lab/bloc/title_bloc.dart';
import 'package:citizen_lab/custom_widgets/no_yes_dialog.dart';
import 'package:citizen_lab/custom_widgets/title_desc_widget.dart';
import 'package:citizen_lab/database/database_provider.dart';
import 'package:citizen_lab/entries/formulation_item.dart';
import 'package:citizen_lab/entries/note.dart';
import 'package:citizen_lab/entries/text/text_info_page_data.dart';
import 'package:citizen_lab/pdf_creator.dart';
import 'package:citizen_lab/themes/theme_changer_provider.dart';
import 'package:citizen_lab/utils/date_formater.dart';
import 'package:citizen_lab/utils/route_generator.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../formulations.dart';
import '../../title_change_provider.dart';

class TextPage extends StatefulWidget {
  final Note note;
  final int projectRandom;

  TextPage({
    @required this.note,
    @required this.projectRandom,
  });

  @override
  _TextPageState createState() => _TextPageState();
}

class _TextPageState extends State<TextPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _titleEditingController = TextEditingController();
  final _descEditingController = TextEditingController();
  final _noteDb = DatabaseProvider.db;

  final _titleBloc = TitleBloc();

  ThemeChangerProvider _themeChanger;
  TitleChangerProvider _titleChanger;
  Timer _timer;
  String _title;
  String _savedTitle;
  String _createdAt;
  String _timeString;

  double screenHeight;

  @override
  void initState() {
    _timeString = dateFormatted();
    _timer = Timer.periodic(Duration(seconds: 1), (_) => _getTime());

    if (widget.note != null) {
      _titleEditingController.text = widget.note.title;
      //_title = _titleEditingController.text;
      _savedTitle = _titleEditingController.text;
      _title = _savedTitle;
      _descEditingController.text = widget.note.description;
      _createdAt = widget.note.dateCreated;
    } else {
      _createdAt = dateFormatted();
    }

    _titleEditingController.addListener(() {
      setState(() {
        _title = _titleEditingController.text;
        if (_titleEditingController.text.isEmpty) {
          _title = _savedTitle;
        }
        print('Textlänge: ${_titleEditingController.text.length}');
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _titleEditingController.dispose();
    _descEditingController.dispose();
    _titleBloc.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _getTime() {
    final String formattedDateTime = dateFormatted();
    setState(() {
      _timeString = formattedDateTime;
    });
  }

  // TODO
  PdfCreator _pdfCreator;

  void _createPdf() {
    _pdfCreator = PdfCreator(
      title: _titleEditingController.text,
      content: _descEditingController.text,
    );

    _pdfCreator.createPdf();
    _pdfCreator.savePdf();
  }

  @override
  Widget build(BuildContext context) {
    _themeChanger = Provider.of<ThemeChangerProvider>(context);
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFabs(),
    );
  }

  Widget _buildBody() {
    return TitleDescWidget(
      titleBloc: _titleBloc,
      titleChanger: _titleChanger,
      title: _title,
      createdAt: _createdAt,
      titleEditingController: _titleEditingController,
      descEditingController: _descEditingController,
      onWillPop: _saveNote,
      db: _noteDb,
    );
  }

  Widget _buildAppBar() {
    final String back = 'Zurück';
    final String noteType = 'Textnotiz';

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
            child: Text((_title != null) ? _title : noteType),
          ),
          /*child: Tooltip(
            message: noteType,
            child: StreamBuilder(
              stream: _titleBloc.title,
              builder: (
                BuildContext context,
                AsyncSnapshot snapshot,
              ) {
                print(snapshot.data);
                return Text((_title != null) ? snapshot.data : noteType);
              },
            ),
          ),*/
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.share),
          onPressed: () {
            _createPdf();
            Future.delayed(
                Duration(milliseconds: 500), () => {_shareContent()});
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

  void _shareContent() async {
    final String fullContent =
        _titleEditingController.text + '\n' + _descEditingController.text;
    final String noTitle = 'Bitte einen Titel und eine Beschreibung eingeben';
    if (_titleEditingController.text.isNotEmpty &&
        _descEditingController.text.isNotEmpty) {
      //Share.share(fullContent);

      final file = File('/sdcard/$_title.pdf');

      final ByteData bytes = await rootBundle.load(file.path);
      final Uint8List uint8List = bytes.buffer.asUint8List();

      await Share.file(
        'text',
        '$_title.pdf',
        uint8List,
        'text/pdf',
        text: _title,
      );
    } else {
      _scaffoldKey.currentState.showSnackBar(
        _buildSnackBar(text: noTitle),
      );
    }
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

  void _setInfoPage() {
    Navigator.pushNamed(
      context,
      RouteGenerator.infoPage,
      arguments: {
        'title': 'Text-Info',
        'tabLength': 3,
        'tabs': textTabList,
        'tabChildren': textSingleChildScrollViewList,
      },
    );
  }

  Widget _buildBody2() {
    final created = 'Erstellt am';
    final title = 'Titel';
    final titleHere = 'Titel hier';
    final content = 'Inhalt';
    final contentHere = 'Inhalt hier';
    final String plsEnterATitle = 'Bitte einen Titel eingeben';

    return SafeArea(
      child: WillPopScope(
        onWillPop: () => _saveNote(),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: 8.0, bottom: 88.0),
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(8.0),
                decoration: ShapeDecoration(
                  shape: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        _timeString,
                        //_timerProvider.getTime,
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
                      onChanged: (value) {
                        _title = value;
                      },
                      decoration: InputDecoration(
                        hintText: '$titleHere.',
                        errorText: _getErrorText(),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        //errorText: _titleValidate ? plsEnterATitle : null,
                      ),
                      //onChanged: (String changed) => _title = changed,
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
        ),
      ),
    );
  }

  String _getErrorText() {
    return _titleChanger.getErrorMessage();
  }

  Future<void> _saveNote() async {
    if (_titleEditingController.text.isNotEmpty) {
      if (widget.note == null) {
        Note note = Note(
          widget.projectRandom,
          'Text',
          _titleEditingController.text,
          _descEditingController.text,
          '',
          _createdAt,
          dateFormatted(),
          0,
          0xFFFFFFFF,
          0xFF000000,
        );
        //await _noteDb.insertNote(note: newNote);
        Navigator.pop(context, note);
        //_noteBloc.add(newNote);
      } else {
        _updateNote(widget.note);
      }
    } else {
      _scaffoldKey.currentState.showSnackBar(
        _buildSnackBarWithButton(
          text: 'Bitte einen Titel eingeben.\nNotiz abbrechen?',
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
      DatabaseProvider.columnNoteContent: '',
      DatabaseProvider.columnNoteCreatedAt: note.dateCreated,
      DatabaseProvider.columnNoteUpdatedAt: dateFormatted(),
      DatabaseProvider.columnNoteEdited: 1,
      DatabaseProvider.columnNoteCardColor: note.cardColor,
      DatabaseProvider.columnNoteCardTextColor: note.cardTextColor,
    });
    //await _noteDb.updateNote(newNote: newNote);
    Navigator.pop(context, newNote);
  }

  Widget _buildFabs() {
    return Padding(
      padding: const EdgeInsets.only(left: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FloatingActionButton(
            heroTag: null,
            child: Icon(Icons.keyboard_arrow_up),
            onPressed: () => _openModalBottomSheet(),
          ),
          FloatingActionButton(
            heroTag: null,
            child: Icon(Icons.remove),
            onPressed: () => _refreshTextFormFields(),
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
    List<Widget> experimentItemsWidgets = [];
    for (int i = 0; i < formulations.length; i++) {
      if (i == 0) {
        experimentItemsWidgets.add(_createTile(formulations[i], true));
      } else {
        experimentItemsWidgets.add(_createTile(formulations[i], false));
      }
    }
    _buildMainBottomSheet(experimentItemsWidgets);
  }

  void _buildMainBottomSheet(List<Widget> experimentItemsWidgets) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => ListView(
            shrinkWrap: true,
            children: experimentItemsWidgets,
          ),
    );
  }

  Widget _createTile(FormulationItem experimentItem, bool centerIcon) {
    return Material(
      child: InkWell(
        child: Container(
          //height: 50.0,
          height: screenHeight / 16,
          child: Stack(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: (!centerIcon)
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              experimentItem.name,
                              style: TextStyle(fontSize: 16.0),
                            ),
                            //Icon(experimentItem.icon, size: 20.0),
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
    Clipboard.setData(ClipboardData(text: text));
    _scaffoldKey.currentState.showSnackBar(_buildSnackBar(text: snackText));
  }

  Widget _buildSnackBar({@required String text}) {
    return SnackBar(
      backgroundColor: Colors.black87,
      duration: Duration(milliseconds: 500),
      content: Text(
        text,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 8.0),
          Expanded(
            flex: 1,
            child: RaisedButton(
              color: Colors.green,
              child: Text(no),
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
              color: Colors.red,
              child: Text(yes),
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
