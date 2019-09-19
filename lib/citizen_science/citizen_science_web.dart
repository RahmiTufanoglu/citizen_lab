import 'dart:async';

import 'package:citizen_lab/themes/theme_changer_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CitizenScienceWebPage extends StatefulWidget {
  final String title;
  final String url;

  const CitizenScienceWebPage({
    @required this.title,
    @required this.url,
  });

  @override
  _CitizenScienceWebPageState createState() => _CitizenScienceWebPageState();
}

class _CitizenScienceWebPageState extends State<CitizenScienceWebPage> {
  final _webViewController = Completer<WebViewController>();
  final _key = UniqueKey();

  bool _isLoadingPage;

  @override
  void initState() {
    super.initState();
    _isLoadingPage = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  Widget _buildAppBar() {
    const String back = 'Zurück';

    return AppBar(
      leading: IconButton(
        tooltip: back,
        icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: Consumer<ThemeChangerProvider>(
        builder: (
          BuildContext context,
          ThemeChangerProvider provider,
          Widget child,
        ) {
          return GestureDetector(
            onPanStart: (_) => provider.setTheme(),
            child: Container(
              width: double.infinity,
              child: Tooltip(
                message: widget.title,
                child: Text(widget.title),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Stack(
        children: <Widget>[
          WebView(
            key: _key,
            javascriptMode: JavascriptMode.unrestricted,
            initialUrl: widget.url,
            onWebViewCreated: (WebViewController webViewController) {
              _webViewController.complete(webViewController);
            },
            onPageFinished: (_) {
              setState(() => _isLoadingPage = false);
            },
          ),
          //_loadIndicator(),
          _isLoadingPage
              ? Center(
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                )
              : Center(),
        ],
      ),
    );
  }
}
