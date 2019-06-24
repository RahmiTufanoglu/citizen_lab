import 'dart:async';

mixin Validators {
  final titleValidator = StreamTransformer<String, String>.fromHandlers(
    handleData: (String title, EventSink sink) {
      if (title.isNotEmpty) {
        sink.add(title);
      } else {
        sink.addError('Title ist leer.');
      }
    },
  );
}
