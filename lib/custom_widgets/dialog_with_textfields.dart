import 'package:flutter/material.dart';

class DialogWithTextFields extends StatefulWidget {
  final Key key;
  final TextEditingController columnTextEditingController;
  final TextEditingController rowTextEditingController;
  final int column;
  final int row;
  final int size;

  DialogWithTextFields({
    this.key,
    @required this.columnTextEditingController,
    @required this.rowTextEditingController,
    @required this.column,
    @required this.row,
    @required this.size,
  }) : super(key: key);

  @override
  _DialogWithTextFieldsState createState() => _DialogWithTextFieldsState();
}

class _DialogWithTextFieldsState extends State<DialogWithTextFields> {
  final String setTableSize = 'Größe der Tabelle festlegen.';
  int _column;
  int _row;
  int _size;

  @override
  void initState() {
    super.initState();

    _column = widget.column;
    _row = widget.row;
  }

  List<int> generateTable() => List<int>.generate(
    _size,
        (i) {
      //_listTextEditingController.add(TextEditingController());
      return i;
    },
  );

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              setTableSize,
              style: TextStyle(fontSize: 16.0),
            ),
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
                      controller: widget.columnTextEditingController,
                      keyboardType: TextInputType.number,
                      maxLines: 1,
                      autofocus: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                        hintText: 'Spalten',
                      ),
                      style: TextStyle(fontSize: 16.0),
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
                      controller: widget.rowTextEditingController,
                      keyboardType: TextInputType.number,
                      maxLines: 1,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                        hintText: 'Zeilen',
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
                      if (widget.rowTextEditingController.text.isNotEmpty) {
                        widget.rowTextEditingController.clear();
                      }

                      if (widget.columnTextEditingController.text.isNotEmpty) {
                        widget.columnTextEditingController.clear();
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
                  //print('${tableColumnController.text}\n${tableRowController.text}',);

                  _column = int.parse(widget.rowTextEditingController.text);
                  _row = int.parse(widget.columnTextEditingController.text);
                  _size = _column * _row;

                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
