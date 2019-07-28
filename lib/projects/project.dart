import 'package:citizen_lab/database/database_provider.dart';
import 'package:citizen_lab/entry.dart';

class Project implements Entry {
  int id;
  String uuid;
  String title;
  String description;
  String createdAt;
  String updatedAt;
  int cardColor;
  int cardTextColor;

  Project(
    this.title,
    this.uuid,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.cardColor,
    this.cardTextColor,
  );

  Project.withId(
    this.id,
    this.uuid,
    this.title,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.cardColor,
    this.cardTextColor,
  );

  Project.map(dynamic obj) {
    this.id = obj[DatabaseHelper.columnProjectId];
    this.uuid = obj[DatabaseHelper.columnProjectUuid];
    this.title = obj[DatabaseHelper.columnProjectTitle];
    this.description = obj[DatabaseHelper.columnProjectDesc];
    this.createdAt = obj[DatabaseHelper.columnProjectCreatedAt];
    this.updatedAt = obj[DatabaseHelper.columnProjectUpdatedAt];
    this.cardColor = obj[DatabaseHelper.columnProjectCardColor];
    this.cardTextColor = obj[DatabaseHelper.columnProjectCardTextColor];
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    if (id != null) {
      map[DatabaseHelper.columnProjectId] = id;
    }
    map[DatabaseHelper.columnProjectTitle] = title;
    map[DatabaseHelper.columnProjectUuid] = uuid;
    map[DatabaseHelper.columnProjectDesc] = description;
    map[DatabaseHelper.columnProjectCreatedAt] = createdAt;
    map[DatabaseHelper.columnProjectUpdatedAt] = updatedAt;
    map[DatabaseHelper.columnProjectCardColor] = cardColor;
    map[DatabaseHelper.columnProjectCardTextColor] = cardTextColor;

    return map;
  }

  Project.fromMap(Map<String, dynamic> map) {
    this.id = map[DatabaseHelper.columnProjectId];
    this.title = map[DatabaseHelper.columnProjectTitle];
    this.uuid = map[DatabaseHelper.columnProjectUuid];
    this.description = map[DatabaseHelper.columnProjectDesc];
    this.createdAt = map[DatabaseHelper.columnProjectCreatedAt];
    this.updatedAt = map[DatabaseHelper.columnProjectUpdatedAt];
    this.cardColor = map[DatabaseHelper.columnProjectCardColor];
    this.cardTextColor = map[DatabaseHelper.columnProjectCardTextColor];
  }
}
