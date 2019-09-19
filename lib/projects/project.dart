import 'package:citizen_lab/database/database_helper.dart';
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
    id = obj[DatabaseHelper.columnProjectId];
    uuid = obj[DatabaseHelper.columnProjectUuid];
    title = obj[DatabaseHelper.columnProjectTitle];
    description = obj[DatabaseHelper.columnProjectDesc];
    createdAt = obj[DatabaseHelper.columnProjectCreatedAt];
    updatedAt = obj[DatabaseHelper.columnProjectUpdatedAt];
    cardColor = obj[DatabaseHelper.columnProjectCardColor];
    cardTextColor = obj[DatabaseHelper.columnProjectCardTextColor];
  }

  Map<String, dynamic> toMap() {
    //final map = Map<String, dynamic>();
    final map = <String, dynamic>{};

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
    id = map[DatabaseHelper.columnProjectId];
    title = map[DatabaseHelper.columnProjectTitle];
    uuid = map[DatabaseHelper.columnProjectUuid];
    description = map[DatabaseHelper.columnProjectDesc];
    createdAt = map[DatabaseHelper.columnProjectCreatedAt];
    updatedAt = map[DatabaseHelper.columnProjectUpdatedAt];
    cardColor = map[DatabaseHelper.columnProjectCardColor];
    cardTextColor = map[DatabaseHelper.columnProjectCardTextColor];
  }
}
