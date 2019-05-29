import 'package:flutter/material.dart';

class SetTitleWidget extends StatefulWidget {
  final TextEditingController titleTextEditingController;
  final GestureTapCallback onPressed;

  SetTitleWidget({
    @required this.titleTextEditingController,
    @required this.onPressed,
  });

  @override
  _SetTitleWidgetState createState() => _SetTitleWidgetState();
}

class _SetTitleWidgetState extends State<SetTitleWidget> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return _setTitleDialog();
  }

  Widget _setTitleDialog() {
    final String title = 'Titel';
    final String descHere = 'Beschreibung hier';
    final String plsEnterATitle = 'Bitte einen Titel eingeben';

    return Form(
      key: _formKey,
      autovalidate: true,
      child: SimpleDialog(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
        ),
        contentPadding: const EdgeInsets.all(16.0),
        titlePadding: const EdgeInsets.all(0.0),
        title: Align(
          alignment: Alignment.topRight,
          child: IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        children: <Widget>[
          Text(
            '$title:',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextFormField(
            controller: widget.titleTextEditingController,
            keyboardType: TextInputType.text,
            maxLength: 50,
            maxLines: 1,
            decoration: InputDecoration(
              hintText: '$descHere.',
              labelStyle: TextStyle(fontSize: 14.0),
            ),
            validator: (text) => text.isEmpty ? plsEnterATitle : null,
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: RaisedButton(
                  child: Icon(Icons.remove),
                  onPressed: () {
                    if (widget.titleTextEditingController.text.isNotEmpty) {
                      widget.titleTextEditingController.clear();
                    }
                  },
                ),
              ),
              SizedBox(width: 16.0),
              Expanded(
                child: RaisedButton(
                  child: Icon(Icons.check),
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      widget.onPressed();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
