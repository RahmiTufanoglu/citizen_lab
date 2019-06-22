import 'dart:async';

import 'package:citizen_lab/entries/validators.dart';
//import 'package:rxdart/rxdart.dart';

class TitleBloc with Validators implements BaseBloc {
  final _titleStreamController = StreamController<String>();

  Stream<String> get title =>
      _titleStreamController.stream.transform(titleValidator);

  //Stream<bool> get submitCheck => Observable

  @override
  void dispose() {
    _titleStreamController.close();
  }
}

abstract class BaseBloc {
  void dispose();
}
