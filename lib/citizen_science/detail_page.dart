import 'dart:ui';

import 'package:citizen_lab/collapsing_appbar_page.dart';
import 'package:citizen_lab/themes/theme_changer_provider.dart';
import 'package:citizen_lab/utils/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPage extends StatefulWidget {
  final Key key;
  final String title;
  final String image;
  final String location;
  final String researchSubject;
  final String built;
  final String extended;
  final String contactPerson;
  final String url;

  DetailPage({
    this.key,
    @required this.title,
    @required this.image,
    @required this.location,
    @required this.researchSubject,
    @required this.built,
    @required this.extended,
    @required this.contactPerson,
    @required this.url,
  }) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  ThemeChangerProvider _themeChanger;

  @override
  Widget build(BuildContext context) {
    _themeChanger = Provider.of<ThemeChangerProvider>(context);
    _themeChanger.checkIfDarkModeEnabled(context);

    return Scaffold(
      body: _buildBody(),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildBody() {
    return CollapsingAppBarPage(
      text: GestureDetector(
        onPanStart: (_) => _themeChanger.setTheme(),
        child: Container(
          width: double.infinity,
          child: Tooltip(
            message: widget.title,
            child: Text(widget.title),
          ),
        ),
      ),
      image: widget.image,
      body: ListView(
        children: <Widget>[
          _titleAndContent('Standort', widget.location),
          //_dividerWithPadding(),
          _titleAndContent('Forschungsgegenstand', widget.researchSubject),
          //_dividerWithPadding(),
          _titleAndContent('Aufgebaut/Eröffnet', widget.built),
          //_dividerWithPadding(),
          _titleAndContent('Erweitert', widget.extended),
          //_dividerWithPadding(),
          _titleAndContent('Ansprechpartner', widget.contactPerson),
        ],
      ),
    );
  }

  Widget _titleAndContent(String title, String content) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '$title:',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(content),
          ],
        ),
      ),
    );
  }

  Widget _dividerWithPadding() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 24.0,
        right: 24.0,
      ),
      child: Divider(color: Colors.black),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      child: Icon(Icons.web),
      //onPressed: () => _launchUrl(),
      onPressed: () => _launchWeb(),
    );
  }

  Future<void> _launchWeb() async {
    return await Navigator.pushNamed(
      context,
      RouteGenerator.citizenScienceWebPage,
      arguments: {
        'url': widget.url,
      },
    );
  }

  Future<void> _launchUrl() async {
    if (await canLaunch(widget.url)) {
      await launch(widget.url);
    } else {
      throw 'Could not launch ${widget.url}';
    }
  }
}
