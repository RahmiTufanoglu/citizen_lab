import 'package:citizen_lab/themes/theme_changer_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SimpleInfoPage extends StatefulWidget {
  final Key key;
  final String title;
  final String content;

  SimpleInfoPage({
    this.key,
    @required this.title,
    @required this.content,
  }) : super(key: key);

  @override
  _SimpleInfoPageState createState() => _SimpleInfoPageState();
}

class _SimpleInfoPageState extends State<SimpleInfoPage> {
  ThemeChangerProvider _themeChanger;

  @override
  Widget build(BuildContext context) {
    _themeChanger = Provider.of<ThemeChangerProvider>(context);
    //_themeChanger.checkIfDarkModeEnabled(context);

    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final String back = 'Zurück';

    return AppBar(
      leading: Tooltip(
        message: back,
        child: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: GestureDetector(
        onPanStart: (_) => _themeChanger.setTheme(),
        child: Container(
          width: double.infinity,
          child: Tooltip(
            message: '',
            child: Text(widget.title),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(widget.content),
      ),
    );
  }
}
