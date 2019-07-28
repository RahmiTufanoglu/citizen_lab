import 'package:citizen_lab/database/database_provider.dart';
import 'package:citizen_lab/entry.dart';

class Note implements Entry {
  int id;
  String uuid;
  String type;
  String title;
  String description;
  String filePath;
  String createdAt;
  String updatedAt;
  int isFirstTime;
  int isEdited;
  int cardColor;
  int cardTextColor;

  Note(
    this.uuid,
    this.type,
    this.title,
    this.description,
    this.filePath,
    this.createdAt,
    this.updatedAt,
    this.isFirstTime,
    this.isEdited,
    this.cardColor,
    this.cardTextColor,
  );

  Note.withId(
    this.id,
    this.uuid,
    this.type,
    this.title,
    this.description,
    this.filePath,
    this.createdAt,
    this.updatedAt,
    this.isFirstTime,
    this.isEdited,
    this.cardColor,
    this.cardTextColor,
  );

  Note.map(dynamic obj) {
    this.id = obj[DatabaseHelper.columnNoteId];
    this.uuid = obj[DatabaseHelper.columnProjectUuid];
    this.type = obj[DatabaseHelper.columnNoteType];
    this.title = obj[DatabaseHelper.columnNoteTitle];
    this.description = obj[DatabaseHelper.columnNoteDescription];
    this.filePath = obj[DatabaseHelper.columnNoteContent];
    this.createdAt = obj[DatabaseHelper.columnNoteCreatedAt];
    this.updatedAt = obj[DatabaseHelper.columnNoteUpdatedAt];
    this.isFirstTime = obj[DatabaseHelper.columnNoteIsFirstTime];
    this.isEdited = obj[DatabaseHelper.columnNoteIsEdited];
    this.cardColor = obj[DatabaseHelper.columnNoteCardColor];
    this.cardTextColor = obj[DatabaseHelper.columnNoteCardTextColor];
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    if (id != null) {
      map[DatabaseHelper.columnNoteId] = id;
    }
    map[DatabaseHelper.columnProjectUuid] = uuid;
    map[DatabaseHelper.columnNoteType] = type;
    map[DatabaseHelper.columnNoteTitle] = title;
    map[DatabaseHelper.columnNoteDescription] = description;
    map[DatabaseHelper.columnNoteContent] = filePath;
    map[DatabaseHelper.columnNoteCreatedAt] = createdAt;
    map[DatabaseHelper.columnNoteUpdatedAt] = updatedAt;
    map[DatabaseHelper.columnNoteIsFirstTime] = isFirstTime;
    map[DatabaseHelper.columnNoteIsEdited] = isEdited;
    map[DatabaseHelper.columnNoteCardColor] = cardColor;
    map[DatabaseHelper.columnNoteCardTextColor] = cardTextColor;

    return map;
  }

  Note.fromMap(Map<String, dynamic> map) {
    this.id = map[DatabaseHelper.columnNoteId];
    this.uuid = map[DatabaseHelper.columnProjectUuid];
    this.type = map[DatabaseHelper.columnNoteType];
    this.title = map[DatabaseHelper.columnNoteTitle];
    this.description = map[DatabaseHelper.columnNoteDescription];
    this.filePath = map[DatabaseHelper.columnNoteContent];
    this.createdAt = map[DatabaseHelper.columnNoteCreatedAt];
    this.updatedAt = map[DatabaseHelper.columnNoteUpdatedAt];
    this.isFirstTime = map[DatabaseHelper.columnNoteIsFirstTime];
    this.isEdited = map[DatabaseHelper.columnNoteIsEdited];
    this.cardColor = map[DatabaseHelper.columnNoteCardColor];
    this.cardTextColor = map[DatabaseHelper.columnNoteCardTextColor];
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
