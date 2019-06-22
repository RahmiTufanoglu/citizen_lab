import 'dart:async';

import 'package:citizen_lab/utils/date_formater.dart';
import 'package:flutter/material.dart';

class TitleDescWidget extends StatefulWidget {
  final Key key;
  final String title;
  final String createdAt;
  final titleEditingController;
  final descEditingController;

  TitleDescWidget({
    this.key,
    @required this.title,
    @required this.createdAt,
    @required this.titleEditingController,
    @required this.descEditingController,
  }) : super(key: key);

  @override
  _TitleDescWidgetState createState() => _TitleDescWidgetState();
}

class _TitleDescWidgetState extends State<TitleDescWidget> {
  final _formKey = GlobalKey<FormState>();
  Timer _timer;
  String _timeString;

  @override
  void initState() {
    _timeString = dateFormatted();
    _timer = Timer.periodic(Duration(seconds: 1), (_) => _getTime());

    /*_titleEditingController.addListener(() {
      setState(() {
        if (_titleEditingController.text.isNotEmpty) {
          _title = _titleEditingController.text;
        }
      });
    });*/

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
  Widget build(BuildContext context) {
    return _buildWidget();
  }

  Widget _buildWidget() {
    final created = 'Erstellt am';
    final title = 'Titel';
    final titleHere = 'Titel hier';
    final content = 'Inhalt';
    final contentHere = 'Inhalt hier';
    final String plsEnterATitle = 'Bitte einen Titel eingeben';
    String pageTitle = widget.title;

    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 8.0, bottom: 88.0),
      child: Form(
        //key: widget.key,
        key: _formKey,
        autovalidate: true,
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(8.0),
              decoration: ShapeDecoration(
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      _timeString,
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      '$created: ${widget.createdAt}',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    controller: widget.titleEditingController,
                    keyboardType: TextInputType.text,
                    maxLines: 2,
                    maxLength: 50,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: '$titleHere.',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      //errorText: _titleValidate ? plsEnterATitle : null,
                    ),
                    //onChanged: (String changed) => pageTitle = changed,
                    validator: (text) => text.isEmpty ? plsEnterATitle : null,
                    //onSaved: (String value) => pageTitle = value,
                  ),
                  SizedBox(height: 42.0),
                  TextFormField(
                    controller: widget.descEditingController,
                    keyboardType: TextInputType.text,
                    maxLines: 20,
                    maxLength: 500,
                    style: TextStyle(fontSize: 16.0),
                    decoration: InputDecoration(
                      hintText: '$contentHere.',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
