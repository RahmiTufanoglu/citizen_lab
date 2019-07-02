import 'package:citizen_lab/database/database_provider.dart';
import 'package:citizen_lab/entries/note.dart';
import 'package:flutter/cupertino.dart';

class DbProvider with ChangeNotifier {
  void add(Note note) {
    if (note != null) {
      DatabaseProvider.db.insertNote(note: note);
    }
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
