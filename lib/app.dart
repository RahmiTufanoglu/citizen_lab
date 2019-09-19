import 'package:citizen_lab/themes/theme.dart';
import 'package:citizen_lab/themes/theme_changer_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main_app.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeChangerProvider>(
          builder: (_) => ThemeChangerProvider(appLightTheme()),
        ),
      ],
      child: MainApp(),
    );
  }
}
