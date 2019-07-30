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
    id = obj[DatabaseHelper.columnNoteId];
    uuid = obj[DatabaseHelper.columnProjectUuid];
    type = obj[DatabaseHelper.columnNoteType];
    title = obj[DatabaseHelper.columnNoteTitle];
    description = obj[DatabaseHelper.columnNoteDescription];
    filePath = obj[DatabaseHelper.columnNoteContent];
    createdAt = obj[DatabaseHelper.columnNoteCreatedAt];
    updatedAt = obj[DatabaseHelper.columnNoteUpdatedAt];
    isFirstTime = obj[DatabaseHelper.columnNoteIsFirstTime];
    isEdited = obj[DatabaseHelper.columnNoteIsEdited];
    cardColor = obj[DatabaseHelper.columnNoteCardColor];
    cardTextColor = obj[DatabaseHelper.columnNoteCardTextColor];
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
    id = map[DatabaseHelper.columnNoteId];
    uuid = map[DatabaseHelper.columnProjectUuid];
    type = map[DatabaseHelper.columnNoteType];
    title = map[DatabaseHelper.columnNoteTitle];
    description = map[DatabaseHelper.columnNoteDescription];
    filePath = map[DatabaseHelper.columnNoteContent];
    createdAt = map[DatabaseHelper.columnNoteCreatedAt];
    updatedAt = map[DatabaseHelper.columnNoteUpdatedAt];
    isFirstTime = map[DatabaseHelper.columnNoteIsFirstTime];
    isEdited = map[DatabaseHelper.columnNoteIsEdited];
    cardColor = map[DatabaseHelper.columnNoteCardColor];
    cardTextColor = map[DatabaseHelper.columnNoteCardTextColor];
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
