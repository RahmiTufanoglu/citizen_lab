import 'package:citizen_lab/database/database_helper.dart';
import 'package:citizen_lab/entries/note.dart';
import 'package:flutter/material.dart';

class NotesProvider with ChangeNotifier {
  Note _note;

  NotesProvider(this._note);

  getNote() => _note;

  setNote(Note note) => _note = note;

  void add(Note note) {
    DatabaseHelper.db.insertNote(note: note);
    notifyListeners();
  }

  void update(Note note) {
    if (note != null) {
      DatabaseHelper.db.updateNote(newNote: note);
    }
    notifyListeners();
  }

  void delete(Note note) {
    DatabaseHelper.db.deleteNote(id: note.id);
    notifyListeners();
  }

  void deleteAllNotesFromProject(List<Note> notes, String uuid) {
    DatabaseHelper.db.deleteAllNotesFromProject(uuid: uuid);
    for (int i = 0; i < notes.length; i++) {}
    notifyListeners();
  }
}
