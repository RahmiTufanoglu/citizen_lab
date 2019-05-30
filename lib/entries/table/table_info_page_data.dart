import 'package:flutter/material.dart';
import 'package:citizen_lab/utils/constants.dart';

List<Widget> tableTabList = [
  Tab(
    child: Text(
      '1',
      style: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
  Tab(
    child: Text(
      '2',
      style: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
];

List<Widget> tableSingleChildScrollViewList = [
  SingleChildScrollView(
    padding: const EdgeInsets.all(16.0),
    child: Text(lorem + lorem + lorem + lorem + lorem + lorem),
  ),
  SingleChildScrollView(
    padding: const EdgeInsets.all(16.0),
    child: Text(lorem + lorem + lorem + lorem + lorem),
  ),
];
