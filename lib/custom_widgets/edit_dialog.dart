import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:citizen_lab/utils/colors.dart';
import 'package:citizen_lab/utils/date_formater.dart';

class EditDialog extends StatefulWidget {
  final Key key;
  final Color dividerColor;
  final TextEditingController controllerTitle;
  final TextEditingController controllerContent;
  final String releaseDate;
  final String textFieldTitleTop;
  final String textFieldTitleBottom;
  final String titleErrorMessage;
  final String contentErrorMessage;
  final IconData btnIconLeft;
  final IconData btnIconRight;
  final GestureTapCallback onTapLeftBtn;
  final GestureTapCallback onTapRightBtn;

  EditDialog({
    this.key,
    this.dividerColor = const Color(0xFFE9E9E9),
    @required this.controllerTitle,
    @required this.controllerContent,
    @required this.releaseDate,
    @required this.textFieldTitleTop,
    @required this.textFieldTitleBottom,
    @required this.titleErrorMessage,
    @required this.contentErrorMessage,
    @required this.btnIconLeft,
    @required this.btnIconRight,
    @required this.onTapLeftBtn,
    @required this.onTapRightBtn,
  }) : super(key: key);

  @override
  _EditDialogState createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  final _formKey = GlobalKey<FormState>();

  String _timeString;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _timeString = dateFormatted();
    _timer = Timer.periodic(
      Duration(seconds: 1),
      (Timer t) => _getTime(),
    );
  }

  void _getTime() {
    final String formattedDateTime = dateFormatted();
    setState(() {
      _timeString = formattedDateTime;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
        ),
        child: Dialog(
          elevation: 8.0,
          child: Scrollbar(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              shrinkWrap: true,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      _timeString,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.black,
                      ),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                  ],
                ),
                Text(
                  'Erstellt am: ' + widget.releaseDate,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.0,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 8.0),
                Container(
                  height: 1.0,
                  width: double.infinity,
                  color: widget.dividerColor,
                ),
                SizedBox(height: 8.0),
                TextFormField(
                  controller: widget.controllerTitle,
                  cursorColor: Colors.black,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 2,
                  maxLength: 50,
                  autovalidate: true,
                  validator: (value) =>
                      value.isEmpty ? widget.titleErrorMessage : null,
                  decoration: InputDecoration(
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    labelText: widget.textFieldTitleTop,
                    hintStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                    ),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.8),
                      ),
                    ),
                  ),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh),
                  color: Colors.black,
                  onPressed: () => widget.controllerTitle.clear(),
                ),
                TextFormField(
                  controller: widget.controllerContent,
                  cursorColor: Colors.black,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 10,
                  maxLength: 250,
                  autovalidate: true,
                  validator: (value) =>
                      value.isEmpty ? widget.contentErrorMessage : null,
                  decoration: InputDecoration(
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    labelText: widget.textFieldTitleBottom,
                    hintStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                    ),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.8),
                      ),
                    ),
                  ),
                  style: TextStyle(fontSize: 16.0),
                ),
                IconButton(
                  icon: Icon(
                    Icons.refresh,
                    color: Colors.black,
                  ),
                  color: Colors.black,
                  onPressed: () => widget.controllerContent.clear(),
                ),
                Container(
                  height: 1.0,
                  width: double.infinity,
                  color: widget.dividerColor,
                ),
                SizedBox(height: 8.0),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        color: Colors.white,
                        highlightColor: Colors.grey.withOpacity(0.2),
                        splashColor: main_color.withOpacity(0.8),
                        elevation: 4.0,
                        highlightElevation: 16.0,
                        child: Icon(
                          widget.btnIconLeft,
                          color: Colors.black,
                        ),
                        onPressed: widget.onTapLeftBtn,
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: RaisedButton(
                        color: Colors.white,
                        highlightColor: Colors.green.withOpacity(0.4),
                        splashColor: Colors.green.withOpacity(0.8),
                        elevation: 4.0,
                        highlightElevation: 16.0,
                        child: Icon(
                          widget.btnIconRight,
                          color: Colors.black,
                        ),
                        onPressed: widget.onTapRightBtn,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
