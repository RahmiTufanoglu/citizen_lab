import 'dart:ui';

import 'package:citizen_lab/collapsing_appbar_page.dart';
import 'package:citizen_lab/themes/theme_changer_provider.dart';
import 'package:citizen_lab/utils/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetailPage extends StatefulWidget {
  final String title;
  final String image;
  final String location;
  final String researchSubject;
  final String built;
  final String extended;
  final String contactPerson;
  final String url;

  const DetailPage({
    @required this.title,
    @required this.image,
    @required this.location,
    @required this.researchSubject,
    @required this.built,
    @required this.extended,
    @required this.contactPerson,
    @required this.url,
  });

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  ThemeChangerProvider _themeChanger;

  @override
  Widget build(BuildContext context) {
    _themeChanger = Provider.of<ThemeChangerProvider>(context);

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
        padding: const EdgeInsets.all(8.0),
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
    return Padding(
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
          const SizedBox(height: 8.0),
          Text(content),
        ],
      ),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      //onPressed: () => _launchUrl(),
      onPressed: () => _launchWeb(),
      child: Icon(Icons.web),
    );
  }

  Future<void> _launchWeb() async {
    return await Navigator.pushNamed(
      context,
      RouteGenerator.webPage,
      arguments: {
        RouteGenerator.title: widget.title,
        RouteGenerator.url: widget.url,
      },
    );
  }
}
