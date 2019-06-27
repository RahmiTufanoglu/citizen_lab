import 'package:citizen_lab/utils/constants.dart';
import 'package:flutter/material.dart';

List<Widget> createProjectTabList = [
  Tab(
    child: Text(
      '1',
      style: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
];

List<Widget> createProjectSingleChildScrollViewList = [
  SingleChildScrollView(
    padding: const EdgeInsets.all(16.0),
    child: Text(lorem + lorem + lorem + lorem + lorem + lorem),
  ),
];
