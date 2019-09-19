import 'package:citizen_lab/themes/theme_changer_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InfoPage extends StatefulWidget {
  final Key key;
  final String title;
  final int tabLength;
  final List<Widget> tabs;
  final List<Widget> tabChildren;

  const InfoPage({
    @required this.title,
    @required this.tabLength,
    @required this.tabs,
    @required this.tabChildren,
    this.key,
  }) : super(key: key);

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: widget.tabLength,
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        tooltip: 'Go to last page',
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
      actions: const <Widget>[],
      bottom: TabBar(
        tabs: widget.tabs,
      ),
    );
  }

  Widget _buildBody() => TabBarView(children: widget.tabChildren);
}
