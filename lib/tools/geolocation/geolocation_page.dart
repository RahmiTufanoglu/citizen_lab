import 'dart:async';

import 'package:citizen_lab/themes/theme_changer_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class GeolocationPage extends StatefulWidget {
  @override
  _GeolocationPageState createState() => _GeolocationPageState();
}

class _GeolocationPageState extends State<GeolocationPage> with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _geolocator = Geolocator();
  final String latitude = 'Breitengrad';
  final String longitude = 'Längengrad';
  final String accuracy = 'Genauigkeitsgrad';

  Position _position = Position(
    latitude: 0.0,
    longitude: 0.0,
    accuracy: 0.0,
  );

  AnimationController _animationController;
  Animation<double> _animation;
  Timer _timer;

  @override
  void initState() {
    super.initState();

    if (!mounted) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _getLocation().then((position) => _position = position);
      });
    });

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController)
      ..addListener(() {}); // ..addListener ???

    //_animation.addListener(() {});

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFabs(),
    );
  }

  Widget _buildAppBar() {
    const String back = 'Zurück';
    const String noteType = 'Ortsbestimmung';

    return AppBar(
      elevation: 4.0,
      title: Consumer<ThemeChangerProvider>(
        builder: (BuildContext context, ThemeChangerProvider provider, Widget child) {
          return GestureDetector(
            onPanStart: (_) => provider.setTheme(),
            child: Container(
              width: double.infinity,
              child: const Tooltip(
                message: noteType,
                child: Text(noteType),
              ),
            ),
          );
        },
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
      ],
    );
  }

  void _shareContent() {
    const String sharingNotPossible = 'Teilvorgang nicht möglich.';

    if (_position != null) {
      final String _content =
          //'$latitude: ${_position.latitude.toString()}\n$longitude: ${_position.longitude.toString()}\n$accuracy: ${_position.accuracy.toString()}';
          '$latitude: ${_position.latitude.toString()}\n'
          '$longitude: ${_position.longitude.toString()}\n'
          '$accuracy: ${_position.accuracy.toString()}';
      Share.share(_content);
    } else {
      _scaffoldKey.currentState.showSnackBar(
        _buildSnackBar(text: sharingNotPossible),
      );
    }
  }

  Widget _buildBody() {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: WillPopScope(
        onWillPop: () async => Navigator.pop(context, false),
        child: Stack(
          children: <Widget>[
            (_position != null)
                ? Center(
                    child: Text(
                      '$latitude: ${_position.latitude.toString()}\n'
                      '$longitude: ${_position.longitude.toString()}\n'
                      '$accuracy: ${_position.accuracy.toString()}',
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
                duration: const Duration(seconds: 1),
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
      ),
    );
  }

  Widget _buildFabs() {
    return Padding(
      padding: const EdgeInsets.only(left: 32.0),
      child: FloatingActionButton(
        heroTag: null,
        onPressed: () => _copyContent(),
        child: Icon(Icons.content_copy),
      ),
    );
  }

  Future _getLocation() async {
    Position currentPosition;
    try {
      currentPosition = await _geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
    } on Exception {
      currentPosition = null;
    }
    return currentPosition;
  }

  void _copyContent() {
    const copyContent = 'Inhalt kopiert';
    const copyNotPossible = 'Kein Inhalt zum kopieren';
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
      duration: const Duration(milliseconds: 500),
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
