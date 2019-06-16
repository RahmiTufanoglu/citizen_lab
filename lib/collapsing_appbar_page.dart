import 'package:flutter/material.dart';

class CollapsingAppBarPage extends StatelessWidget {
  final double fontSize;
  final double appBarElevation;
  final String image;
  final Widget text;
  final Widget body;

  CollapsingAppBarPage({
    this.fontSize = 16.0,
    this.appBarElevation = 4.0,
    @required this.text,
    @required this.image,
    @required this.body,
  });

  @override
  Widget build(BuildContext context) {
    double pageHeight = MediaQuery.of(context).size.height;
    const double toolbarHeight = kToolbarHeight + 24.0;

    return NestedScrollView(
      headerSliverBuilder: (
        BuildContext context,
        bool innerBoxIsScrolled,
      ) {
        return <Widget>[
          SliverAppBar(
            title: text,
            expandedHeight: pageHeight / 3,
            floating: true,
            pinned: true,
            snap: true,
            forceElevated: true,
            elevation: appBarElevation,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: Padding(
              padding: const EdgeInsets.only(top: toolbarHeight),
              child: FlexibleSpaceBar(
                //title: text,
                collapseMode: CollapseMode.pin,
                background: Image.asset(
                  image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ];
      },
      body: Center(child: body),
    );
  }
}
