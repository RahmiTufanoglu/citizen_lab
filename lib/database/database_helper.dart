import 'package:citizen_lab/database/project_dao.dart';
import 'package:citizen_lab/notes/note.dart';
import 'package:citizen_lab/projects/project.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'note_dao.dart';

class DatabaseHelper implements ProjectDao, NoteDao {
  static final DatabaseHelper db = DatabaseHelper._();

  DatabaseHelper._();

  Database _db;

  static const int dbVersion = 1;
  static const String dbName = 'citizen_lab.db';

  static const String projectTable = 'projects';
  static const String columnProjectId = 'id';

  static const String columnProjectUuid = 'uuid';
  static const String columnProjectNoteId = 'note_id';
  static const String columnProjectTitle = 'title';
  static const String columnProjectDesc = 'description';
  static const String columnProjectCreatedAt = 'created_at';
  static const String columnProjectUpdatedAt = 'updated_at';
  static const String columnProjectCardColor = 'card_color';
  static const String columnProjectCardTextColor = 'card_text_color';

  static const String noteTable = 'notes';
  static const String columnNoteId = 'id';
  static const String columnNoteProject = 'project';
  static const String columnNoteType = 'type';
  static const String columnNoteTitle = 'title';
  static const String columnNoteDescription = 'description';
  static const String columnNoteContent = 'content';
  static const String columnNoteTableColumn = 'table_column';
  static const String columnNoteTableRow = 'table_row';
  static const String columnNoteCreatedAt = 'created_at';
  static const String columnNoteUpdatedAt = 'updated_at';
  static const String columnNoteIsFirstTime = 'first_time';
  static const String columnNoteIsEdited = 'edited';
  static const String columnNoteCardColor = 'card_color';
  static const String columnNoteCardTextColor = 'card_text_color';

  static const String createProjectTable = 'CREATE TABLE $projectTable('
      '$columnProjectId INTEGER PRIMARY KEY AUTOINCREMENT,'
      '$columnProjectNoteId INTEGER REFERENCES $noteTable($columnNoteId),'
      '$columnProjectUuid TEXT NOT NULL, '
      '$columnProjectTitle TEXT NOT NULL, '
      '$columnProjectDesc TEXT NOT NULL, '
      '$columnProjectCreatedAt TEXT NOT NULL, '
      '$columnProjectUpdatedAt TEXT NOT NULL, '
      '$columnProjectCardColor INTEGER NOT NULL, '
      '$columnProjectCardTextColor INTEGER NOT NULL)';

  static const String createNoteTable = 'CREATE TABLE $noteTable('
      '$columnNoteId INTEGER PRIMARY KEY AUTOINCREMENT,'
      '$columnProjectUuid TEXT NOT NULL, '
      '$columnNoteType TEXT NOT NULL, '
      '$columnNoteTitle TEXT NOT NULL, '
      '$columnNoteDescription TEXT NOT NULL, '
      '$columnNoteContent TEXT NOT NULL, '
      '$columnNoteCreatedAt TEXT NOT NULL, '
      '$columnNoteUpdatedAt TEXT NOT NULL, '
      '$columnNoteIsFirstTime INTEGER NOT NULL, '
      '$columnNoteIsEdited INTEGER NOT NULL, '
      '$columnNoteCardColor INTEGER NOT NULL, '
      '$columnNoteCardTextColor INTEGER NOT NULL)';

  Future<Database> get database async => _db ?? await _initDb();

