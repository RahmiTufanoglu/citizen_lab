import 'package:flutter/material.dart';

class CollapsingAppBarPage extends StatelessWidget {
  final double fontSize;
  final double appBarElevation;
  final Widget text;
  final Widget body;

  CollapsingAppBarPage({
    this.fontSize = 16.0,
    this.appBarElevation = 4.0,
    @required this.text,
    @required this.body,
  });

  @override
  Widget build(BuildContext context) {
    double pageHeight = MediaQuery.of(context).size.height;

    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            expandedHeight: pageHeight / 3,
            //backgroundColor: appBarColor.withOpacity(0.8),
            floating: true,
            pinned: true,
            snap: true,
            forceElevated: true,
            elevation: appBarElevation,
            //backgroundColor: backgroundColor.withOpacity(0.8),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: text,
              //background: Container(color: backgroundColor),
              background: Image.network(
                "https://images.pexels.com/photos/396547/pexels-photo-396547.jpeg?auto=compress&cs=tinysrgb&h=350",
                fit: BoxFit.cover,
              ),
            ),
          ),
        ];
      },
      body: body,
    );
  }
}
