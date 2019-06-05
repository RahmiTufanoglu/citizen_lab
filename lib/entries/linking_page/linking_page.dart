import 'dart:async';

import 'package:citizen_lab/custom_widgets/no_yes_dialog.dart';
import 'package:citizen_lab/themes/theme.dart';
import 'package:citizen_lab/themes/theme_changer.dart';
import 'package:citizen_lab/utils/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../note.dart';

class LinkingPage extends StatefulWidget {
  final key;
  final Note note;
  final String projectTitle;
  final url;

  LinkingPage({
    this.key,
    @required this.note,
    @required this.projectTitle,
    @required this.url,
  }) : super(key: key);

  @override
  _LinkingPageState createState() => _LinkingPageState(this.url);
}

class _LinkingPageState extends State<LinkingPage> {
  String _url;
  final _key = UniqueKey();

  _LinkingPageState(this._url);

  //WebViewController _controller;

  Completer _controller = Completer<WebViewController>();

  ThemeChanger _themeChanger;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    _themeChanger = Provider.of<ThemeChanger>(context);
    _checkIfDarkModeEnabled();

    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        tooltip: 'Zurück',
        icon: Icon(Icons.arrow_back),
        onPressed: () => null,
      ),
      title: GestureDetector(
        onPanStart: (_) => _enableDarkMode(),
        child: Container(
          width: double.infinity,
          child: Tooltip(
            message: 'Linking',
            child: Text('Linking'),
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
    String fullContent = '';
    Share.share(fullContent);
  }

  void _backToHomePage() {
    final String cancel = 'Notiz abbrechen und zur Hauptseite zurückkehren?';

    showDialog(
      context: context,
      builder: (_) => NoYesDialog(
            text: cancel,
            onPressed: () {
              Navigator.popUntil(
                context,
                ModalRoute.withName(RouteGenerator.routeHomePage),
              );
            },
          ),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: WebView(
        key: _key,
        javascriptMode: JavascriptMode.unrestricted,
        //initialUrl: _url,
        initialUrl: 'https://www.google.de/',
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
        },
      ),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      child: Icon(Icons.content_copy),
      onPressed: () {},
    );
  }
}
