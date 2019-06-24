import 'dart:async';

import 'package:citizen_lab/utils/date_formater.dart';
import 'package:flutter/material.dart';

class TitleDescWidget extends StatefulWidget {
  final Key key;
  final String title;
  final String createdAt;
  final titleEditingController;
  final descEditingController;
  final titleBloc;

  TitleDescWidget({
    this.key,
    @required this.title,
    @required this.createdAt,
    @required this.titleEditingController,
    @required this.descEditingController,
    @required this.titleBloc,
  }) : super(key: key);

  @override
  _TitleDescWidgetState createState() => _TitleDescWidgetState();
}

class _TitleDescWidgetState extends State<TitleDescWidget> {
  Timer _timer;
  String _timeString;

  @override
  void initState() {
    _timeString = dateFormatted();
    _timer = Timer.periodic(Duration(seconds: 1), (_) => _getTime());

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

    return ListView(
      padding: EdgeInsets.only(bottom: 88.0),
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
        Card(
          margin: EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                StreamBuilder(
                  stream: widget.titleBloc.title,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    return TextField(
                      controller: widget.titleEditingController,
                      keyboardType: TextInputType.text,
                      maxLines: 2,
                      maxLength: 50,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                      //onChanged: widget.titleBloc.changeTitle,
                      onChanged: widget.titleBloc.changeTitle,
                      decoration: InputDecoration(
                        hintText: '$titleHere.',
                        errorText: snapshot.error,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                      ),
                      //onChanged: (String changed) => pageTitle = changed,
                      //validator: (text) => text.isEmpty ? plsEnterATitle : null,
                    );
                    /*return _buildTextField(
                      controller: widget.descEditingController,
                      maxLines: 2,
                      maxLength: 50,
                      hintText: titleHere,
                      onChanged: widget.titleBloc.changeTitle,
                    );*/
                  },
                ),
                Divider(color: Colors.black),
                _buildTextField(
                  controller: widget.descEditingController,
                  maxLines: 20,
                  maxLength: 500,
                  hintText: contentHere,
                  onChanged: null,
                ),
                /*TextField(
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
                ),*/
              ],
            ),
          ),
        ),
      ],
    );
  }

  TextField _buildTextField({
    @required TextEditingController controller,
    @required int maxLines,
    @required int maxLength,
    @required String hintText,
    @required ValueChanged onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.text,
      maxLines: maxLines,
      maxLength: maxLength,
      style: TextStyle(fontSize: 16.0),
      onChanged: (_) => onChanged,
      decoration: InputDecoration(
        hintText: '$hintText.',
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        ),
      ),
    );
  }
}
