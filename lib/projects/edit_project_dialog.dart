import 'dart:async';

import 'package:citizen_lab/app_locations.dart';
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

  const EditProjectDialog({
    @required this.titleProjectController,
    @required this.descProjectController,
    @required this.onPressedClose,
    @required this.onPressedClean,
    @required this.onPressedAccept,
    @required this.createdAt,
    this.key,
  }) : super(key: key);

  @override
  _EditProjectDialogState createState() => _EditProjectDialogState();
}

class _EditProjectDialogState extends State<EditProjectDialog> {
  String _timeString;
  Timer _timer;

  @override
  void initState() {
    super.initState();

    _timeString = dateFormatted();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer t) => _getTime(),
    );

    /*_title = widget.titleProjectController.text;

    widget.titleProjectController.addListener(() {
      setState(() {
        _title = widget.titleProjectController.text;
      });
    });*/
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  void _getTime() {
    final String formattedDateTime = dateFormatted();
    setState(() => _timeString = formattedDateTime);
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      elevation: 4.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
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
                const SizedBox(height: 16.0),
                Text(
                  _timeString,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
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
        const SizedBox(height: 16.0),
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
            hintText: '${AppLocalizations.of(context).translate('titleHere')}.',
            labelStyle: TextStyle(fontSize: 14.0),
          ),
        ),
        const SizedBox(height: 42.0),
        Text(
          '${AppLocalizations.of(context).translate('desc')}:',
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
            hintText: '${AppLocalizations.of(context).translate('descHere')}.',
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
                onPressed: widget.onPressedClean,
                child: Icon(Icons.delete_outline),
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: RaisedButton(
                elevation: 4.0,
                highlightElevation: 16.0,
                padding: const EdgeInsets.all(0.0),
                onPressed: widget.onPressedAccept,
                child: Icon(Icons.check),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
