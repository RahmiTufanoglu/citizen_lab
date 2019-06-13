import 'package:citizen_lab/collapsing_appbar_page.dart';
import 'package:citizen_lab/themes/theme.dart';
import 'package:citizen_lab/themes/theme_changer_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetailPage extends StatefulWidget {
  final Key key;
  final String title;
  final String content;
  final String image;

  DetailPage({
    this.key,
    @required this.title,
    @required this.content,
    @required this.image,
  }) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  ThemeChangerProvider _themeChanger;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    _themeChanger = Provider.of<ThemeChangerProvider>(context);
    _checkIfDarkModeEnabled();

    return Scaffold(
      body: CollapsingAppBarPage(
        text: GestureDetector(
          onPanStart: (_) => _enableDarkMode(),
          child: Container(
            width: double.infinity,
            child: Tooltip(
              message: '',
              child: Text(
                widget.title,
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ),
        ),
        image: widget.image,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(widget.content),
        ),
      ),
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
}
