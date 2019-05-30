import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:citizen_lab/custom_widgets/no_yes_dialog.dart';
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
  final _columnTextEditingController = TextEditingController();
  final _rowTextEditingController = TextEditingController();
  final _noteDb = ProjectDatabaseProvider();
  final List<TextEditingController> _listTextEditingController = [];

  File _csv;
  int _column;
  int _row;
  String _title;
  String _createdAt;
  String csv;
  String _timeString;

  //Timer _timer;

  final csvCodec = CsvCodec();

  bool _tableExists = false;
  int _oldRow;
  int _oldColumn;

  List<String> data;
  int _size;

  List<List> list = [];

  @override
  void initState() {
    super.initState();
    _timeString = dateFormatted();
    /*_timer = Timer.periodic(
      Duration(seconds: 1),
      (Timer t) => _getTime(),
    );*/

    if (widget.note != null) {
      _titleEditingController.text = widget.note.title;
      _title = _titleEditingController.text;
      _column = widget.note.tableColumn;
      _row = widget.note.tableRow;
      _csv = File(widget.note.content);
      _createdAt = widget.note.dateCreated;

      _size = _column * _row;
      _oldColumn = _column;
      _oldRow = _row;

      for (int i = 0; i < _size; i++) {
        _listTextEditingController.add(TextEditingController());
      }
    } else {
      _titleEditingController.text = '';
      _createdAt = dateFormatted();
    }

    _titleEditingController.addListener(() {
      setState(() {
        _title = _titleEditingController.text;
      });
    });
  }

  @override
  void dispose() {
    _titleEditingController.dispose();
    _descriptionEditingController.dispose();
    _columnTextEditingController.dispose();
    _rowTextEditingController.dispose();
    for (int i = 0; i < _listTextEditingController.length; i++) {
      _listTextEditingController[i].dispose();
    }
    //_timer.cancel();
    super.dispose();
  }

  List<int> generateTable2() {
    return List<int>.generate(
      _column * _row,
      (i) {
        widget.note == null
            ? _listTextEditingController.add(TextEditingController())
            : _csvToList();
        return i;
      },
    );
  }

  generateTable() {
    if (widget.note == null) {
      if (_row != null && _column != null) {
        for (int x = 0; x < _row; x++) {
          for (int y = 0; y < _column; y++) {
            _listTextEditingController.add(TextEditingController());
          }
        }
      }
    } else {
      _csvToList();
    }

    /*return List<int>.generate(
      _column * _row,
      (i) {
        widget.note == null
            ? _listTextEditingController.add(TextEditingController())
            : _csvToList();
        return i;
      },
    );*/
  }

  Future<String> _loadCsv(String path) async {
    return await rootBundle.loadString(path);
  }

  void _csvToList() async {
    final csvData = await _loadCsv(_csv.path);
    final List<List> csvTable = CsvToListConverter().convert(csvData);
    list = csvTable;

    _openCsvTable();
  }

  Future<void> _openCsvTable() async {
    int i = 0;
    for (int x = 0; x < _row; x++) {
      for (int y = 0; y < _column; y++) {
        //_listTextEditingController[i++].text = list[x][y];
        _listTextEditingController[i++].text = list[x][y].toString();
        /*_listTextEditingController.add(
          TextEditingController(text: list[x][y]),
        );*/
      }
    }
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

  void _getTime() async {
    final String formattedDateTime = dateFormatted();
    if (mounted) {
      setState(() {
        _timeString = formattedDateTime;
      });
    }
  }

  Widget _buildAppBar() {
    final back = 'Zurück';
    final noteType = 'Tabellennotiz';

    return AppBar(
      leading: IconButton(
        tooltip: back,
        icon: Icon(Icons.arrow_back),
        onPressed: () => _saveNote(),
      ),
      title: Tooltip(
        message: noteType,
        child: Text(_title != null ? _title : noteType),
      ),
      actions: <Widget>[
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

  Widget _buildBody2() {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 24.0) / 2.0;
    final double itemWidth = size.width / 0.5;

    return WillPopScope(
      onWillPop: () => _saveNote(),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 88.0),
        child: (_row != null || _column != null)
            ? GridView.count(
                crossAxisCount: _column,
                crossAxisSpacing: 0.0,
                childAspectRatio: (itemWidth / itemHeight),
                shrinkWrap: false,
                children: generateTable().map((int i) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: TextFormField(
                      controller: _listTextEditingController[i],
                      decoration: InputDecoration(
                        hintText: i.toString(),
                        contentPadding: const EdgeInsets.all(16.0),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                      ),
                    ),
                  );
                }).toList(),
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

  Widget _buildBody() {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 24.0) / 2.0;
    final double itemWidth = size.width / 0.5;

    generateTable();

    return WillPopScope(
      onWillPop: () => _saveNote(),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 88.0),
        child: (_column != null || _row != null)
            ? GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _column,
                  crossAxisSpacing: 0.0,
                  childAspectRatio: (itemWidth / itemHeight),
                ),
                itemCount: (_size == null) ? _column * _row : _size,
                shrinkWrap: false,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: TextFormField(
                      controller: _listTextEditingController[index],
                      decoration: InputDecoration(
                        hintText: index.toString(),
                        contentPadding: const EdgeInsets.all(16.0),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                      ),
                    ),
                  );
                },
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
            tooltip: 'Tabelle erstellen.',
            elevation: 4.0,
            highlightElevation: 16.0,
            child: Icon(Icons.add),
            onPressed: () => _buildTableCreate(),
          ),
          FloatingActionButton(
            heroTag: null,
            tooltip: 'Tabelle teilen.',
            elevation: 4.0,
            highlightElevation: 16.0,
            child: Icon(Icons.share),
            onPressed: () {
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
            },
          ),
        ],
      ),
    );
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

    csv = const ListToCsvConverter().convert(graphArray);

    String dir = (await getTemporaryDirectory()).absolute.path + '/';

    // TODO CHECK TITLE NAME IS NOT NULL!!!
    _csv = File('$dir' + '$title.csv');
    _csv.writeAsString(csv);

    return _csv.path;
  }

  _saveNote() async {
    final String noNote =
        'Keine Tabelle erstellt.\nWollen sie die Notiz abbrechen?';

    String message;

    if (_column != null && _row != null && _title != null) {
      if (widget.note == null) {
        String path = await _createCsv(_title);
        Note newNote = Note(
          widget.projectTitle,
          'Tabelle',
          _titleEditingController.text.isEmpty
              ? _titleEditingController.text = ''
              : _titleEditingController.text,
          _descriptionEditingController.text.isEmpty
              ? _descriptionEditingController.text = ''
              : _descriptionEditingController.text,
          path,
          _column,
          _row,
          _createdAt,
          dateFormatted(),
        );
        await _noteDb.insertNote(note: newNote);
        message = 'gespeichert';
      } else {
        _updateNote(widget.note);
        message = 'editiert';
      }
      Navigator.pop(context, message);
    } else {
      _globalKey.currentState.showSnackBar(
        _buildSnackBarWithButton(
          text: noNote,
          onPressed: () => Navigator.pop(context),
        ),
      );
    }
  }

  void _updateNote(Note note) async {
    Note newNote = Note.fromMap({
      ProjectDatabaseProvider.columnNoteId: note.id,
      ProjectDatabaseProvider.columnNoteProject: note.project,
      ProjectDatabaseProvider.columnNoteType: note.type,
      ProjectDatabaseProvider.columnNoteTitle: _title,
      // TODO description updaten
      ProjectDatabaseProvider.columnNoteDescription: note.description,
      ProjectDatabaseProvider.columnNoteContent: _csv.path,
      ProjectDatabaseProvider.columnNoteTableColumn:
          _columnTextEditingController.text.isEmpty
              ? _column
              : _columnTextEditingController.text,
      ProjectDatabaseProvider.columnNoteTableRow:
          _rowTextEditingController.text.isEmpty
              ? _row
              : _rowTextEditingController.text,
      ProjectDatabaseProvider.columnNoteCreatedAt: note.dateCreated,
      ProjectDatabaseProvider.columnNoteUpdatedAt: dateFormatted(),
    });
    await _noteDb.updateNote(newNote: newNote);
  }

  _shareCsv() async {
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

  _showDialogEditImage() async {
    await showDialog(
      context: context,
      builder: (context) {
        return SimpleTimerDialog(
          createdAt: _createdAt,
          textEditingController: _titleEditingController,
          descEditingController: _descriptionEditingController,
          descExists: false,
          onPressedClose: () => Navigator.of(context).pop(),
          onPressedClear: () {
            if (_titleEditingController.text.isNotEmpty) {
              _titleEditingController.clear();
            }
          },
          onPressedUpdate: () {
            _row = int.parse(_columnTextEditingController.text);
            _column = int.parse(_rowTextEditingController.text);

            setState(() {
              _title = _titleEditingController.text;
            });

            Navigator.pop(context);
          },
        );
      },
    );
  }

  _buildTableCreate() async {
    final String tableSize = 'Titel und Tabellengröße festlegen.';

    return await showDialog(
      context: context,
      builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    tableSize,
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(
                            top: 8.0,
                            bottom: 8.0,
                            right: 8.0,
                          ),
                          child: TextField(
                            controller: _columnTextEditingController,
                            keyboardType: TextInputType.number,
                            maxLines: 1,
                            decoration: InputDecoration(
                              hintText: 'Spalten',
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(
                            top: 8.0,
                            bottom: 8.0,
                            left: 8.0,
                          ),
                          child: TextField(
                            controller: _rowTextEditingController,
                            keyboardType: TextInputType.number,
                            maxLines: 1,
                            decoration: InputDecoration(
                              hintText: 'Zeilen',
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    controller: _descriptionEditingController,
                    keyboardType: TextInputType.text,
                    maxLines: 2,
                    maxLength: 50,
                    decoration: InputDecoration(
                      hintText: 'Titel',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  TextField(
                    controller: _titleEditingController,
                    keyboardType: TextInputType.text,
                    maxLines: 10,
                    maxLength: 200,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      hintText: 'Beschreibung',
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          elevation: 4.0,
                          highlightElevation: 16.0,
                          child: Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: RaisedButton(
                          elevation: 4.0,
                          highlightElevation: 16.0,
                          child: Icon(Icons.delete),
                          onPressed: () {
                            if (_columnTextEditingController.text.isNotEmpty) {
                              _columnTextEditingController.clear();
                            }

                            if (_rowTextEditingController.text.isNotEmpty) {
                              _rowTextEditingController.clear();
                            }

                            if (_titleEditingController.text.isNotEmpty) {
                              _titleEditingController.clear();
                            }

                            if (_descriptionEditingController.text.isNotEmpty) {
                              _descriptionEditingController.clear();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    child: RaisedButton(
                      elevation: 4.0,
                      highlightElevation: 16.0,
                      child: Icon(Icons.check),
                      onPressed: () {
                        _column = int.parse(_columnTextEditingController.text);
                        _row = int.parse(_rowTextEditingController.text);

                        setState(() {
                          _title = _titleEditingController.text;
                        });

                        _tableExists = true;

                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
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
