import 'package:citizen_lab/themes/theme_changer_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InfoPage extends StatefulWidget {
  final Key key;
  final String title;
  final int tabLength;
  final List<Widget> tabs;
  final List<Widget> tabChildren;

  InfoPage({
    this.key,
    @required this.title,
    @required this.tabLength,
    @required this.tabs,
    @required this.tabChildren,
  });

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  ThemeChangerProvider _themeChanger;

  @override
  Widget build(BuildContext context) {
    _themeChanger = Provider.of<ThemeChangerProvider>(context);
    _themeChanger.checkIfDarkModeEnabled(context);

    return DefaultTabController(
      length: widget.tabLength,
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final String back = 'Zurück';

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
            message: '',
            child: Text(widget.title),
          ),
        ),
      ),
      actions: <Widget>[],
      bottom: TabBar(
        tabs: widget.tabs,
      ),
    );
  }

  Widget _buildBody() {
    return TabBarView(
      children: widget.tabChildren,
    );
  }
}
