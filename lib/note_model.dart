import 'package:flutter/widgets.dart';

import 'entries/note.dart';

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
    this.id = note.id;
    this.uuid = note.uuid;
    this.type = note.type;
    this.title = note.title;
    this.description = note.description;
    this.content = note.filePath;
    this.dateCreated = note.createdAt;
    this.dateEdited = note.updatedAt;
    this.edited = note.isFirstTime;
  }

  @override
  void updateNote(Note note) {
    this.id = note.id;
    this.uuid = note.uuid;
    this.type = note.type;
    this.title = note.title;
    this.description = note.description;
    this.content = note.filePath;
    this.dateCreated = note.createdAt;
    this.dateEdited = note.updatedAt;
    this.edited = note.isFirstTime;
  }

  @override
  void deleteNote(Note note) {
    this.id = note.id;
    this.uuid = note.uuid;
    this.type = note.type;
    this.title = note.title;
    this.description = note.description;
    this.content = note.filePath;
    this.dateCreated = note.createdAt;
    this.dateEdited = note.updatedAt;
    this.edited = note.isFirstTime;
  }
}

abstract class NoteBase {
  void saveNote(Note note);

  void updateNote(Note note);

  void deleteNote(Note note);
}
