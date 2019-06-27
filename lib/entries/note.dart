import 'package:citizen_lab/database/database_provider.dart';

class Note {
  int id;
  int projectRandom;
  String type;
  String title;
  String description;
  String content;
  String dateCreated;
  String dateEdited;
  int edited;

  Note(
    this.projectRandom,
    this.type,
    this.title,
    this.description,
    this.content,
    this.dateCreated,
    this.dateEdited,
    this.edited,
  );

  Note.withId(
    this.id,
    this.projectRandom,
    this.type,
    this.title,
    this.description,
    this.content,
    this.dateCreated,
    this.dateEdited,
    this.edited,
  );

  Note.map(dynamic obj) {
    this.id = obj[DatabaseProvider.columnNoteId];
    this.projectRandom = obj[DatabaseProvider.columnProjectRandom];
    this.type = obj[DatabaseProvider.columnNoteType];
    this.title = obj[DatabaseProvider.columnNoteTitle];
    this.description = obj[DatabaseProvider.columnNoteDescription];
    this.content = obj[DatabaseProvider.columnNoteContent];
    this.dateCreated = obj[DatabaseProvider.columnNoteCreatedAt];
    this.dateEdited = obj[DatabaseProvider.columnNoteUpdatedAt];
    this.edited = obj[DatabaseProvider.columnNoteEdited];
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    if (id != null) {
      map[DatabaseProvider.columnNoteId] = id;
    }
    map[DatabaseProvider.columnProjectRandom] = projectRandom;
    map[DatabaseProvider.columnNoteType] = type;
    map[DatabaseProvider.columnNoteTitle] = title;
    map[DatabaseProvider.columnNoteDescription] = description;
    map[DatabaseProvider.columnNoteContent] = content;
    map[DatabaseProvider.columnNoteCreatedAt] = dateCreated;
    map[DatabaseProvider.columnNoteUpdatedAt] = dateEdited;
    map[DatabaseProvider.columnNoteEdited] = edited;

    return map;
  }

  Note.fromMap(Map<String, dynamic> map) {
    this.id = map[DatabaseProvider.columnNoteId];
    this.projectRandom = map[DatabaseProvider.columnProjectRandom];
    this.type = map[DatabaseProvider.columnNoteType];
    this.title = map[DatabaseProvider.columnNoteTitle];
    this.description = map[DatabaseProvider.columnNoteDescription];
    this.content = map[DatabaseProvider.columnNoteContent];
    this.dateCreated = map[DatabaseProvider.columnNoteCreatedAt];
    this.dateEdited = map[DatabaseProvider.columnNoteUpdatedAt];
    this.edited = map[DatabaseProvider.columnNoteEdited];
  }

  /*factory Note.fromMap(Map<String, dynamic> map) => Note.withId(
      id: map[DatabaseProvider.columnNoteId],
      projectRandom: map[DatabaseProvider.columnProjectRandom],
  type: map[DatabaseProvider.columnNoteType],
  title: map[DatabaseProvider.columnNoteTitle],
  description: map[DatabaseProvider.columnNoteDescription],
  content: map[DatabaseProvider.columnNoteContent],
  dateCreated: map[DatabaseProvider.columnNoteCreatedAt],
  dateEdited: map[DatabaseProvider.columnNoteUpdatedAt],
  );*/
}
