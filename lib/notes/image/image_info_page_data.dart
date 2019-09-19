import 'package:citizen_lab/utils/constants.dart';
import 'package:flutter/material.dart';

List<Widget> imageTabList = [
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

List<Widget> imageSingleChildScrollViewList = [
  SingleChildScrollView(
    padding: const EdgeInsets.all(16.0),
    child: const Text(
        Constants.lorem + Constants.lorem + Constants.lorem + Constants.lorem + Constants.lorem + Constants.lorem),
  ),
  SingleChildScrollView(
    padding: const EdgeInsets.all(16.0),
    child: const Text(Constants.lorem + Constants.lorem + Constants.lorem + Constants.lorem + Constants.lorem),
  ),
];
