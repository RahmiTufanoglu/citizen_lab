import 'package:flutter/material.dart';
import 'package:citizen_lab/collapsing_appbar_page.dart';

class DetailPage extends StatelessWidget {
  final String title;
  final String content;
  final String image;

  DetailPage({
    @required this.title,
    @required this.content,
    @required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CollapsingAppBarPage(
        text: Text(
          title,
          style: TextStyle(fontSize: 16.0),
        ),
        image: image,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(content),
        ),
      ),
    );
  }
}
