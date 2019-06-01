import 'dart:async';

import 'package:flutter/material.dart';
import 'package:aeyrium_sensor/aeyrium_sensor.dart';

import 'entries/note.dart';

class AeyriumPage extends StatefulWidget {
  final Key key;
  final Note note;
  final String projectTitle;

  AeyriumPage({
    this.key,
    @required this.note,
    @required this.projectTitle,
  }) : super(key: key);

  @override
  _AeyriumPageState createState() => _AeyriumPageState();
}

class _AeyriumPageState extends State<AeyriumPage> {
  String _data = '';
  StreamSubscription<dynamic> _streamSubscriptions;

  @override
  void initState() {
    _streamSubscriptions = AeyriumSensor.sensorEvents.listen((event) {
      setState(() {
        _data = "Pitch ${event.pitch} , Roll ${event.roll}";
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    if (_streamSubscriptions != null) {
      _streamSubscriptions.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFabs(),
    );
  }

  Widget _buildAppBar() {
    return AppBar();
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Center(
        child: Text('Device : $_data'),
      ),
    );
  }

  Widget _buildFabs() {
    return Container();
  }
}
