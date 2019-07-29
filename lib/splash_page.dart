import 'dart:async';

import 'package:citizen_lab/utils/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () => _checkFirstSeen());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.white,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          ),
        ),
      ),
    );
  }

  Future _checkFirstSeen() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);

    if (_seen) {
      await Navigator.pushNamed(
        context,
        RouteGenerator.HOMEPAGE,
      );
    } else {
      await prefs.setBool('seen', true);
      await Navigator.pushNamed(
        context,
        RouteGenerator.ONBOARDING_PAGE,
      );
    }
  }
}
