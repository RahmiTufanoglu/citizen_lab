import 'dart:async';

import 'package:citizen_lab/citizen_science/timer_provider.dart';
import 'package:citizen_lab/citizen_science/title_provider.dart';
import 'package:citizen_lab/custom_widgets/no_yes_dialog.dart';
import 'package:citizen_lab/database/project_database_helper.dart';
import 'package:citizen_lab/entries/experiment_item.dart';
import 'package:citizen_lab/entries/note.dart';
import 'package:citizen_lab/entries/text/text_info_page_data.dart';
import 'package:citizen_lab/themes/theme.dart';
import 'package:citizen_lab/themes/theme_changer_provider.dart';
import 'package:citizen_lab/utils/date_formater.dart';
import 'package:citizen_lab/utils/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class TextPage extends StatefulWidget {
  final Key key;
  final Note note;
  final String projectTitle;

  TextPage({
    this.key,
    @required this.note,
    @required this.projectTitle,
  }) : super(key: key);

  @override
  _TextPageState createState() => _TextPageState();
}

class _TextPageState extends State<TextPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _titleEditingController = TextEditingController();
  final _descEditingController = TextEditingController();
  final _noteDb = ProjectDatabaseHelper();

  ThemeChangerProvider _themeChanger;
  //bool _darkModeEnabled = false;
  Timer _timer;
  String _title;
  String _createdAt;
  String _timeString;

  //TitleProvider _titleProvider;
  //bool _titleValidate = false;

  TimerProvider _timerProvider;

  @override
  void initState() {
    //_timeString = dateFormatted();
    //_timer = Timer.periodic(Duration(seconds: 1), (_) => _getTime());

    if (widget.note != null) {
      _titleEditingController.text = widget.note.title;
      _title = _titleEditingController.text;
      _descEditingController.text = widget.note.description;
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
    //_timer.cancel();
    super.dispose();
  }

  /*void _getTime() {
    final String formattedDateTime = dateFormatted();
    setState(() {
      _timeString = formattedDateTime;
    });
  }*/

  void _onStart() {
    if (widget.note != null) {
      _titleEditingController.text = widget.note.title;
      _title = _titleEditingController.text;
      _descEditingController.text = widget.note.description;
      _createdAt = widget.note.dateCreated;
    } else {
      _createdAt = dateFormatted();
    }
  }

  @override
  Widget build(BuildContext context) {
    _themeChanger = Provider.of<ThemeChangerProvider>(context);
    _themeChanger.checkIfDarkModeEnabled(context);
    //_checkIfDarkModeEnabled();

    //_titleProvider = Provider.of<TitleProvider>(context);

    _timerProvider = Provider.of<TimerProvider>(context);
    Timer.periodic(Duration(seconds: 1), (_) => _timerProvider.setTimer());
    //_timerProvider.setTimer();

    _onStart();

    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFabs(),
    );
  }

  /*void _checkIfDarkModeEnabled() {
    final ThemeData theme = Theme.of(context);
    theme.brightness == appDarkTheme().brightness
        ? _darkModeEnabled = true
        : _darkModeEnabled = false;
  }*/

  Widget _buildAppBar() {
    final String back = 'Zurück';
    final String noteType = 'Textnotiz';

    return AppBar(
      elevation: 4.0,
      leading: IconButton(
        tooltip: back,
        icon: Icon(Icons.arrow_back),
        onPressed: _saveNote,
      ),
      title: GestureDetector(
        onPanStart: (_) => _themeChanger.setTheme(),
        child: Container(
          width: double.infinity,
          child: Tooltip(
            message: noteType,
            //child: Text((_title != null) ? _titleProvider.getTitle : noteType),
            child: Text((_title != null) ? _title : noteType),
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

  /*void _enableDarkMode() {
    _darkModeEnabled
        ? _themeChanger.setTheme(appLightTheme())
        : _themeChanger.setTheme(appDarkTheme());
  }*/

  void _shareContent() {
    final String fullContent =
        _titleEditingController.text + '\n' + _descEditingController.text;
    final String noTitle = 'Bitte einen Titel und eine Beschreibung eingeben';
    if (_titleEditingController.text.isNotEmpty &&
        _descEditingController.text.isNotEmpty) {
      Share.share(fullContent);
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

  Widget _buildBody() {
    final created = 'Erstellt am';
    final title = 'Titel';
    final titleHere = 'Titel hier';
    final content = 'Inhalt';
    final contentHere = 'Inhalt hier';
    final String plsEnterATitle = 'Bitte einen Titel eingeben';

    return SafeArea(
      child: Form(
        key: _formKey,
        autovalidate: true,
        child: WillPopScope(
          onWillPop: () => _saveNote(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 88.0),
            child: Column(
              children: <Widget>[
                Card(
                  margin: const EdgeInsets.only(
                    top: 8.0,
                    left: 8.0,
                    right: 8.0,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          //_timeString,
                          _timerProvider.getTime,
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
                Card(
                  margin: const EdgeInsets.only(
                    bottom: 8.0,
                    left: 8.0,
                    right: 8.0,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '$title:',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextFormField(
                          controller: _titleEditingController,
                          keyboardType: TextInputType.text,
                          maxLength: 50,
                          maxLines: 2,
                          style: TextStyle(fontSize: 16.0),
                          decoration: InputDecoration(
                            hintText: '$titleHere.',
                            //errorText: _titleValidate ? plsEnterATitle : null,
                          ),
                          /*onChanged: (changed) {
                            _titleProvider.setTitle(changed);
                            _title = _titleProvider.getTitle;
                            (_title.isEmpty)
                                ? _titleValidate = true
                                : _titleValidate = false;
                          },*/
                          validator: (text) =>
                              text.isEmpty ? plsEnterATitle : null,
                        ),
                        SizedBox(height: 42.0),
                        Text(
                          '$content:',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextFormField(
                          controller: _descEditingController,
                          keyboardType: TextInputType.text,
                          maxLength: 500,
                          maxLines: 20,
                          style: TextStyle(fontSize: 16.0),
                          decoration: InputDecoration(
                            hintText: '$contentHere.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveNote() async {
    if (_titleEditingController.text.isNotEmpty) {
      if (widget.note == null) {
        Note newNote = Note(
          widget.projectTitle,
          'Text',
          _titleEditingController.text,
          _descEditingController.text,
          '',
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
      ProjectDatabaseHelper.columnNoteProject: note.project,
      ProjectDatabaseHelper.columnNoteType: note.type,
      ProjectDatabaseHelper.columnNoteTitle: _titleEditingController.text,
      ProjectDatabaseHelper.columnNoteDescription: _descEditingController.text,
      ProjectDatabaseHelper.columnNoteContent: '',
      ProjectDatabaseHelper.columnNoteCreatedAt: note.dateCreated,
      ProjectDatabaseHelper.columnNoteUpdatedAt: dateFormatted(),
    });
    await _noteDb.updateNote(newNote: newNote);
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
      //_titleValidate = true;
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

  Widget _buildSnackBar({@required String text}) {
    return SnackBar(
      backgroundColor: Colors.black.withOpacity(0.5),
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
            color: Colors.green,
            child: Text('Nein'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
            ),
            onPressed: () => _scaffoldKey.currentState.hideCurrentSnackBar(),
          ),
          Spacer(flex: 1),
          RaisedButton(
            color: Colors.red,
            child: Text('Ja'),
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
