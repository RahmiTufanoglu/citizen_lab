import 'package:flutter/material.dart';

class ColumnRowEditingWidget extends StatefulWidget {
  final String title;
  final TextEditingController titleEditingController;
  final TextEditingController descEditingController;
  final TextEditingController columnEditingController;
  final TextEditingController rowEditingController;
  final GestureTapCallback onPressedClear;
  final GestureTapCallback onPressedCheck;

  ColumnRowEditingWidget({
    @required this.title,
    @required this.titleEditingController,
    @required this.descEditingController,
    @required this.columnEditingController,
    @required this.rowEditingController,
    @required this.onPressedClear,
    @required this.onPressedCheck,
  });

  @override
  _ColumnRowEditingWidgetState createState() => _ColumnRowEditingWidgetState();
}

class _ColumnRowEditingWidgetState extends State<ColumnRowEditingWidget> {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
      contentPadding: const EdgeInsets.all(16.0),
      titlePadding: const EdgeInsets.only(left: 16.0),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            widget.title,
            style: TextStyle(fontSize: 16.0),
          ),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      children: <Widget>[
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
                  controller: widget.columnEditingController,
                  keyboardType: TextInputType.number,
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: 'Spalten',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
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
                  controller: widget.rowEditingController,
                  keyboardType: TextInputType.number,
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: 'Zeilen',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.0),
        TextField(
          controller: widget.titleEditingController,
          keyboardType: TextInputType.text,
          maxLines: 2,
          maxLength: 50,
          decoration: InputDecoration(
            hintText: 'Titel',
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
        ),
        SizedBox(height: 8.0),
        Row(
          children: <Widget>[
            Expanded(
              child: RaisedButton(
                elevation: 4.0,
                highlightElevation: 16.0,
                child: Icon(Icons.remove),
                onPressed: widget.onPressedClear,
              ),
            ),
            SizedBox(width: 8.0),
            Expanded(
              child: RaisedButton(
                elevation: 4.0,
                highlightElevation: 16.0,
                child: Icon(Icons.check),
                onPressed: widget.onPressedCheck,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
