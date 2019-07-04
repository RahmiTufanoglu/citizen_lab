import 'package:citizen_lab/splash_page.dart';
import 'package:citizen_lab/themes/theme.dart';
import 'package:citizen_lab/themes/theme_changer_provider.dart';
import 'package:citizen_lab/title_change_provider.dart';
import 'package:citizen_lab/utils/constants.dart';
import 'package:citizen_lab/utils/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'citizen_science/timer_provider.dart';

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    /*return ChangeNotifierProvider<ThemeChangerProvider>(
      builder: (BuildContext context) => ThemeChangerProvider(appLightTheme()),
      child: MaterialAppWithTheme(),
    );*/
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeChangerProvider>(
          builder: (_) => ThemeChangerProvider(appLightTheme()),
        ),
        ChangeNotifierProvider<TitleChangerProvider>(
          builder: (_) => TitleChangerProvider(),
        ),
        ChangeNotifierProvider<TimerProvider>(
          builder: (_) => TimerProvider(),
        ),
      ],
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
    final theme = Provider.of<ThemeChangerProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: APP_TITLE,
      home: SplashPage(),
      theme: theme.getTheme,
      //darkTheme: appDarkTheme(),
      onGenerateRoute: RouteGenerator.routes(),
    );
  }
}
