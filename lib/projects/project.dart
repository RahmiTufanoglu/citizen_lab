import 'package:citizen_lab/database/database_provider.dart';

class Project {
  int id;
  int random;
  String title;
  String description;
  String dateCreated;
  String dateEdited;
  int cardColor;
  int cardTextColor;

  Project(
    this.title,
    this.random,
    this.description,
    this.dateCreated,
    this.dateEdited,
    this.cardColor,
    this.cardTextColor,
  );

  Project.withId(
    this.id,
    this.random,
    this.title,
    this.description,
    this.dateCreated,
    this.dateEdited,
    this.cardColor,
    this.cardTextColor,
  );

  Project.map(dynamic obj) {
    this.id = obj[DatabaseProvider.columnProjectId];
    this.random = obj[DatabaseProvider.columnProjectRandom];
    this.title = obj[DatabaseProvider.columnProjectTitle];
    this.description = obj[DatabaseProvider.columnProjectDesc];
    this.dateCreated = obj[DatabaseProvider.columnProjectCreatedAt];
    this.dateEdited = obj[DatabaseProvider.columnProjectUpdatedAt];
    this.cardColor = obj[DatabaseProvider.columnProjectCardColor];
    this.cardTextColor = obj[DatabaseProvider.columnProjectCardTextColor];
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    if (id != null) {
      map[DatabaseProvider.columnProjectId] = id;
    }
    map[DatabaseProvider.columnProjectTitle] = title;
    map[DatabaseProvider.columnProjectRandom] = random;
    map[DatabaseProvider.columnProjectDesc] = description;
    map[DatabaseProvider.columnProjectCreatedAt] = dateCreated;
    map[DatabaseProvider.columnProjectUpdatedAt] = dateEdited;
    map[DatabaseProvider.columnProjectCardColor] = cardColor;
    map[DatabaseProvider.columnProjectCardTextColor] = cardTextColor;

    return map;
  }

  Project.fromMap(Map<String, dynamic> map) {
    this.id = map[DatabaseProvider.columnProjectId];
    this.title = map[DatabaseProvider.columnProjectTitle];
    this.random = map[DatabaseProvider.columnProjectRandom];
    this.description = map[DatabaseProvider.columnProjectDesc];
    this.dateCreated = map[DatabaseProvider.columnProjectCreatedAt];
    this.dateEdited = map[DatabaseProvider.columnProjectUpdatedAt];
    this.cardColor = map[DatabaseProvider.columnProjectCardColor];
    this.cardTextColor = map[DatabaseProvider.columnProjectCardTextColor];
  }
}
