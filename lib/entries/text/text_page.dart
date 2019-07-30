import 'dart:async';
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
import 'package:citizen_lab/utils/date_formatter.dart';
import 'package:citizen_lab/utils/route_generator.dart';
import 'package:citizen_lab/utils/utils.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../formulations.dart';
import '../../title_change_provider.dart';

class TextPage extends StatefulWidget {
  final Key key;
  final Note note;
  final String uuid;

  TextPage({
    this.key,
    @required this.note,
    @required this.uuid,
  }) : super(key: key);

  @override
  _TextPageState createState() => _TextPageState();
}

class _TextPageState extends State<TextPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _titleEditingController = TextEditingController();
  final _descEditingController = TextEditingController();
  final _noteDb = DatabaseHelper.db;

  final _titleBloc = TitleBloc();

  ThemeChangerProvider _themeChanger;
  TitleChangerProvider _titleChanger;
  String _title = '';
  String _savedTitle = '';
  String _createdAt = '';
  String _editedAt = '';

  PdfCreator _pdfCreator;

  @override
  void initState() {
    super.initState();

    if (widget.note != null) {
      _titleEditingController.text = widget.note.title;
      _savedTitle = _titleEditingController.text;
      _title = _savedTitle;
      _descEditingController.text = widget.note.description;
      _editedAt = widget.note.updatedAt;
      _createdAt = widget.note.createdAt;
    } else {
      _editedAt = dateFormatted();
      _createdAt = dateFormatted();
    }

    _titleEditingController.addListener(() {
      setState(() {
        _title = _titleEditingController.text;
        if (_titleEditingController.text.isEmpty) {
          _title = _savedTitle;
        }
      });
    });
  }

  @override
  void dispose() {
    _titleEditingController.dispose();
    _descEditingController.dispose();
    _titleBloc.dispose();
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
            //_shareContent();
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

  Future<void> _createPdf() async {
    String title = Utils.removeWhiteSpace(_title);

    _pdfCreator = PdfCreator(
      title: _titleEditingController.text,
      content: _descEditingController.text,
      dateCreated: dateFormatted(),
      filePath: await _localPath(title),
    );

    _pdfCreator.createPdf();
    await _pdfCreator.savePdf();
  }

  Future<void> _shareContent() async {
    final String noTitle = 'Bitte einen Titel und eine Beschreibung eingeben';

    if (_titleEditingController.text.isNotEmpty &&
        _descEditingController.text.isNotEmpty) {
      String title = Utils.removeWhiteSpace(_title);
      final String path = await _localPath(title);
      final ByteData bytes = await rootBundle.load(path);
      final Uint8List uint8List = bytes.buffer.asUint8List();

      await Share.file(
        'text',
        '$title.pdf',
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

  Future<String> _localPath(String title) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$title.pdf';
    return path;
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

  void _setInfoPage() {
    Navigator.pushNamed(
      context,
      RouteGenerator.infoPage,
      arguments: {
        RouteGenerator.title: 'Text-Info',
        RouteGenerator.tabLength: 3,
        RouteGenerator.tabs: textTabList,
        RouteGenerator.tabChildren: textSingleChildScrollViewList,
      },
    );
  }

  Future _saveNote() async {
    if (_titleEditingController.text.isNotEmpty) {
      if (widget.note == null) {
        Note note = Note(
          widget.uuid,
          'Text',
          _titleEditingController.text,
          _descEditingController.text,
          '',
          _createdAt,
          _editedAt,
          0,
          0,
          0xFFFFFFFF,
          0xFF000000,
        );
        //await _noteDb.insertNote(note: newNote);
        Navigator.pop(context, note);
        //_noteBloc.add(newNote);
      } else {
        _checkIfContentEdited() == 1
            ? _updateNote(widget.note)
            : Navigator.pop(context);
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
      DatabaseHelper.columnNoteId: note.id,
      DatabaseHelper.columnProjectUuid: note.uuid,
      DatabaseHelper.columnNoteType: note.type,
      DatabaseHelper.columnNoteTitle: _titleEditingController.text,
      DatabaseHelper.columnNoteDescription: _descEditingController.text,
      DatabaseHelper.columnNoteContent: '',
      DatabaseHelper.columnNoteCreatedAt: note.createdAt,
      DatabaseHelper.columnNoteUpdatedAt: dateFormatted(),
      DatabaseHelper.columnNoteIsFirstTime: 1,
      DatabaseHelper.columnNoteIsEdited: _checkIfContentEdited(),
      DatabaseHelper.columnNoteCardColor: note.cardColor,
      DatabaseHelper.columnNoteCardTextColor: note.cardTextColor,
    });
    Navigator.pop(context, newNote);
  }

  int _checkIfContentEdited() {
    return _titleEditingController.text == widget.note.title
        ? _descEditingController.text == widget.note.description ? 0 : 1
        : 1;
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

    _titleEditingController.clear();
    _descEditingController.clear();

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
      i == 0
          ? experimentItemsWidgets.add(_createTile(formulations[i], true))
          : experimentItemsWidgets.add(_createTile(formulations[i], false));
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

  Widget _createTile(
    FormulationItem experimentItem,
    bool centerIcon,
  ) {
    final double screenHeight = MediaQuery.of(context).size.height;

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
