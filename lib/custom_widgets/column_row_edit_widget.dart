import 'package:citizen_lab/utils/utils.dart';
import 'package:flutter/material.dart';

class ColumnRowEditingWidget extends StatefulWidget {
  final Key key;
  final String title;
  final TextEditingController titleEditingController;
  final TextEditingController columnEditingController;
  final TextEditingController rowEditingController;
  final GestureTapCallback onPressedClear;
  final GestureTapCallback onPressedCheck;

  const ColumnRowEditingWidget({
    @required this.title,
    @required this.titleEditingController,
    @required this.columnEditingController,
    @required this.rowEditingController,
    @required this.onPressedClear,
    @required this.onPressedCheck,
    this.key,
  }) : super(key: key);

  @override
  _ColumnRowEditingWidgetState createState() => _ColumnRowEditingWidgetState();
}

class _ColumnRowEditingWidgetState extends State<ColumnRowEditingWidget> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) => _buildDialog();

  Widget _buildDialog() {
    const String plsEnterANumber = 'Bitte eine\nZahl unter\n 9 eingeben.';

    return Form(
      key: _formKey,
      autovalidate: true,
      child: SimpleDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        contentPadding: const EdgeInsets.all(16.0),
        titlePadding: const EdgeInsets.only(left: 0.0),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                widget.title,
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        children: <Widget>[
          TextFormField(
            controller: widget.titleEditingController,
            keyboardType: TextInputType.text,
            maxLength: 50,
            maxLines: 1,
            decoration: InputDecoration(
              hintText: 'Titel hier',
              labelStyle: TextStyle(fontSize: 14.0),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
            validator: (text) => text.isEmpty ? 'Bitte einen Titel eingeben' : null,
          ),
          const SizedBox(height: 8.0),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  child: TextFormField(
                    controller: widget.columnEditingController,
                    keyboardType: TextInputType.number,
                    maxLength: 2,
                    maxLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Spalten',
                      labelStyle: TextStyle(fontSize: 14.0),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    validator: (text) {
                      final bool _columnNumeric = isNumeric(widget.columnEditingController.text);

                      if (text.isEmpty || !_columnNumeric || text.length > 8) {
                        return plsEnterANumber;
                      } else {
                        return null;
                      }
                    },
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
                  child: TextFormField(
                    controller: widget.rowEditingController,
                    keyboardType: TextInputType.number,
                    maxLength: 2,
                    maxLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Zeilen',
                      labelStyle: TextStyle(fontSize: 14.0),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    validator: (text) {
                      final bool _rowNumeric = isNumeric(widget.rowEditingController.text);

                      if (text.isEmpty || !_rowNumeric) {
                        return plsEnterANumber;
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            children: <Widget>[
              Expanded(
                child: RaisedButton(
                  elevation: 4.0,
                  highlightElevation: 16.0,
                  onPressed: widget.onPressedClear,
                  child: Icon(Icons.remove),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: RaisedButton(
                  elevation: 4.0,
                  highlightElevation: 16.0,
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      widget.onPressedCheck();
                    }
                  },
                  child: Icon(Icons.check),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
