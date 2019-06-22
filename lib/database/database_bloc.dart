import 'dart:async';

import 'package:citizen_lab/database/project_database_helper.dart';
import 'package:citizen_lab/entries/note.dart';

class DatabaseBloc {
  final _noteController = StreamController<List<Note>>.broadcast();

  get notes => _noteController.stream;

  dispose() {
    _noteController.close();
  }

  // Daten aus der Datenbank asynchron holen
  getNotes() async {
    _noteController.sink.add(await ProjectDatabaseHelper().getAllNotes());
  }

  DatabaseBloc() {
    getNotes();
  }

  delete(int id) {
    ProjectDatabaseHelper().deleteNote(id: id);
    getNotes();
  }

  add(Note note) {
    ProjectDatabaseHelper().insertNote(note: note);
    getNotes();
  }
}
