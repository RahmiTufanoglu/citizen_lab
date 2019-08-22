import 'entries/note.dart';

abstract class NoteBase {
  void saveNote(Note note);

  void updateNote(Note note);

  void deleteNote(Note note);
}
