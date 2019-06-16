import 'dart:async';

import 'package:citizen_lab/themes/theme_changer_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CitizenScienceWebPage extends StatefulWidget {
  final Key key;
  final String url;

  CitizenScienceWebPage({
    this.key,
    @required this.url,
  }) : super(key: key);

  @override
  _CitizenScienceWebPageState createState() => _CitizenScienceWebPageState();
}

class _CitizenScienceWebPageState extends State<CitizenScienceWebPage> {
  final _webViewController = Completer<WebViewController>();
  final _key = UniqueKey();

  ThemeChangerProvider _themeChanger;

  @override
  Widget build(BuildContext context) {
    _themeChanger = Provider.of<ThemeChangerProvider>(context);
    _themeChanger.checkIfDarkModeEnabled(context);

    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  Widget _buildAppBar() {
    final String back = 'Zurück';
    final String citizenScience = 'Citizen Science';

    return AppBar(
      leading: IconButton(
        tooltip: back,
        icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: GestureDetector(
        onPanStart: (_) => _themeChanger.setTheme(),
        child: Container(
          width: double.infinity,
          child: Tooltip(
            message: citizenScience,
            child: Text(citizenScience),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: WebView(
        key: _key,
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: widget.url,
        onWebViewCreated: (WebViewController webViewController) {
          _webViewController.complete(webViewController);
        },
      ),
    );
  }
}