  Future<Database> _initDb() async {
    final String databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, projectTable);
    final Database db = await openDatabase(
      path,
      version: dbVersion,
      onCreate: _onCreate,
    );
    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(createProjectTable);
    await db.execute(createNoteTable);
  }

  @override
  Future<int> insertProject({Project project}) async {
    final Database db = await database;
    final int result = await db.insert(
      projectTable,
      project.toMap(),
      //conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return result;
  }

  @override
  Future<Project> getProject({int id}) async {
    final Database db = await database;
    final List<Map> maps = await db.query(
      projectTable,
      where: '$columnProjectId = ?',
      whereArgs: [id],
      orderBy: '$columnProjectCreatedAt ASC',
    );
    return maps.isNotEmpty ? Project.fromMap(maps.first) : null;
  }

  /*@override
  Future<List> getAllProjects() async {
    final Database db = await this.database;
    final List<Map<String, dynamic>> result = await db.query(
      projectTable,
      orderBy: '$columnProjectCreatedAt ASC',
    );
    return result.toList();
  }*/

  @override
  Future<List<Project>> getAllProjects() async {
    //Future<List<dynamic>> getAllProjects() async {
    final db = await database;
    final result = await db.query(projectTable);
    //final list = result.isNotEmpty
    final List<Project> list = result.isNotEmpty
        ? result.map((map) {
            return Project.fromMap(map);
          }).toList()
        : [];
    return list;
  }

  /*@override
  Future<List<Project>> getAllProjects() async {
    final Database db = await this.database;
    var res = await db.query(noteTable);
    List<Project> list = res.isNotEmpty
        ? res.map((project) {
            return Project.fromMap(project);
          }).toList()
        : [];
    return list;
  }*/

  @override
  Future<int> deleteProject({int id}) async {
    final db = await database;
    return db.delete(
      projectTable,
      where: '$columnProjectId = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<int> deleteAllProjects() async {
    final db = await database;
    return db.delete(projectTable);
  }

  @override
  Future<int> updateProject({Project newProject}) async {
    final db = await database;
    final result = await db.update(
      projectTable,
      newProject.toMap(),
      where: '$columnProjectId = ?',
      whereArgs: [newProject.id],
    );
    return result;
  }

  @override
  Future<int> getProjectCount() async {
    final db = await database;
    return Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT (*) FROM $projectTable'),
    );
  }

  @override
  //Future<List> getNotesOfProject({@required String id}) async {
  Future<List<Note>> getNotesOfProject({String uuid}) async {
    final db = await database;
    //final List<Map<String, dynamic>> maps = await db.query(
    final result = await db.query(
      noteTable,
      where: '$columnProjectUuid = ?',
      //whereArgs: [id],
      whereArgs: [uuid],
      //orderBy: order == null ? '$columnNoteCreatedAt DESC' : order,
      orderBy: '$columnNoteCreatedAt DESC',
    );
    //return maps.toList();
    final List<Note> list = result.isNotEmpty
        ? result.map((map) {
            return Note.fromMap(map);
          }).toList()
        : [];
    return list;
  }

  @override
  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final res = await db.query(noteTable);
    final List<Note> list = res.isNotEmpty
        ? res.map((map) {
            return Note.fromMap(map);
          }).toList()
        : [];
    return list;
  }

  @override
  Future<int> insertNote({Note note}) async {
    final Database db = await database;
    final int result = await db.insert(
      noteTable,
      note.toMap(),
      //conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return result;
  }

  @override
  Future<Note> getNote({int id}) async {
    final Database db = await database;
    final List<Map> maps = await db.query(
      noteTable,
      where: '$columnNoteId = ?',
      whereArgs: [id],
      orderBy: '$columnNoteCreatedAt DESC',
    );
    return maps.isNotEmpty ? Note.fromMap(maps.first) : null;
  }

  /*Future<List> getAllNotes() async {
    final Database db = await this.db;
    final List<Map<String, dynamic>> result = await db.query(
      noteTable,
      orderBy: '$columnNoteCreatedAt DESC',
    );
    return result.toList();
  }*/

  @override
  Future<int> deleteNote({int id}) async {
    final Database db = await database;
    return db.delete(
      noteTable,
      where: '$columnNoteId = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<int> deleteAllNotes() async {
    final Database db = await database;
    return db.delete(noteTable);
  }

  @override
  Future<int> deleteAllNotesFromProject({String uuid}) async {
    print('deleteAllNotesFromProject');
    final Database db = await database;
    return db.delete(
      noteTable,
      where: '$columnProjectUuid= ?',
      //where: '$columnNoteId = ?',
      whereArgs: [uuid],
    );
  }

  @override
  Future<int> updateNote({Note newNote}) async {
    final Database db = await database;
    final int result = await db.update(
      noteTable,
      newNote.toMap(),
      where: '$columnNoteId = ?',
      whereArgs: [newNote.id],
    );
    return result;
  }

  @override
  Future<int> getCount() async {
    final Database db = await database;
    return Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT (*) FROM $noteTable'),
    );
  }

  Future<void> close() async {
    final Database db = await database;
    return db.close();
  }
}
