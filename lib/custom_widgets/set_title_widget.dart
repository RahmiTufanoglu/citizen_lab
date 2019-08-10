import 'package:flutter/material.dart';

class SetTitleWidget extends StatefulWidget {
  final TextEditingController titleTextEditingController;
  final GestureTapCallback onPressed;

  const SetTitleWidget({
    @required this.titleTextEditingController,
    @required this.onPressed,
  })  : assert(titleTextEditingController != null),
        assert(onPressed != null);

  @override
  _SetTitleWidgetState createState() => _SetTitleWidgetState();
}

class _SetTitleWidgetState extends State<SetTitleWidget> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) => _setTitleDialog();

  Widget _setTitleDialog() {
    const String title = 'Titel';
    const String descHere = 'Beschreibung hier';
    const String plsEnterATitle = 'Bitte einen Titel eingeben';

    return Form(
      key: _formKey,
      autovalidate: true,
      child: SimpleDialog(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(
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
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: RaisedButton(
                  onPressed: () {
                    if (widget.titleTextEditingController.text.isNotEmpty) {
                      widget.titleTextEditingController.clear();
                    }
                  },
                  child: Icon(Icons.remove),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: RaisedButton(
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      widget.onPressed();
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
