import 'package:citizen_lab/project_database_provider.dart';

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
    this.id = obj[ProjectDatabaseProvider.columnProjectId];
    this.title = obj[ProjectDatabaseProvider.columnProjectTitle];
    this.description = obj[ProjectDatabaseProvider.columnProjectDesc];
    this.dateCreated = obj[ProjectDatabaseProvider.columnProjectCreatedAt];
    this.dateEdited = obj[ProjectDatabaseProvider.columnProjectUpdatedAt];
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    if (id != null) {
      map[ProjectDatabaseProvider.columnProjectId] = id;
    }
    map[ProjectDatabaseProvider.columnProjectTitle] = title;
    map[ProjectDatabaseProvider.columnProjectDesc] = description;
    map[ProjectDatabaseProvider.columnProjectCreatedAt] = dateCreated;
    map[ProjectDatabaseProvider.columnProjectUpdatedAt] = dateEdited;

    return map;
  }

  Project.fromMap(Map<String, dynamic> map) {
    this.id = map[ProjectDatabaseProvider.columnProjectId];
    this.title = map[ProjectDatabaseProvider.columnProjectTitle];
    this.description = map[ProjectDatabaseProvider.columnProjectDesc];
    this.dateCreated = map[ProjectDatabaseProvider.columnProjectCreatedAt];
    this.dateEdited = map[ProjectDatabaseProvider.columnProjectUpdatedAt];
  }
}
