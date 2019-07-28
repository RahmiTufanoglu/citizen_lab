import 'dart:async';

import 'package:citizen_lab/utils/date_formater.dart';
import 'package:flutter/material.dart';

class SimpleTimerPage extends StatefulWidget {
  final String createdAt;
  final TextEditingController textEditingController;
  final TextEditingController descEditingController;
  final GestureTapCallback onPressedClear;
  final GestureTapCallback onPressedUpdate;
  final GestureTapCallback onPressedClose;
  final bool descExists;

  SimpleTimerPage({
    @required this.createdAt,
    @required this.textEditingController,
    @required this.descEditingController,
    @required this.onPressedClear,
    @required this.onPressedUpdate,
    @required this.onPressedClose,
    @required this.descExists,
  })  : assert(createdAt != null),
        assert(textEditingController != null),
        assert(descEditingController != null),
        assert(onPressedClear != null),
        assert(onPressedUpdate != null),
        assert(onPressedClose != null),
        assert(descExists != null);

  @override
  _SimpleTimerPageState createState() => _SimpleTimerPageState();
}

class _SimpleTimerPageState extends State<SimpleTimerPage> {
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
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Form(
      key: _formKey,
      autovalidate: true,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
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
                    Text(
                      'Erstellt am: ${widget.createdAt}',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontStyle: FontStyle.italic,
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
          ListView(
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
                /*validator: (text) {
              return text.isEmpty ? 'Bitte einen Titel eingeben' : null;
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
          )
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
          TextFormField(
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
