import 'dart:async';

import 'package:citizen_lab/utils/constants.dart';
import 'package:citizen_lab/utils/date_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EditProjectDialog extends StatefulWidget {
  final Key key;
  final TextEditingController titleProjectController;
  final TextEditingController descProjectController;
  final GestureTapCallback onPressedClose;
  final GestureTapCallback onPressedClean;
  final GestureTapCallback onPressedAccept;
  final String createdAt;

  EditProjectDialog({
    this.key,
    @required this.titleProjectController,
    @required this.descProjectController,
    @required this.onPressedClose,
    @required this.onPressedClean,
    @required this.onPressedAccept,
    @required this.createdAt,
  }) : super(key: key);

  @override
  _EditProjectDialogState createState() => _EditProjectDialogState();
}

class _EditProjectDialogState extends State<EditProjectDialog> {
  String _timeString;
  Timer _timer;

  @override
  void initState() {
    _timeString = dateFormatted();
    _timer = Timer.periodic(
      Duration(seconds: 1),
      (Timer t) => _getTime(),
    );

    /*_title = widget.titleProjectController.text;

    widget.titleProjectController.addListener(() {
      setState(() {
        _title = widget.titleProjectController.text;
      });
    });*/

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  void _getTime() {
    final String formattedDateTime = dateFormatted();
    setState(() {
      _timeString = formattedDateTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
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
            padding: const EdgeInsets.only(left: 16.0),
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
                Text(
                  'Erstellt am: ${widget.createdAt}',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: widget.onPressedClose,
          ),
        ],
      ),
      children: <Widget>[
        SizedBox(height: 16.0),
        Text(
          'Titel:',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextFormField(
          controller: widget.titleProjectController,
          keyboardType: TextInputType.text,
          maxLength: 50,
          maxLines: 1,
          decoration: InputDecoration(
            hintText: '$titleHere.',
            labelStyle: TextStyle(fontSize: 14.0),
          ),
        ),
        SizedBox(height: 42.0),
        Text(
          '$desc:',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextFormField(
          controller: widget.descProjectController,
          keyboardType: TextInputType.text,
          maxLength: 500,
          maxLines: 10,
          decoration: InputDecoration(
            hintText: '$descHere.',
            labelStyle: TextStyle(fontSize: 14.0),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: RaisedButton(
                elevation: 4.0,
                highlightElevation: 16.0,
                padding: const EdgeInsets.all(0.0),
                child: Icon(Icons.delete_outline),
                onPressed: widget.onPressedClean,
              ),
            ),
            SizedBox(width: 8.0),
            Expanded(
              child: RaisedButton(
                elevation: 4.0,
                highlightElevation: 16.0,
                padding: const EdgeInsets.all(0.0),
                child: Icon(Icons.check),
                onPressed: widget.onPressedAccept,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
