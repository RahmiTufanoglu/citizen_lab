import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:citizen_lab/custom_widgets/ColumnRowEditWidget.dart';
import 'package:citizen_lab/custom_widgets/no_yes_dialog.dart';
import 'package:citizen_lab/custom_widgets/table_widget.dart';
import 'package:citizen_lab/database/project_database_provider.dart';
import 'package:citizen_lab/entries/table/table_info_page_data.dart';
import 'package:citizen_lab/utils/route_generator.dart';
import 'package:citizen_lab/custom_widgets/simple_timer_dialog.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'package:citizen_lab/utils/date_formater.dart';
import 'package:citizen_lab/entries/note.dart';

class TablePage extends StatefulWidget {
  final Key key;
  final Note note;
  final String projectTitle;

  TablePage({
    this.key,
    @required this.note,
    @required this.projectTitle,
  }) : super(key: key);

  @override
  _TablePageState createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  final _globalKey = GlobalKey<ScaffoldState>();
  final _titleEditingController = TextEditingController();
  final _descriptionEditingController = TextEditingController();
  final _rowTextEditingController = TextEditingController();
  final _columnTextEditingController = TextEditingController();
  final _noteDb = ProjectDatabaseProvider();
  final _listTextEditingController = <TextEditingController>[];

  File _csv;
  int _column;
  int _row;
  String _title;
  String _createdAt;
  List<String> data;
  List<List<dynamic>> list = [];

  String _oldPath;

  @override
  void initState() {
    if (widget.note != null) {
      _titleEditingController.text = widget.note.title;
      _title = _titleEditingController.text;
      _descriptionEditingController.text = widget.note.description;
      _csv = File(widget.note.content);
      _createdAt = widget.note.dateCreated;

      _oldPath = _csv.path;

      List<List<dynamic>> csvList = _csvToList(_csv);
      _column = csvList[0].length;
      _row = csvList.length;
      _columnTextEditingController.text = _column.toString();
      _rowTextEditingController.text = _row.toString();
    } else {
      _titleEditingController.text = '';
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
    _descriptionEditingController.dispose();
    _rowTextEditingController.dispose();
    _columnTextEditingController.dispose();
    for (int i = 0; i < _listTextEditingController.length; i++) {
      _listTextEditingController[i].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
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
      title: Tooltip(
        message: noteType,
        child: Text((_title != null) ? _title : noteType),
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
      _globalKey.currentState.showSnackBar(
        _buildSnackBarWithButton(
          text: 'Tabelle erstellt. Teilen?',
          onPressed: () => _shareCsv(),
        ),
      );
    } else {
      _globalKey.currentState.showSnackBar(
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

    return WillPopScope(
      onWillPop: () => _saveNote(),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 88.0),
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
            tooltip: 'Beschreibung editieren.',
            elevation: 4.0,
            highlightElevation: 16.0,
            child: Icon(Icons.folder),
            onPressed: () => null,
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
    if (widget.note == null) {
      String path = await _createCsv(_title);
      Note newNote = Note(
        widget.projectTitle,
        'Tabelle',
        _titleEditingController.text.isEmpty
            ? 'Tablenotiz'
            : _titleEditingController.text,
        _descriptionEditingController.text,
        path,
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
    String path = await _createCsv(_title);
    Note newNote = Note.fromMap({
      ProjectDatabaseProvider.columnNoteId: note.id,
      ProjectDatabaseProvider.columnNoteProject: note.project,
      ProjectDatabaseProvider.columnNoteType: note.type,
      ProjectDatabaseProvider.columnNoteTitle:
          _titleEditingController.text.isEmpty
              ? 'Tablenotiz'
              : _titleEditingController.text,
      ProjectDatabaseProvider.columnNoteDescription:
          _descriptionEditingController.text,
      ProjectDatabaseProvider.columnNoteContent: path,
      ProjectDatabaseProvider.columnNoteTableColumn: null,
      ProjectDatabaseProvider.columnNoteTableRow: null,
      ProjectDatabaseProvider.columnNoteCreatedAt: note.dateCreated,
      ProjectDatabaseProvider.columnNoteUpdatedAt: dateFormatted(),
    });
    await _noteDb.updateNote(newNote: newNote);
  }

  Future<void> _shareCsv() async {
    try {
      if (_csv.path != null) {
        final ByteData bytes = await rootBundle.load(_csv.path);
        final Uint8List list = bytes.buffer.asUint8List();

        final tempDir = await getTemporaryDirectory();
        final file = await File('${tempDir.path}/$_title.csv').create();
        file.writeAsBytesSync(list);

        const channelName = 'rahmitufanoglu.citizenlab';
        final channel = const MethodChannel('channel:$channelName.share/share');
        channel.invokeMethod('shareTable', '$_title.csv');
      } else {
        _globalKey.currentState.showSnackBar(
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
            //_row = int.parse(_rowTextEditingController.text);
            //_column = int.parse(_columnTextEditingController.text);

            _title = _titleEditingController.text;

            Navigator.pop(context);
          },
        );
      },
    );
  }

  Future<void> _buildTableCreate() async {
    final String tableSize = 'Titel und Tabellengröße festlegen.';

    return await showDialog(
      context: context,
      builder: (context) {
        return ColumnRowEditingWidget(
          title: tableSize,
          columnEditingController: _columnTextEditingController,
          rowEditingController: _rowTextEditingController,
          titleEditingController: _titleEditingController,
          descEditingController: _descriptionEditingController,
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

    _title = _titleEditingController.text;

    setState(() {});

    Navigator.pop(context);
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

    return SnackBar(
      backgroundColor: Colors.black.withOpacity(0.5),
      duration: Duration(seconds: 5),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            text,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          MaterialButton(
            color: Colors.red,
            child: Text(yes),
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}
