import 'dart:async';

import 'package:citizen_lab/database/database_provider.dart';
import 'package:citizen_lab/entries/note.dart';

class DatabaseBloc {
  final _noteController = StreamController<List<Note>>.broadcast();

  get notes => _noteController.stream;

  dispose() {
    _noteController.close();
  }

  // Daten aus der Datenbank asynchron holen
  getNotes() async {
    _noteController.sink.add(await DatabaseProvider().getAllNotes());
  }

  DatabaseBloc() {
    getNotes();
  }

  delete(int id) {
    DatabaseProvider().deleteNote(id: id);
    getNotes();
  }

  add(Note note) {
    DatabaseProvider().insertNote(note: note);
    getNotes();
  }
}
