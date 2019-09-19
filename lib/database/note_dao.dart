import 'package:citizen_lab/notes/note.dart';

abstract class NoteDao {
  Future<List<Note>> getNotesOfProject({String uuid});

  Future<List<Note>> getAllNotes();

  Future<int> insertNote({Note note});

  Future<Note> getNote({int id});

  Future<int> deleteNote({int id});

  Future<int> deleteAllNotes();

  Future<int> deleteAllNotesFromProject({String uuid});

  Future<int> updateNote({Note newNote});

  Future<int> getCount();
}
