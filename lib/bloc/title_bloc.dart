import 'dart:async';

import 'package:citizen_lab/bloc/validators.dart';
import 'package:rxdart/rxdart.dart';

import 'base_bloc.dart';

class TitleBloc with Validators implements BaseBloc {
  //final _titleStreamController = StreamController<String>();
  final _titleStreamController = BehaviorSubject<String>();

  Stream<String> get title =>
      _titleStreamController.stream.transform(titleValidator);

  Function(String) get changeTitle => _titleStreamController.sink.add;

  TitleBloc() {
    _titleStreamController.stream.listen(checkAppBarTitle);
  }

  void checkAppBarTitle(String s) {}

  @override
  void dispose() {
    _titleStreamController.close();
  }
}
