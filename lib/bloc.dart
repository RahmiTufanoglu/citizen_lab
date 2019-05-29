import 'dart:async';

class ThemeBloc {
  final _themeController = StreamController<bool>();

  get changeTheme => _themeController.sink.add;

  get darkThemeEnabled => _themeController.stream;

  void dispose() => _themeController.close();
}

final bloc = ThemeBloc();
