import 'dart:async';

import 'package:citizen_lab/custom_widgets/no_yes_dialog.dart';
import 'package:citizen_lab/themes/theme_changer_provider.dart';
import 'package:citizen_lab/utils/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class StopwatchPage extends StatefulWidget {
  @override
  _StopwatchPageState createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage>
    with TickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _timerTextEditingController = TextEditingController();
  final _stopWatch = Stopwatch();
  final _timeout = const Duration(milliseconds: 30);
  final _scrollController = ScrollController();

  ThemeChangerProvider _themeChanger;
  String _stopWatchText = '00:00:000';
  String _elapsedTime = '00:00:000';
  Icon _icon = Icon(Icons.play_arrow);
  List<String> _elapsedTimeList = [];

  void _startTimeout() => Timer(_timeout, _handleTimeout);

  void _handleTimeout() {
    if (_stopWatch.isRunning) {
      _startTimeout();
    }
    setState(() {
      _setStopwatchText();
    });
  }

  @override
  Widget build(BuildContext context) {
    _themeChanger = Provider.of<ThemeChangerProvider>(context);
    _themeChanger.checkIfDarkModeEnabled(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFabs(),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      title: GestureDetector(
        onPanStart: (_) => _themeChanger.setTheme(),
        child: Container(
          width: double.infinity,
          child: Tooltip(
            message: '',
            child: Text('Stopwatch'),
          ),
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.share),
          onPressed: () => _shareContent(),
        ),
        IconButton(
          icon: Icon(Icons.home),
          onPressed: () => _backToHomePage(),
        ),
      ],
    );
  }

  void _shareContent() {
    final String sharingNotPossible = 'Teilvorgang nicht möglich.';

    if (_elapsedTime != '00:00:000') {
      final String _content = _elapsedTimeList[_elapsedTimeList.length - 1];
      Share.share(_content);
    } else {
      _scaffoldKey.currentState.showSnackBar(
        _buildSnackBar(text: sharingNotPossible),
      );
    }
  }

  void _backToHomePage() async {
    final String cancel = 'Notiz abbrechen und zur Hauptseite zurückkehren?';

    await showDialog(
      context: context,
      builder: (_) {
        return NoYesDialog(
          text: cancel,
          onPressed: () {
            Navigator.popUntil(
              context,
              ModalRoute.withName(RouteGenerator.routeHomePage),
            );
          },
        );
      },
    );
  }

  Widget _buildBody() {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double containerHeight = (screenHeight / 3) - kToolbarHeight - 24.0;

    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _stopWatchText,
              style: TextStyle(fontSize: 56.0),
            ),
            SizedBox(height: 56.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: _icon,
                  iconSize: 56.0,
                  onPressed: _startStopButtonPressed,
                ),
                SizedBox(width: 42.0),
                IconButton(
                  icon: Icon(Icons.stop),
                  iconSize: 56.0,
                  onPressed: _resetButtonPressed,
                ),
              ],
            ),
            SizedBox(height: 56.0),
            Container(
              padding: const EdgeInsets.all(8.0),
              height: containerHeight,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
              ),
              child: ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                reverse: true,
                itemCount: _elapsedTimeList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      (index == _elapsedTimeList.length - 1)
                          ? 'Letzte Zeit:\t${_elapsedTimeList[index]}'
                          : _elapsedTimeList[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20.0),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startStopButtonPressed() {
    setState(() {
      if (_stopWatch.isRunning) {
        _setElapsedTime();
        _icon = Icon(Icons.play_arrow);
        _stopWatch.stop();
      } else {
        _icon = Icon(Icons.pause);
        _stopWatch.start();
        _startTimeout();
      }
    });
  }

  void _resetButtonPressed() {
    if (_stopWatch.isRunning) {
      _setElapsedTime();
      _startStopButtonPressed();
    }
    setState(() {
      _stopWatch.reset();
      _setStopwatchText();
    });
  }

  void _setElapsedTime() {
    _elapsedTime = _stopWatchText;
    _elapsedTimeList.add(_elapsedTime);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.decelerate,
      );
    });
  }

  void _setStopwatchText() {
    _stopWatchText = _stopWatch.elapsed.inMinutes.toString().padLeft(2, '0') +
        ":" +
        (_stopWatch.elapsed.inSeconds % 60).toString().padLeft(2, '0') +
        ":" +
        (_stopWatch.elapsed.inMilliseconds % 1000).toString().padLeft(3, '0');
  }

  Widget _buildFabs() {
    return FloatingActionButton(
      child: Icon(Icons.content_copy),
      onPressed: () => _copyContent(),
    );
  }

  void _copyContent() {
    final copyContent = 'Inhalt kopiert';
    final copyNotPossible = 'Kein Inhalt zum kopieren';

    String content = _elapsedTimeList[_elapsedTimeList.length - 1];

    if (_elapsedTimeList.isNotEmpty) {
      _setClipboard(content, '$copyContent.');
    } else {
      _scaffoldKey.currentState.showSnackBar(
        _buildSnackBar(text: '$copyNotPossible.'),
      );
    }
  }

  void _setClipboard(String text, String snackText) {
    Clipboard.setData(
      ClipboardData(text: text),
    );

    _scaffoldKey.currentState.showSnackBar(
      _buildSnackBar(text: snackText),
    );
  }

  Widget _buildSnackBar({@required String text}) {
    return SnackBar(
      backgroundColor: Colors.black.withOpacity(0.5),
      duration: Duration(milliseconds: 500),
      content: Text(
        text,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
