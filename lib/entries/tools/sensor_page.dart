import 'dart:async';

import 'package:citizen_lab/themes/theme.dart';
import 'package:citizen_lab/themes/theme_changer.dart';
import 'package:citizen_lab/utils/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:citizen_lab/custom_widgets/no_yes_dialog.dart';

class SensorPage extends StatefulWidget {
  final Key key;

  SensorPage({this.key}) : super(key: key);

  @override
  _SensorPageState createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _geolocator = Geolocator();

  var _position = Position(latitude: 0.0, longitude: 0.0, accuracy: 0.0);
  AnimationController _animationController;
  Animation<double> _animation;
  Timer _timer;

  ThemeChanger _themeChanger;
  bool _darkModeEnabled = false;

  @override
  void initState() {
    if (!mounted) return;

    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        _getLocation().then((position) => _position = position);
      });
    });

    _animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController)
      ..addListener(() {});

    _animationController.forward();

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer.cancel();
    super.dispose();
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
    final String back = 'Zurück';
    final String noteType = 'Ortsbestimmung';

    return AppBar(
      elevation: 4.0,
      title: GestureDetector(
        onPanStart: (_) => _enableDarkMode(),
        child: Container(
          width: double.infinity,
          child: Tooltip(
            message: noteType,
            child: Text(noteType),
          ),
        ),
      ),
      leading: IconButton(
        tooltip: back,
        icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context, false),
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

    if (_position != null) {
      final String _content =
          'Latitude: ${_position.latitude.toString()}\nLongitude: ${_position.longitude.toString()}\nAccuracy: ${_position.accuracy.toString()}';
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
    final double screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, false);
      },
      child: Stack(
        children: <Widget>[
          (_position != null)
              ? Center(
                  child: Text(
                    'Latitude: ${_position.latitude.toString()}\nLongitude: ${_position.longitude.toString()}\nAccuracy: ${_position.accuracy.toString()}',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    'Sensor nicht aktiv.',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
          Center(
            child: AnimatedContainer(
              duration: Duration(seconds: 1),
              height: _animation.value * screenHeight,
              width: _animation.value * screenWidth,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFabs() {
    return Padding(
      padding: const EdgeInsets.only(left: 32.0),
      child: FloatingActionButton(
        heroTag: null,
        child: Icon(Icons.content_copy),
        onPressed: () => _copyContent(),
      ),
    );
  }

  Future<Position> _getLocation() async {
    Position currentPosition;
    try {
      currentPosition = await _geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
    } catch (error) {
      currentPosition = null;
    }
    return currentPosition;
  }

  void _copyContent() {
    final copyContent = 'Inhalt kopiert';
    final copyNotPossible = 'Kein Inhalt zum kopieren';
    final String _content =
        'Latitude: ${_position.latitude.toString()}\nLongitude: ${_position.longitude.toString()}\nAccuracy: ${_position.accuracy.toString()}';
    if (_content != null) {
      _setClipboard(_content, '$copyContent.');
    } else {
      _scaffoldKey.currentState.showSnackBar(
        _buildSnackBar(text: '$copyNotPossible.'),
      );
    }
  }

  void _setClipboard(String text, String snackText) {
    Clipboard.setData(ClipboardData(text: text));

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
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
