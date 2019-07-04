import 'dart:async';

import 'package:citizen_lab/themes/theme.dart';
import 'package:citizen_lab/utils/date_formater.dart';
import 'package:flutter/material.dart';

import '../title_change_provider.dart';

class TitleDescWidget extends StatefulWidget {
  final Key key;
  final titleBloc;
  final TitleChangerProvider titleChanger;
  final String title;
  final String createdAt;
  final titleEditingController;
  final descEditingController;

  //final GestureTapCallback onWillPop;
  final Function onWillPop;

  TitleDescWidget({
    this.key,
    @required this.titleBloc,
    @required this.titleChanger,
    @required this.title,
    @required this.createdAt,
    @required this.titleEditingController,
    @required this.descEditingController,
    @required this.onWillPop,
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

  bool _checkIfDarkModeEnabled() {
    final ThemeData theme = Theme.of(context);
    if (theme.brightness == appDarkTheme().brightness) {
      return true;
    } else {
      return false;
    }
  }

  Widget _buildWidget() {
    final title = 'Titel';
    final titleHere = 'Titel hier';
    final content = 'Inhalt';
    final contentHere = 'Inhalt hier';
    final String plsEnterATitle = 'Bitte einen Titel eingeben';
    String pageTitle = widget.title;

    return SafeArea(
      child: WillPopScope(
        onWillPop: () => widget.onWillPop(),
        child: ListView(
          padding: EdgeInsets.only(top: 8.0, bottom: 88.0),
          children: <Widget>[
            Container(
              color: _checkIfDarkModeEnabled() ? Colors.black12 : Colors.white,
              child: ExpansionTile(
                title: null,
                leading: Icon(Icons.access_time),
                children: <Widget>[_topWidget()],
              ),
            ),
            _bottomWidget(),
          ],
        ),
      ),
    );
  }

  Widget _topWidget() {
    final created = 'Erstellt am';
    return Container(
      margin: EdgeInsets.all(8.0),
      decoration: ShapeDecoration(
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          borderSide: BorderSide(color: Colors.grey, width: 2.0),
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
    );
  }

  Widget _bottomWidget() {
    final titleHere = 'Titel hier';
    final contentHere = 'Inhalt hier';
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            StreamBuilder(
              stream: widget.titleBloc.title,
              builder: (BuildContext context, AsyncSnapshot snapshot) =>
                  _buildTextField(
                    controller: widget.titleEditingController,
                    maxLines: 2,
                    maxLength: 50,
                    hintText: titleHere,
                    onChanged: widget.titleBloc.changeTitle,
                    snapshot: snapshot,
                  ),
            ),
            Divider(color: Colors.black),
            _buildTextField(
              controller: widget.descEditingController,
              maxLines: 20,
              maxLength: 500,
              hintText: contentHere,
              onChanged: null,
              snapshot: null,
            ),
          ],
        ),
      ),
    );
  }

  TextField _buildTextField({
    @required TextEditingController controller,
    @required int maxLines,
    @required int maxLength,
    @required String hintText,
    @required ValueChanged<String> onChanged,
    @required AsyncSnapshot snapshot,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.text,
      maxLines: maxLines,
      maxLength: maxLength,
      style: TextStyle(fontSize: 16.0),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: '$hintText.',
        errorText: (snapshot != null) ? snapshot.error : '',
        focusedErrorBorder: _buildUnderlineInputBorder(),
        errorBorder: _buildUnderlineInputBorder(),
        enabledBorder: _buildUnderlineInputBorder(),
        focusedBorder: _buildUnderlineInputBorder(),
      ),
    );
  }

  UnderlineInputBorder _buildUnderlineInputBorder() =>
      UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent));
}
