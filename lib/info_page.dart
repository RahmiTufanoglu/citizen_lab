import 'package:flutter/material.dart';

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
    final String back = 'Zurück';

    return AppBar(
      leading: IconButton(
        tooltip: back,
        icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(widget.title),
      actions: <Widget>[],
      bottom: TabBar(tabs: widget.tabs),
    );
  }

  Widget _buildBody() {
    return TabBarView(
      children: widget.tabChildren,
    );
  }
}
