import 'package:citizen_lab/database/project_database_helper.dart';

class Note {
  int id;
  String project;
  String type;
  String title;
  String description;
  String content;
  String dateCreated;
  String dateEdited;

  Note(
    this.project,
    this.type,
    this.title,
    this.description,
    this.content,
    this.dateCreated,
    this.dateEdited,
  );

  Note.withId(
    this.id,
    this.project,
    this.type,
    this.title,
    this.description,
    this.content,
    this.dateCreated,
    this.dateEdited,
  );

  Note.map(dynamic obj) {
    this.id = obj[ProjectDatabaseHelper.columnNoteId];
    this.project = obj[ProjectDatabaseHelper.columnNoteProject];
    this.type = obj[ProjectDatabaseHelper.columnNoteType];
    this.title = obj[ProjectDatabaseHelper.columnNoteTitle];
    this.description = obj[ProjectDatabaseHelper.columnNoteDescription];
    this.content = obj[ProjectDatabaseHelper.columnNoteContent];
    this.dateCreated = obj[ProjectDatabaseHelper.columnNoteCreatedAt];
    this.dateEdited = obj[ProjectDatabaseHelper.columnNoteUpdatedAt];
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    if (id != null) {
      map[ProjectDatabaseHelper.columnNoteId] = id;
    }
    map[ProjectDatabaseHelper.columnNoteProject] = project;
    map[ProjectDatabaseHelper.columnNoteType] = type;
    map[ProjectDatabaseHelper.columnNoteTitle] = title;
    map[ProjectDatabaseHelper.columnNoteDescription] = description;
    map[ProjectDatabaseHelper.columnNoteContent] = content;
    map[ProjectDatabaseHelper.columnNoteCreatedAt] = dateCreated;
    map[ProjectDatabaseHelper.columnNoteUpdatedAt] = dateEdited;

    return map;
  }

  Note.fromMap(Map<String, dynamic> map) {
    this.id = map[ProjectDatabaseHelper.columnNoteId];
    this.project = map[ProjectDatabaseHelper.columnNoteProject];
    this.type = map[ProjectDatabaseHelper.columnNoteType];
    this.title = map[ProjectDatabaseHelper.columnNoteTitle];
    this.description = map[ProjectDatabaseHelper.columnNoteDescription];
    this.content = map[ProjectDatabaseHelper.columnNoteContent];
    this.dateCreated = map[ProjectDatabaseHelper.columnNoteCreatedAt];
    this.dateEdited = map[ProjectDatabaseHelper.columnNoteUpdatedAt];
  }
}
