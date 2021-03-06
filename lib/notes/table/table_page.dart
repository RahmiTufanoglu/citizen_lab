import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:citizen_lab/custom_widgets/column_row_edit_widget.dart';
import 'package:citizen_lab/custom_widgets/custom_widgets.dart';
import 'package:citizen_lab/custom_widgets/simple_timer_dialog.dart';
import 'package:citizen_lab/database/database_helper.dart';
import 'package:citizen_lab/notes/note.dart';
import 'package:citizen_lab/notes/table/table_info_page_data.dart';
import 'package:citizen_lab/themes/theme_changer_provider.dart';
import 'package:citizen_lab/utils/date_formatter.dart';
import 'package:citizen_lab/utils/route_generator.dart';
import 'package:csv/csv.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class TablePage extends StatefulWidget {
  final Note note;
  final String uuid;

  const TablePage({
    @required this.note,
    @required this.uuid,
  });

  @override
  _TablePageState createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _titleEditingController = TextEditingController();
  final _descriptionEditingController = TextEditingController();
  final _rowTextEditingController = TextEditingController();
  final _columnTextEditingController = TextEditingController();
  //final _listTextEditingController = List<TextEditingController>();
  final _listTextEditingController = <TextEditingController>[];

  File _csv;
  int _column;
  int _row;
  String _title;
  String _createdAt;

  @override
  void initState() {
    super.initState();

    if (widget.note != null) {
      _titleEditingController.text = widget.note.title;
      _title = _titleEditingController.text;
      _descriptionEditingController.text = widget.note.description;
      _csv = File(widget.note.filePath);
      _createdAt = widget.note.createdAt;

      if (_column != null && _row != null) {
        final List<List<dynamic>> csvList = _csvToList(_csv);
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
      resizeToAvoidBottomPadding: false,
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFabs(),
    );
  }

  Widget _buildAppBar() {
    const String back = 'Zurück';
    const String noteType = 'Tabellennotiz';

    return AppBar(
      leading: IconButton(
        tooltip: back,
        icon: Icon(Icons.arrow_back),
        onPressed: _saveNote,
      ),
      title: Consumer(
        builder: (
          BuildContext context,
          ThemeChangerProvider themeChangerProvider,
          Widget child,
        ) {
          return GestureDetector(
            onPanStart: (_) => themeChangerProvider.setTheme(),
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

  void _shareContent() {
    if (_title != null && !_checkIfTableIsEmpty()) {
      // TODO: Check if File exists
      if (_csv == null) _createCsv(_title);

      /*_scaffoldKey.currentState.showSnackBar(
        _buildSnackBarWithButton(
          text: 'Tabelle erstellt. Teilen?',
          onPressed: () => _shareCsv(),
        ),
      );*/

      Future.delayed(const Duration(milliseconds: 500), () => _shareCsv());
      /*_scaffoldKey.currentState.showSnackBar(
        _buildSnackBar(text: 'Tabelle kann nicht geteilt werden.'),
      );*/
    } else {
      _scaffoldKey.currentState.showSnackBar(
        _buildSnackBar(text: 'Bitte einen Titel eingeben.'),
      );
    }
  }

  void _setInfoPage() {
    Navigator.pushNamed(
      context,
      CustomRoute.infoPage,
      arguments: {
        argTitle: 'Tabellen-Info',
        argTabLength: 2,
        argTabs: tableTabList,
        argTabChildren: tableSingleChildScrollViewList,
      },
    );
  }

  Widget _buildBody() {
    _generateTable();

    return SafeArea(
      child: WillPopScope(
        onWillPop: () => _saveNote(),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 88.0),
          child: _column != null || _row != null
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

  void _generateTable() {
    if (widget.note == null) {
      if (_row != null && _column != null) {
        for (int x = 0; x < _row; x++) {
          for (int y = 0; y < _column; y++) {
            _listTextEditingController.add(TextEditingController());
          }
        }
      }
    } else {
      final List<List<dynamic>> csvList = _csvToList(_csv);
      _column = csvList[0].length;
      _row = csvList.length;

      for (int i = 0; i < (_column * _row); i++) {
        _listTextEditingController.add(TextEditingController());
      }

      _csvRead(csvList, _column, _row);
    }
  }

  void _csvRead(List<List> list, int column, int row) {
    final List newCsvList = [];
    int tmp = 0;
    for (int i = 0; i < row; i++) {
      for (int j = 0; j < column; j++) {
        newCsvList.add(list[i][j].toString());
        _listTextEditingController[tmp++].text = list[i][j].toString();
      }
    }
  }

  List<List> _csvToList(File myCsvFile) {
    final List<List<dynamic>> listCreated = const CsvToListConverter().convert(myCsvFile.readAsStringSync());
    return listCreated;
  }

  String _listToCsv(List listToConvert) => const ListToCsvConverter().convert(listToConvert);

  Widget _buildFabs() => Padding(
        padding: const EdgeInsets.only(left: 32.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FloatingActionButton(
              heroTag: null,
              tooltip: 'Beschreibung editieren.',
              elevation: 4.0,
              highlightElevation: 16.0,
              onPressed: () => _showDialogEditImage(),
              child: Icon(Icons.description),
            ),
            FloatingActionButton(
              heroTag: null,
              tooltip: 'Tabelle leeren.',
              elevation: 4.0,
              highlightElevation: 16.0,
              onPressed: () => _clearTableContent(),
              child: Icon(Icons.remove),
            ),
            FloatingActionButton(
              heroTag: null,
              tooltip: 'Tabelle erstellen.',
              elevation: 4.0,
              highlightElevation: 16.0,
              onPressed: () => _buildTableCreate(),
              child: const Icon(Icons.add),
            ),
          ],
        ),
      );

  void _clearTableContent() {
    for (int i = 0; i < _listTextEditingController.length; i++) {
      if (_listTextEditingController[i].text.isNotEmpty) {
        _listTextEditingController[i].clear();
      }
    }
  }

  bool _checkIfTableIsEmpty() {
    bool empty = false;
    int count = 0;
    for (int i = 0; i < _listTextEditingController.length; i++) {
      if (_listTextEditingController[i].text.isEmpty) count++;
    }

    print(count);
    print(_listTextEditingController.length);
    count == _listTextEditingController.length ? empty = true : empty = false;
    return empty;
  }

  Future<void> _saveNote() async {
    if (_titleEditingController.text.isNotEmpty && _column != null && _row != null && !_checkIfTableIsEmpty()) {
      if (widget.note == null) {
        String path = '';
        if (_column != null && _row != null) {
          path = await _createCsv(_title);
          //path = _csv.path;
        }
        final Note note = Note(
          widget.uuid,
          'Tabelle',
          _titleEditingController.text,
          _descriptionEditingController.text,
          path,
          _createdAt,
          dateFormatted(),
          0,
          0,
          0xFFFFFFFF,
          0xFF000000,
        );
        Navigator.pop(context, note);
      } else {
        await _csv.delete();
        //String path = _csv.path;
        // TODO: Do not create CSV if exists
        final String path = await _createCsv(_title);
        await _updateNote(widget.note, path);
      }
    } else {
      _scaffoldKey.currentState.showSnackBar(
        _buildSnackBarWithButton(
          text: 'Titel oder Tabelle unvollständig.\nNotiz abbrechen?',
          onPressed: () => Navigator.pop(context),
        ),
      );
    }
  }

  Future<void> _updateNote(Note note, String path) async {
    final Note newNote = Note.fromMap({
      DatabaseHelper.columnNoteId: note.id,
      DatabaseHelper.columnProjectUuid: note.uuid,
      DatabaseHelper.columnNoteType: note.type,
      DatabaseHelper.columnNoteTitle: _titleEditingController.text,
      DatabaseHelper.columnNoteDescription: _descriptionEditingController.text,
      DatabaseHelper.columnNoteContent: path,
      DatabaseHelper.columnNoteCreatedAt: note.createdAt,
      DatabaseHelper.columnNoteUpdatedAt: dateFormatted(),
      DatabaseHelper.columnNoteIsFirstTime: 1,
      DatabaseHelper.columnNoteIsEdited: 0,
      DatabaseHelper.columnNoteCardColor: note.cardColor,
      DatabaseHelper.columnNoteCardTextColor: note.cardTextColor,
    });
    Navigator.pop(context, newNote);
  }

  Future<void> _shareCsv() async {
    //try {
    /*final ByteData bytes = await rootBundle.load(_csv.path);
      final Uint8List uint8List = bytes.buffer.asUint8List();
      await Share.file(
        'table',
        '$_title.csv',
        uint8List,
        'table/csv',
        text: _title,
      );*/

    if (Platform.isAndroid) {
      final ByteData bytes = await rootBundle.load(_csv.path);
      final Uint8List uint8List = bytes.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/$_title.csv').create();
      file.writeAsBytesSync(uint8List);

      const channelName = 'rahmitufanoglu.citizenlab';
      const channel = MethodChannel('channel:$channelName.share/share');
      await channel.invokeMethod('shareTable', '$_title.csv');
    } else if (Platform.isIOS) {
      final ByteData bytes = await rootBundle.load(_csv.path);
      await Share.file(
        'table',
        '$_title.csv',
        bytes.buffer.asUint8List(),
        'table/csv',
        text: _title,
      );
    }
    /*} catch (error) {
      debugPrint('Share $error');
    }*/
  }

  void _showDialogEditImage() {
    final String oldTitle = _title;

    showDialog(
      context: context,
      builder: (context) {
        return SimpleTimerDialog(
          createdAt: _createdAt,
          textEditingController: _titleEditingController,
          descEditingController: _descriptionEditingController,
          descExists: true,
          onPressedClose: () {
            _titleEditingController.text = oldTitle;
            Navigator.of(context).pop();
          },
          onPressedClear: () {
            _titleEditingController.clear();
            _descriptionEditingController.clear();
          },
          onPressedUpdate: () {
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _buildTableCreate() {
    const String enterTableSize = 'Titel und Tabellengröße festlegen.';
    showDialog(
      context: context,
      builder: (_) {
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

  Future<String> _createCsv(String title) async {
    final List<List<String>> graphArray = List.generate(
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

    //String dir = (await getTemporaryDirectory()).absolute.path + '/';
    //_csv = File('$dir$title.csv');

    _csv = File(await _localPath(title));

    final String path = _listToCsv(graphArray);
    await _csv.writeAsString(path);

    return _csv.path;
  }

  Future<String> _localPath(String title) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$title.csv';
    return path;
  }

  void _clearAllFields() {
    _rowTextEditingController.clear();
    _columnTextEditingController.clear();
    _titleEditingController.clear();
    _descriptionEditingController.clear();
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
      duration: const Duration(milliseconds: 500),
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
    const String no = 'Nein';
    const String yes = 'Ja';

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
              child: const Text(no),
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
              child: const Text(yes),
            ),
          ),
        ],
      ),
    );
  }
}
