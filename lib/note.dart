import 'package:citizen_lab/project_database_provider.dart';

class Note {
  int id;
  String project;
  String type;
  String title;
  String description;
  String content;
  int tableColumn;
  int tableRow;
  String dateCreated;
  String dateEdited;

  Note(
    this.project,
    this.type,
    this.title,
    this.description,
    this.content,
    this.tableColumn,
    this.tableRow,
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
    this.tableColumn,
    this.tableRow,
    this.dateCreated,
    this.dateEdited,
  );

  Note.map(dynamic obj) {
    this.id = obj[ProjectDatabaseProvider.columnNoteId];
    this.project = obj[ProjectDatabaseProvider.columnNoteProject];
    this.type = obj[ProjectDatabaseProvider.columnNoteType];
    this.title = obj[ProjectDatabaseProvider.columnNoteTitle];
    this.description = obj[ProjectDatabaseProvider.columnNoteDescription];
    this.content = obj[ProjectDatabaseProvider.columnNoteContent];
    this.tableColumn = obj[ProjectDatabaseProvider.columnNoteTableColumn];
    this.tableRow = obj[ProjectDatabaseProvider.columnNoteTableRow];
    this.dateCreated = obj[ProjectDatabaseProvider.columnNoteCreatedAt];
    this.dateEdited = obj[ProjectDatabaseProvider.columnNoteUpdatedAt];
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    if (id != null) {
      map[ProjectDatabaseProvider.columnNoteId] = id;
    }
    map[ProjectDatabaseProvider.columnNoteProject] = project;
    map[ProjectDatabaseProvider.columnNoteType] = type;
    map[ProjectDatabaseProvider.columnNoteTitle] = title;
    map[ProjectDatabaseProvider.columnNoteDescription] = description;
    map[ProjectDatabaseProvider.columnNoteContent] = content;
    map[ProjectDatabaseProvider.columnNoteTableColumn] = tableColumn;
    map[ProjectDatabaseProvider.columnNoteTableRow] = tableRow;
    map[ProjectDatabaseProvider.columnNoteCreatedAt] = dateCreated;
    map[ProjectDatabaseProvider.columnNoteUpdatedAt] = dateEdited;

    return map;
  }

  Note.fromMap(Map<String, dynamic> map) {
    this.id = map[ProjectDatabaseProvider.columnNoteId];
    this.project = map[ProjectDatabaseProvider.columnNoteProject];
    this.type = map[ProjectDatabaseProvider.columnNoteType];
    this.title = map[ProjectDatabaseProvider.columnNoteTitle];
    this.description = map[ProjectDatabaseProvider.columnNoteDescription];
    this.content = map[ProjectDatabaseProvider.columnNoteContent];
    this.tableColumn = map[ProjectDatabaseProvider.columnNoteTableColumn];
    this.tableRow = map[ProjectDatabaseProvider.columnNoteTableRow];
    this.dateCreated = map[ProjectDatabaseProvider.columnNoteCreatedAt];
    this.dateEdited = map[ProjectDatabaseProvider.columnNoteUpdatedAt];
  }
}
