import 'dart:async';

import 'package:citizen_lab/custom_widgets/no_yes_dialog.dart';
import 'package:citizen_lab/entries/tools/timer_painter.dart';
import 'package:citizen_lab/themes/theme.dart';
import 'package:citizen_lab/themes/theme_changer.dart';
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

  String _stopWatchText = '00:00:000';
  String _elapsedTime = '00:00:000';
  Icon _icon = Icon(Icons.play_arrow);

  List<String> _elapsedTimeList = [];

  ThemeChanger _themeChanger;
  bool _darkModeEnabled = false;

  void _startTimeout() {
    Timer(_timeout, _handleTimeout);
  }

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
    _themeChanger = Provider.of<ThemeChanger>(context);
    _checkIfDarkModeEnabled();

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
        onDoubleTap: () => _enableDarkMode(),
        child: Tooltip(
          message: '',
          child: Text('Stopwatch'),
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

  void _checkIfDarkModeEnabled() {
    final ThemeData theme = Theme.of(context);
    theme.brightness == appDarkTheme().brightness
        ? _darkModeEnabled = true
        : _darkModeEnabled = false;
  }

  void _enableDarkMode() {
    _darkModeEnabled
        ? _themeChanger.setTheme(appLightTheme())
        : _themeChanger.setTheme(appDarkTheme());
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
              height: (screenHeight / 3) - kToolbarHeight - 24.0,
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
        //_elapsedTime = _stopWatchText;
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
      //_elapsedTime = _stopWatchText;
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
    _stopWatchText = _stopWatch.elapsed.inMinutes.toString().padLeft(2, "0") +
        ":" +
        (_stopWatch.elapsed.inSeconds % 60).toString().padLeft(2, "0") +
        ":" +
        (_stopWatch.elapsed.inMilliseconds % 1000).toString().padLeft(3, "0");
  }

  Widget _buildFabs() {
    return FloatingActionButton(
      child: Icon(Icons.content_copy),
      onPressed: () => _copyContent(),
    );
  }

  Future<void> _showSetTimerDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(16.0),
            ),
          ),
          contentPadding: const EdgeInsets.all(16.0),
          titlePadding: const EdgeInsets.all(0.0),
          children: <Widget>[
            TextFormField(
              controller: _timerTextEditingController,
              autofocus: true,
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(16.0),
                ),
              ),
              onPressed: () => null,
            ),
          ],
        );
      },
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

//
//
//
//
//
//
//
//
//
class _StopwatchPageState2 extends State<StopwatchPage>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  IconData _startIcon = Icons.play_arrow;
  final _durationTextEditingController = TextEditingController();

  int _duration = 60;

  String get _timerString {
    Duration duration =
        _animationController.duration * _animationController.value;
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _duration),
    );
  }

  @override
  void dispose() {
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
    return AppBar(
      title: Text('Stopwatch'),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (BuildContext context, Widget child) {
                    return CustomPaint(
                      painter: TimerPainter(
                        animation: _animationController,
                        backgroundColor: Colors.red,
                        color: Colors.green,
                      ),
                    );
                  },
                ),
              ),
              Center(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (BuildContext context, Widget child) {
                    return Text(
                      _timerString,
                      style: TextStyle(fontSize: 56.0),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 32.0),
          child: FloatingActionButton(
            child: Icon(Icons.timer),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    children: <Widget>[
                      TextFormField(
                        controller: _durationTextEditingController,
                      ),
                      RaisedButton(
                        onPressed: () {
                          setState(() {
                            _duration =
                                int.parse(_durationTextEditingController.text);
                            _animationController.reverse();
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
        FloatingActionButton(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (BuildContext context, Widget child) {
              return Icon(_startIcon);
            },
          ),
          onPressed: () {
            if (_animationController.isAnimating) {
              _animationController.stop();
              setState(() {
                _startIcon = Icons.pause;
              });
            } else {
              setState(() {
                _startIcon = Icons.play_arrow;
              });
              _animationController.reverse(
                from: _animationController.value == 0.0
                    ? 1.0
                    : _animationController.value,
              );
            }
          },
        ),
        FloatingActionButton(
          child: Icon(Icons.content_copy),
          onPressed: () {},
        ),
      ],
    );
  }
}
