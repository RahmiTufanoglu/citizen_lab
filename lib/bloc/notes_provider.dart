import 'package:citizen_lab/database/database_provider.dart';
import 'package:citizen_lab/entries/note.dart';
import 'package:flutter/material.dart';

class NotesProvider with ChangeNotifier {
  Note _note;

  NotesProvider(this._note);

  getNote() => _note;

  setNote(Note note) => _note = note;

  void add(Note note) {
    DatabaseProvider.db.insertNote(note: note);
    notifyListeners();
  }

  void update(Note note) {
    if (note != null) {
      DatabaseProvider.db.updateNote(newNote: note);
    }
    notifyListeners();
  }

  void delete(Note note) {
    DatabaseProvider.db.deleteNote(id: note.id);
    notifyListeners();
  }

  void deleteAllNotesFromProject(List<Note> notes, int random) {
    DatabaseProvider.db.deleteAllNotesFromProject(random: random);
    for (int i = 0; i < notes.length; i++) {}
    notifyListeners();
  }
}
