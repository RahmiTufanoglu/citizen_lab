import 'package:citizen_lab/splash_page.dart';
import 'package:citizen_lab/themes/theme.dart';
import 'package:citizen_lab/themes/theme_changer_provider.dart';
import 'package:citizen_lab/title_change_provider.dart';
import 'package:citizen_lab/utils/constants.dart';
import 'package:citizen_lab/utils/route_generator.dart';
import 'package:flutter/foundation.dart';
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
      localizationsDelegates: [
        CustomLocalizationDelegate(),
      ],
      debugShowCheckedModeBanner: false,
      title: appTitle,
      home: SplashPage(),
      theme: theme.getTheme,
      //darkTheme: appDarkTheme(),
      onGenerateRoute: RouteGenerator.routes(),
    );
  }
}

class CustomLocalizationDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const CustomLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'en';

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      SynchronousFuture<MaterialLocalizations>(const CustomLocalization());

  @override
  bool shouldReload(CustomLocalizationDelegate old) => false;

  @override
  String toString() => 'CustomLocalization.delegate(de_DE)';
}

class CustomLocalization extends DefaultMaterialLocalizations {
  const CustomLocalization();

  @override
  String get searchFieldLabel => 'Suche';
}
