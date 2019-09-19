import 'package:citizen_lab/app_locations.dart';
import 'package:citizen_lab/splash_page.dart';
import 'package:citizen_lab/themes/theme_changer_provider.dart';
import 'package:citizen_lab/utils/constants.dart';
import 'package:citizen_lab/utils/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final Iterable<LocalizationsDelegate<dynamic>> _localizationsDelegates = const [
    AppLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  final Iterable<Locale> _supportedLocales = const [
    Locale('en', 'US'),
    Locale('de', 'DE'),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeChangerProvider>(
      builder: (BuildContext context, ThemeChangerProvider themeChangerProvider, Widget child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          //localizationsDelegates: const [CustomLocalizationDelegate()],
          localizationsDelegates: _localizationsDelegates,
          supportedLocales: _supportedLocales,
          localeResolutionCallback: (locale, supportedLocales) => _setLocale(locale, supportedLocales),
          title: Constants.appTitle,
          home: SplashPage(),
          theme: themeChangerProvider.getTheme,
          onGenerateRoute: RouteGenerator.generateRoute(),
        );
      },
    );
  }

  Locale _setLocale(Locale locale, Iterable<Locale> supportedLocales) {
    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode && supportedLocale.countryCode == locale.countryCode) {
        return supportedLocale;
      }
    }
    return supportedLocales.first;
  }
}
