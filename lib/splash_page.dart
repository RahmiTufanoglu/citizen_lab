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
    Future.delayed(const Duration(seconds: 1), () => _checkFirstTime());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.white,
        child: Center(
          child: const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          ),
        ),
      ),
    );
  }

  Future<void> _checkFirstTime() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool seen = prefs.getBool('seen') ?? false;

    if (seen) {
      await Navigator.pushNamed(
        context,
        CustomRoute.homePage,
      );
    } else {
      await prefs.setBool('seen', true);
      await Navigator.pushNamed(
        context,
        CustomRoute.onboardingPage,
      );
    }
  }
}
