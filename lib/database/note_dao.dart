import 'package:citizen_lab/entries/note.dart';
import 'package:flutter/widgets.dart';

abstract class NoteDao {
  Future<List<Note>> getNotesOfProject({@required String uuid});

  Future<List<Note>> getAllNotes();

  Future<int> insertNote({@required Note note});

  Future<Note> getNote({@required int id});

  Future<int> deleteNote({@required int id});

  Future<int> deleteAllNotes();

  Future<int> deleteAllNotesFromProject({@required String uuid});

  Future<int> updateNote({@required Note newNote});

  Future<int> getCount();
}
