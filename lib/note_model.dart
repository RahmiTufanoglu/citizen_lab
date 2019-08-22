import 'package:flutter/widgets.dart';

import 'entries/note.dart';
import 'note_base.dart';

class NoteModel with ChangeNotifier implements NoteBase {
  int id;
  String uuid;
  String type;
  String title;
  String description;
  String content;
  String dateCreated;
  String dateEdited;
  int edited;

  //String cardColor;
  //String textColor;

  @override
  void saveNote(Note note) {
    id = note.id;
    uuid = note.uuid;
    type = note.type;
    title = note.title;
    description = note.description;
    content = note.filePath;
    dateCreated = note.createdAt;
    dateEdited = note.updatedAt;
    edited = note.isFirstTime;
  }

  @override
  void updateNote(Note note) {
    id = note.id;
    uuid = note.uuid;
    type = note.type;
    title = note.title;
    description = note.description;
    content = note.filePath;
    dateCreated = note.createdAt;
    dateEdited = note.updatedAt;
    edited = note.isFirstTime;
  }

  @override
  void deleteNote(Note note) {
    id = note.id;
    uuid = note.uuid;
    type = note.type;
    title = note.title;
    description = note.description;
    content = note.filePath;
    dateCreated = note.createdAt;
    dateEdited = note.updatedAt;
    edited = note.isFirstTime;
  }
}
