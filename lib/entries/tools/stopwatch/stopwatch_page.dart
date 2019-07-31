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
  final _stopWatch = Stopwatch();
  final _timeout = const Duration(milliseconds: 30);
  final _scrollController = ScrollController();

  ThemeChangerProvider _themeChanger;
  String _stopWatchText = '00:00:000';
  String _elapsedTime = '00:00:000';
  Icon _icon = Icon(Icons.play_arrow);
  final List<String> _elapsedTimeList = [];

  @override
  Widget build(BuildContext context) {
    _themeChanger = Provider.of<ThemeChangerProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFabs(),
    );
  }

  Widget _buildAppBar() {
    const String stopWatch = 'Stoppuhr';
    const String back = 'Zurück';

    return AppBar(
      leading: IconButton(
        tooltip: back,
        icon: Icon(Icons.arrow_back),
        onPressed: () => _onBackPressed(),
      ),
      title: GestureDetector(
        onPanStart: (_) => _themeChanger.setTheme(),
        child: Container(
          width: double.infinity,
          child: Tooltip(
            message: stopWatch,
            child: const Text(stopWatch),
          ),
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.share),
          onPressed: () {
            //String content = '';
            final StringBuffer content = StringBuffer();
            for (int i = 0; i < _elapsedTimeList.length; i++) {
              //content += _elapsedTimeList[i] + '\n';
              content.write(_elapsedTimeList[i] + '\n');
            }
            _shareContent(content.toString());
          },
        ),
        IconButton(
          icon: Icon(Icons.home),
          onPressed: () => _backToHomePage(),
        ),
      ],
    );
  }

  void _shareContent(String content) {
    const String sharingNotPossible = 'Teilvorgang nicht möglich.';

    if (_elapsedTime != '00:00:000') {
      Share.share(content);
    } else {
      _scaffoldKey.currentState.showSnackBar(
        _buildSnackBar(text: sharingNotPossible),
      );
    }
  }

  void _backToHomePage() {
    const String cancel = 'Notiz abbrechen und zur Hauptseite zurückkehren?';

    showDialog(
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
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: <Widget>[
              Center(
                child: Text(
                  _stopWatchText,
                  style: TextStyle(fontSize: 56.0),
                ),
              ),
              const SizedBox(height: 56.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FloatingActionButton(
                    heroTag: null,
                    onPressed: _running,
                    child: Icon(Icons.timer),
                  ),
                  FloatingActionButton(
                    heroTag: null,
                    onPressed: _startStopButtonPressed,
                    child: _icon,
                  ),
                  FloatingActionButton(
                    heroTag: null,
                    onPressed: () => _resetButtonPressed(),
                    child: Icon(Icons.stop),
                  ),
                ],
              ),
              const SizedBox(height: 56.0),
              Container(
                //height: 200.0,
                height: MediaQuery.of(context).orientation ==
                        Orientation.portrait
                    ? (screenHeight / 2.5) - kToolbarHeight - statusBarHeight
                    : (screenHeight / 1.5) - kToolbarHeight - statusBarHeight,
                decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2)),
                child: ListView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  reverse: true,
                  itemCount: _elapsedTimeList.length,
                  itemBuilder: (BuildContext context, int index) {
                    final String content = _elapsedTimeList[index];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(42.0, 0.0, 42.0, 0.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 16,
                            child: Text(
                              index == _elapsedTimeList.length - 1
                                  ? 'Letzte Zeit:\t${_elapsedTimeList[index]}'
                                  : _elapsedTimeList[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ),
                          const Spacer(),
                          Expanded(
                            flex: 2,
                            child: IconButton(
                              icon: Icon(Icons.share),
                              onPressed: () => _shareContent(content),
                            ),
                          ),
                          const Spacer(flex: 2),
                          Expanded(
                            flex: 2,
                            child: IconButton(
                              icon: Icon(Icons.content_copy),
                              onPressed: () => _copyContent(content),
                            ),
                          ),
                        ],
                      ),
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

  void _running() {
    setState(() {
      if (_stopWatch.isRunning) {
        _setElapsedTime();
      } else {
        _icon = Icon(Icons.pause);
        _stopWatch.start();
        _startTimeout();
      }
    });
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

  void _startTimeout() => Timer(_timeout, _handleTimeout);

  void _handleTimeout() {
    if (_stopWatch.isRunning) _startTimeout();
    setState(() => _setStopwatchText());
  }

  void _resetButtonPressed() {
    if (_stopWatch.isRunning) {
      //_setElapsedTime();
      _startStopButtonPressed();
    }
    //_stopWatch.reset();
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
        ':' +
        (_stopWatch.elapsed.inSeconds % 60).toString().padLeft(2, '0') +
        ':' +
        (_stopWatch.elapsed.inMilliseconds % 1000).toString().padLeft(3, '0');
  }

  Widget _buildFabs() {
    return Padding(
      padding: const EdgeInsets.only(left: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FloatingActionButton(
            heroTag: null,
            tooltip: '',
            onPressed: () => _clearList(),
            child: Icon(Icons.remove),
          ),
          FloatingActionButton(
            heroTag: null,
            onPressed: () {
              //String content = '';
              final StringBuffer content = StringBuffer();
              for (int i = 0; i < _elapsedTimeList.length; i++) {
                //content += _elapsedTimeList[i] + '\n';
                content.write(_elapsedTimeList[i] + '\n');
              }
              _copyContent(content.toString());
            },
            child: Icon(Icons.content_copy),
          ),
        ],
      ),
    );
  }

  void _clearList() {
    setState(() {
      _elapsedTimeList.clear();
    });
  }

  void _copyContent(String content) {
    const copyContent = 'Inhalt kopiert';
    const copyNotPossible = 'Kein Inhalt zum kopieren';

    if (_elapsedTimeList.isNotEmpty) {
      _setClipboard(content, '$copyContent.');
    } else {
      _scaffoldKey.currentState.showSnackBar(
        _buildSnackBar(text: '$copyNotPossible.'),
      );
    }
  }

  void _setClipboard(String text, String snackText) {
    Clipboard.setData(ClipboardData(text: text));
    _scaffoldKey.currentState.showSnackBar(_buildSnackBar(text: snackText));
  }

  Widget _buildSnackBar({@required String text}) {
    return SnackBar(
      backgroundColor: Colors.black87,
      duration: const Duration(milliseconds: 500),
      content: Text(
        text,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _onBackPressed() {
    _stopWatch.stop();
    Navigator.pop(context, true);
  }
}
