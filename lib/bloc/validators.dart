import 'dart:async';

mixin Validators {
  static String titleIsEmpty = 'Title ist leer.';

  final titleValidator = StreamTransformer<String, String>.fromHandlers(
    handleData: (String title, EventSink sink) {
      if (title.isNotEmpty) {
        sink.add(title);
      } else {
        sink.addError(titleIsEmpty);
      }
    },
  );
}
