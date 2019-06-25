import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:citizen_lab/citizen_science/title_provider.dart';
import 'package:citizen_lab/custom_widgets/ColumnRowEditWidget.dart';
import 'package:citizen_lab/custom_widgets/no_yes_dialog.dart';
import 'package:citizen_lab/custom_widgets/simple_timer_dialog.dart';
import 'package:citizen_lab/custom_widgets/table_widget.dart';
import 'package:citizen_lab/custom_widgets/title_desc_widget.dart';
import 'package:citizen_lab/database/database_provider.dart';
import 'package:citizen_lab/entries/note.dart';
import 'package:citizen_lab/entries/table/table_info_page_data.dart';
import 'package:citizen_lab/themes/theme_changer_provider.dart';
import 'package:citizen_lab/utils/date_formater.dart';
import 'package:citizen_lab/utils/route_generator.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../experiment_item.dart';

class TablePage extends StatefulWidget {
  final Key key;
  final Note note;
  final int projectRandom;

  TablePage({
    this.key,
    @required this.note,
    @required this.projectRandom,
  }) : super(key: key);

  @override
  _TablePageState createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  static int _initialPage = 1;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _titleEditingController = TextEditingController();
  final _descriptionEditingController = TextEditingController();
  final _rowTextEditingController = TextEditingController();
  final _columnTextEditingController = TextEditingController();
  final _pageController = PageController(initialPage: _initialPage);
  final _noteDb = DatabaseProvider();
  final _listTextEditingController = <TextEditingController>[];

  ThemeChangerProvider _themeChanger;
  File _csv;
  int _column;
  int _row;
  String _title;
  String _createdAt;
  List<String> _data;
  List<List<dynamic>> _list = [];
  TitleProvider _titleProvider;

  //Timer _timer;
  //String _timeString;

  @override
  void initState() {
    //_timeString = dateFormatted();
    //_timer = Timer.periodic(Duration(seconds: 1), (_) => _getTime());

    if (widget.note != null) {
      _titleEditingController.text = widget.note.title;
      _title = _titleEditingController.text;
      _descriptionEditingController.text = widget.note.description;
      _csv = File(widget.note.content);
      _createdAt = widget.note.dateCreated;

      if (_column != null && _row != null) {
        List<List<dynamic>> csvList = _csvToList(_csv);
        _column = csvList[0].length;
        _row = csvList.length;
        _columnTextEditingController.text = _column.toString();
        _rowTextEditingController.text = _row.toString();
      }
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
    _descriptionEditingController.dispose();
    _rowTextEditingController.dispose();
    _columnTextEditingController.dispose();
    _pageController.dispose();
    for (int i = 0; i < _listTextEditingController.length; i++) {
      _listTextEditingController[i].dispose();
    }
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
      floatingActionButton: _buildFabs(),
    );
  }

  Widget _buildAppBar() {
    final String back = 'Zurück';
    final String noteType = 'Tabellennotiz';

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
    if (_title.isNotEmpty) {
      _createCsv(_title);
      _scaffoldKey.currentState.showSnackBar(
        _buildSnackBarWithButton(
          text: 'Tabelle erstellt. Teilen?',
          onPressed: () => _shareCsv(),
        ),
      );
    } else {
      _scaffoldKey.currentState.showSnackBar(
        _buildSnackBar(text: 'Bitte einen Titel eingeben.'),
      );
    }
  }

