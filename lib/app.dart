import 'package:citizen_lab/splash_page.dart';
import 'package:citizen_lab/themes/theme_changer.dart';
import 'package:flutter/material.dart';
import 'package:citizen_lab/utils/route_generator.dart';
import 'package:citizen_lab/themes/theme.dart';

import 'package:citizen_lab/utils/constants.dart';
import 'package:provider/provider.dart';

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeChanger>(
      builder: (BuildContext context) => ThemeChanger(appLightTheme()),
      child: MaterialAppWithTheme(),
    );
  }
}

class MaterialAppWithTheme extends StatefulWidget {
  @override
  _MaterialAppWithThemeState createState() => _MaterialAppWithThemeState();
}

class _MaterialAppWithThemeState extends State<MaterialAppWithTheme> {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: app_title,
      home: SplashPage(),
      theme: theme.getTheme(),
      //darkTheme: appDarkTheme(),
      onGenerateRoute: RouteGenerator.routes(),
    );
  }
}
