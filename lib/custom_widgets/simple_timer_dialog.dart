import 'dart:async';

import 'package:citizen_lab/utils/date_formater.dart';
import 'package:flutter/material.dart';

class SimpleTimerDialog extends StatefulWidget {
  final Key key;
  final String createdAt;
  final TextEditingController textEditingController;
  final TextEditingController descEditingController;
  final GestureTapCallback onPressedClear;
  final GestureTapCallback onPressedUpdate;
  final GestureTapCallback onPressedClose;
  final bool descExists;

  //final TitleProvider titleProvider;
  //final String title;

  SimpleTimerDialog({
    this.key,
    @required this.createdAt,
    @required this.textEditingController,
    @required this.descEditingController,
    @required this.onPressedClear,
    @required this.onPressedUpdate,
    @required this.onPressedClose,
    @required this.descExists,
    //@required this.titleProvider,
    //@required this.title,
  }) : super(key: key);

  @override
  _SimpleTimerDialogState createState() => _SimpleTimerDialogState();
}

class _SimpleTimerDialogState extends State<SimpleTimerDialog> {
  final _formKey = GlobalKey<FormState>();
  String _timeString;
  Timer _timer;

  @override
  void initState() {
    _timeString = dateFormatted();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _getTime() {
    final String formattedDateTime = dateFormatted();
    setState(() {
      _timeString = formattedDateTime;
    });
  }

  @override
  Widget build(BuildContext context) => _buildDialog();

  Widget _buildDialog() {
    final double screenWidth = MediaQuery.of(context).size.width;

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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 16.0),
                  Text(
                    _timeString,
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Container(
                    width: screenWidth / 2,
                    child: Text(
                      'Erstellt am: ${widget.createdAt}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.0,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close,
                size: 24.0,
              ),
              onPressed: widget.onPressedClose,
            ),
          ],
        ),
        children: <Widget>[
          Text(
            'Titel:',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextFormField(
            controller: widget.textEditingController,
            keyboardType: TextInputType.text,
            maxLength: 50,
            maxLines: 1,
            decoration: InputDecoration(
              hintText: 'Titel hier.',
              labelStyle: TextStyle(fontSize: 14.0),
            ),
            validator: (text) =>
                text.isEmpty ? 'Bitte einen Titel eingeben' : null,
            //onChanged: (String changed) => widget.textEditingController.text = changed,
            /*onChanged: (changed) {
              widget.titleProvider.setTitle(changed);
              widget.title = widget.titleProvider.getTitle;
              (widget.title.isEmpty)
                  ? _titleValidate = true
                  : _titleValidate = false;
            },*/
          ),
          SizedBox(height: 56.0),
          _descWidget(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: RaisedButton(
                  elevation: 4.0,
                  highlightElevation: 16.0,
                  padding: const EdgeInsets.all(0.0),
                  child: Icon(Icons.remove),
                  onPressed: widget.onPressedClear,
                ),
              ),
              SizedBox(width: 16.0),
              Expanded(
                child: RaisedButton(
                  elevation: 4.0,
                  highlightElevation: 16.0,
                  padding: const EdgeInsets.all(0.0),
                  child: Icon(Icons.check),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      widget.onPressedUpdate();
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

  Widget _descWidget() {
    if (widget.descExists) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Beschreibung:',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextField(
            controller: widget.descEditingController,
            keyboardType: TextInputType.text,
            maxLength: 50,
            maxLines: 1,
            decoration: InputDecoration(
              hintText: 'Beschreibung hier.',
              labelStyle: TextStyle(fontSize: 14.0),
            ),
          ),
          SizedBox(height: 42.0),
        ],
      );
    } else {
      return Container();
    }
  }
}