  void _setInfoPage() {
    Navigator.pushNamed(
      context,
      RouteGenerator.infoPage,
      arguments: {
        'title': 'Tabellen-Info',
        'tabLength': 2,
        'tabs': tableTabList,
        'tabChildren': tableSingleChildScrollViewList,
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
    generateTable();

    return SafeArea(
      child: WillPopScope(
        onWillPop: () => _saveNote(),
        child: Padding(
          padding: EdgeInsets.only(
            top: 8.0,
            left: 8.0,
            right: 8.0,
            bottom: 88.0,
          ),
          child: (_column != null || _row != null)
              ? TableWidget(
                  listTextEditingController: _listTextEditingController,
                  column: _column,
                  row: _row,
                )
              : Center(
                  child: Icon(
                    Icons.table_chart,
                    color: Colors.grey,
                    size: 100.0,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildBody2() {
    generateTable();

    return SafeArea(
      child: WillPopScope(
        onWillPop: () => _saveNote(),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 88.0),
          child: PageView(
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
                descEditingController: _descriptionEditingController,
              ),
              (_column != null || _row != null)
                  ? TableWidget(
                      listTextEditingController: _listTextEditingController,
                      column: _column,
                      row: _row,
                    )
                  : Center(
                      child: Icon(
                        Icons.table_chart,
                        color: Colors.grey,
                        size: 100.0,
                      ),
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
                  controller: _descriptionEditingController,
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

  void generateTable() {
    if (widget.note == null) {
      if (_row != null && _column != null) {
        for (int x = 0; x < _row; x++) {
          for (int y = 0; y < _column; y++) {
            _listTextEditingController.add(TextEditingController());
          }
        }
      }
    } else {
      List<List<dynamic>> csvList = _csvToList(_csv);
      _column = csvList[0].length;
      _row = csvList.length;

      for (int i = 0; i < (_column * _row); i++) {
        _listTextEditingController.add(TextEditingController());
      }

      _csvRead(csvList, _column, _row);
    }
  }

  void _csvRead(List<List<dynamic>> list, int column, int row) {
    List newCsvList = [];
    int tmp = 0;
    for (int i = 0; i < row; i++) {
      for (int j = 0; j < column; j++) {
        newCsvList.add(list[i][j].toString());
        _listTextEditingController[tmp++].text = list[i][j].toString();
      }
    }
  }

  List<List> _csvToList(File myCsvFile) {
    List<List<dynamic>> listCreated =
        CsvToListConverter().convert(myCsvFile.readAsStringSync());
    return listCreated;
  }

  String _listToCsv(List listToConvert) {
    String csvPath = ListToCsvConverter().convert(listToConvert);
    return csvPath;
  }

  Widget _buildFabs() {
    return Padding(
      padding: const EdgeInsets.only(left: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FloatingActionButton(
            heroTag: null,
            tooltip: 'Beschreibung editieren.',
            elevation: 4.0,
            highlightElevation: 16.0,
            child: Icon(Icons.description),
            onPressed: () => _showDialogEditImage(),
          ),
          FloatingActionButton(
            heroTag: null,
            tooltip: 'Tabelle leeren.',
            elevation: 4.0,
            highlightElevation: 16.0,
            child: Icon(Icons.remove),
            onPressed: () => _clearTableContent(),
          ),
          FloatingActionButton(
            heroTag: null,
            tooltip: 'Tabelle erstellen.',
            elevation: 4.0,
            highlightElevation: 16.0,
            child: Icon(Icons.add),
            onPressed: () => _buildTableCreate(),
          ),
        ],
      ),
    );
  }

  Widget _buildFabs2() {
    if (_initialPage == 1) {
      return _buildFabsTable();
    } else {
      return _buildFabsContent();
    }
  }

  Widget _buildFabsTable() {
    return Padding(
      padding: const EdgeInsets.only(left: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          /*FloatingActionButton(
            heroTag: null,
            tooltip: 'Beschreibung editieren.',
            elevation: 4.0,
            highlightElevation: 16.0,
            child: Icon(Icons.description),
            onPressed: () => _showDialogEditImage(),
          ),*/
          FloatingActionButton(
            heroTag: null,
            tooltip: 'Tabelle leeren.',
            elevation: 4.0,
            highlightElevation: 16.0,
            child: Icon(Icons.remove),
            onPressed: () => _clearTableContent(),
          ),
          FloatingActionButton(
            heroTag: null,
            tooltip: 'Tabelle erstellen.',
            elevation: 4.0,
            highlightElevation: 16.0,
            child: Icon(Icons.add),
            onPressed: () => _buildTableCreate(),
          ),
        ],
      ),
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

  void _copyContent() {
    final String copyContent = 'Inhalt kopiert';
    final String copyNotPossible = 'Kein Inhalt zum kopieren';

    if (_titleEditingController.text.isNotEmpty &&
        _descriptionEditingController.text.isNotEmpty) {
      String fullContent = _titleEditingController.text +
          '\n' +
          _descriptionEditingController.text;
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
            _descriptionEditingController.text += experimentItem.name;
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

  void _refreshTextFormFields() {
    final String textDeleted = 'Text gelöscht';

    if (_titleEditingController.text.isNotEmpty) {
      _titleEditingController.clear();
    }

    if (_descriptionEditingController.text.isNotEmpty) {
      _descriptionEditingController.clear();
    }

    _scaffoldKey.currentState.showSnackBar(
      _buildSnackBar(text: '$textDeleted.'),
    );
  }

  void _clearTableContent() {
    int i = 0;
    for (int x = 0; x < _row; x++) {
      for (int y = 0; y < _column; y++) {
        if (_listTextEditingController[i].text.isNotEmpty) {
          _listTextEditingController[i++].clear();
        }
      }
    }
  }

  Future<String> _createCsv(String title) async {
    List<List<String>> graphArray = List.generate(
      _row,
      (i) => List<String>(_column),
    );

    int i = 0;
    for (int x = 0; x < _row; x++) {
      for (int y = 0; y < _column; y++) {
        debugPrint('$x/$y = ${_listTextEditingController[i].text}');
        graphArray[x][y] = _listTextEditingController[i++].text;
      }
    }

    String dir = (await getTemporaryDirectory()).absolute.path + '/';
    _csv = File('$dir$title.csv');

    String path = _listToCsv(graphArray);
    _csv.writeAsString(path);

    return _csv.path;
  }

  _saveNote() async {
    if (_titleEditingController.text.isNotEmpty &&
        _column != null &&
        _row != null) {
      if (widget.note == null) {
        String path = '';
        if (_column != null && _row != null) {
          path = await _createCsv(_title);
        }
        Note note = Note(
          //widget.projectTitle,
          widget.projectRandom,
          'Tabelle',
          _titleEditingController.text,
          _descriptionEditingController.text,
          path,
          _createdAt,
          dateFormatted(),
        );
        //await _noteDb.insertNote(note: newNote);
        Navigator.pop(context, note);
      } else {
        _csv.delete();
        String path = await _createCsv(_title);
        _updateNote(widget.note, path);
      }
      //Navigator.pop(context, true);
    } else {
      _scaffoldKey.currentState.showSnackBar(
        _buildSnackBarWithButton(
          text: 'Bitte einen Titel eingeben\nNotiz abbrechen?',
          onPressed: () => Navigator.pop(context),
        ),
      );
    }
  }

  void _updateNote(Note note, String path) async {
    Note newNote = Note.fromMap({
      DatabaseProvider.columnNoteId: note.id,
      //ProjectDatabaseHelper.columnProjectId: note.projectId,
      DatabaseProvider.columnProjectRandom: note.projectRandom,
      DatabaseProvider.columnNoteType: note.type,
      DatabaseProvider.columnNoteTitle: _titleEditingController.text,
      DatabaseProvider.columnNoteDescription:
          _descriptionEditingController.text,
      DatabaseProvider.columnNoteContent: path,
      DatabaseProvider.columnNoteCreatedAt: note.dateCreated,
      DatabaseProvider.columnNoteUpdatedAt: dateFormatted(),
    });
    //await _noteDb.updateNote(newNote: newNote);
    Navigator.pop(context, newNote);
  }

  Future<void> _shareCsv() async {
    try {
      if (_csv.path != null) {
        final ByteData bytes = await rootBundle.load(_csv.path);
        final Uint8List uint8List = bytes.buffer.asUint8List();

        final tempDir = await getTemporaryDirectory();
        final file = await File('${tempDir.path}/$_title.csv').create();
        file.writeAsBytesSync(uint8List);

        const channelName = 'rahmitufanoglu.citizenlab';
        final channel = const MethodChannel('channel:$channelName.share/share');
        channel.invokeMethod('shareTable', '$_title.csv');
      } else {
        _scaffoldKey.currentState.showSnackBar(
          _buildSnackBar(text: 'Tabelle kann nicht geteilt werden.'),
        );
      }
    } catch (error) {
      debugPrint('Share $error');
    }
  }

  Future<void> _showDialogEditImage() async {
    await showDialog(
      context: context,
      builder: (context) {
        return SimpleTimerDialog(
          //titleProvider: _titleProvider,
          //title: _titleEditingController.text,
          createdAt: _createdAt,
          textEditingController: _titleEditingController,
          descEditingController: _descriptionEditingController,
          descExists: true,
          onPressedClose: () => Navigator.of(context).pop(),
          onPressedClear: () {
            if (_titleEditingController.text.isNotEmpty) {
              _titleEditingController.clear();
            }

            if (_descriptionEditingController.text.isNotEmpty) {
              _descriptionEditingController.clear();
            }
          },
          onPressedUpdate: () {
            _title = _titleEditingController.text;
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Future<void> _buildTableCreate() async {
    final String enterTableSize = 'Titel und Tabellengröße festlegen.';

    return await showDialog(
      context: context,
      builder: (context) {
        return ColumnRowEditingWidget(
          title: enterTableSize,
          titleEditingController: _titleEditingController,
          columnEditingController: _columnTextEditingController,
          rowEditingController: _rowTextEditingController,
          onPressedClear: _clearAllFields,
          onPressedCheck: _checkAllFields,
        );
      },
    );
  }

  void _clearAllFields() {
    if (_rowTextEditingController.text.isNotEmpty) {
      _rowTextEditingController.clear();
    }

    if (_columnTextEditingController.text.isNotEmpty) {
      _columnTextEditingController.clear();
    }

    if (_titleEditingController.text.isNotEmpty) {
      _titleEditingController.clear();
    }

    if (_descriptionEditingController.text.isNotEmpty) {
      _descriptionEditingController.clear();
    }
  }

  void _checkAllFields() {
    _column = int.parse(_columnTextEditingController.text);
    _row = int.parse(_rowTextEditingController.text);

    if (_column != null && _row != null) {
      setState(() {});
      Navigator.pop(context);
    }
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
