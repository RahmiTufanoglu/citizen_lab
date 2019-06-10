import 'package:citizen_lab/database/project_database_helper.dart';

class Project {
  int id;
  String title;
  String description;
  String dateCreated;
  String dateEdited;

  Project(
    this.title,
    this.description,
    this.dateCreated,
    this.dateEdited,
  );

  Project.withId(
    this.id,
    this.title,
    this.description,
    this.dateCreated,
    this.dateEdited,
  );

  Project.map(dynamic obj) {
    this.id = obj[ProjectDatabaseHelper.columnProjectId];
    this.title = obj[ProjectDatabaseHelper.columnProjectTitle];
    this.description = obj[ProjectDatabaseHelper.columnProjectDesc];
    this.dateCreated = obj[ProjectDatabaseHelper.columnProjectCreatedAt];
    this.dateEdited = obj[ProjectDatabaseHelper.columnProjectUpdatedAt];
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    if (id != null) {
      map[ProjectDatabaseHelper.columnProjectId] = id;
    }
    map[ProjectDatabaseHelper.columnProjectTitle] = title;
    map[ProjectDatabaseHelper.columnProjectDesc] = description;
    map[ProjectDatabaseHelper.columnProjectCreatedAt] = dateCreated;
    map[ProjectDatabaseHelper.columnProjectUpdatedAt] = dateEdited;

    return map;
  }

  Project.fromMap(Map<String, dynamic> map) {
    this.id = map[ProjectDatabaseHelper.columnProjectId];
    this.title = map[ProjectDatabaseHelper.columnProjectTitle];
    this.description = map[ProjectDatabaseHelper.columnProjectDesc];
    this.dateCreated = map[ProjectDatabaseHelper.columnProjectCreatedAt];
    this.dateEdited = map[ProjectDatabaseHelper.columnProjectUpdatedAt];
  }
}
