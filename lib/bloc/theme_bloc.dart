import 'dart:async';

import 'base_bloc.dart';

class ThemeBloc implements BaseBloc {
  final _themeController = StreamController<bool>();

  void get changeTheme => _themeController.sink.add;

  Stream<bool> get darkThemeEnabled => _themeController.stream;

  @override
  void dispose() {
    _themeController.close();
  }
}
