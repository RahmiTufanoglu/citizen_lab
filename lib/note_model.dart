import 'package:flutter/widgets.dart';

import 'entries/note.dart';

class NoteModel with ChangeNotifier implements NoteBase {
  int id;
  int projectRandom;
  String type;
  String title;
  String description;
  String content;
  String dateCreated;
  String dateEdited;

  @override
  void saveNote(Note note) {
    this.id = note.id;
    this.projectRandom = note.projectRandom;
    this.type = note.type;
    this.title = note.title;
    this.description = note.description;
    this.content = note.content;
    this.dateCreated = note.dateCreated;
    this.dateEdited = note.dateEdited;
  }

  @override
  void updateNote(Note note) {
    this.id = note.id;
    this.projectRandom = note.projectRandom;
    this.type = note.type;
    this.title = note.title;
    this.description = note.description;
    this.content = note.content;
    this.dateCreated = note.dateCreated;
    this.dateEdited = note.dateEdited;
  }

  @override
  void deleteNote(Note note) {
    this.id = note.id;
    this.projectRandom = note.projectRandom;
    this.type = note.type;
    this.title = note.title;
    this.description = note.description;
    this.content = note.content;
    this.dateCreated = note.dateCreated;
    this.dateEdited = note.dateEdited;
  }
}

abstract class NoteBase {
  void saveNote(Note note);

  void updateNote(Note note);

  void deleteNote(Note note);
}