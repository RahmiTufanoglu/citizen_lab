import 'package:citizen_lab/splash_page.dart';
import 'package:citizen_lab/themes/theme_changer_provider.dart';
import 'package:citizen_lab/utils/constants.dart';
import 'package:citizen_lab/utils/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'custom_localization_delegate.dart';

class MaterialAppWithTheme extends StatefulWidget {
  @override
  _MaterialAppWithThemeState createState() => _MaterialAppWithThemeState();
}

class _MaterialAppWithThemeState extends State<MaterialAppWithTheme> {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChangerProvider>(context);

    return MaterialApp(
      localizationsDelegates: [
        const CustomLocalizationDelegate(),
      ],
      debugShowCheckedModeBanner: false,
      title: appTitle,
      home: SplashPage(),
      theme: theme.getTheme,
      //darkTheme: appDarkTheme(),
      onGenerateRoute: RouteGenerator.generateRoute(),
    );
  }
}
