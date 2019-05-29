import 'package:flutter/material.dart';
import 'package:citizen_lab/collapsing_appbar_page.dart';

import 'package:citizen_lab/utils/constants.dart';

class DetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CollapsingAppBarPage(
        text: Text(
          'Detail',
          style: TextStyle(fontSize: 16.0),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(lorem + lorem + lorem + lorem),
        ),
      ),
    );
  }
}
