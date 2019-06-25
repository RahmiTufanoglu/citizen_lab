import 'package:citizen_lab/entries/note.dart';
import 'package:citizen_lab/projects/project.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  static final DatabaseProvider _instance = DatabaseProvider.internal();

  factory DatabaseProvider() => _instance;

  DatabaseProvider.internal();

  Database _db;

  static const int DB_VERSION = 1;
  static final String dbName = 'citizen_lab_projects2.db';

  static final String projectTable = 'projects';
  static final String columnProjectId = 'id';

  static final String columnProjectRandom = 'random';
  static final String columnProjectNoteId = 'note_id';
  static final String columnProjectTitle = 'title';
  static final String columnProjectDesc = 'description';
  static final String columnProjectCreatedAt = 'created_at';
  static final String columnProjectUpdatedAt = 'updated_at';

  static final String noteTable = 'notes';
  static final String columnNoteId = 'id';
  static final String columnNoteProject = 'project';
  static final String columnNoteType = 'type';
  static final String columnNoteTitle = 'title';
  static final String columnNoteDescription = 'description';
  static final String columnNoteContent = 'content';
  static final String columnNoteTableColumn = 'table_column';
  static final String columnNoteTableRow = 'table_row';
  static final String columnNoteCreatedAt = 'created_at';
  static final String columnNoteUpdatedAt = 'updated_at';

  static final String createProjectTable = 'CREATE TABLE $projectTable('
      '$columnProjectId INTEGER PRIMARY KEY AUTOINCREMENT,'
      '$columnProjectNoteId INTEGER REFERENCES $noteTable($columnNoteId),'
      '$columnProjectRandom INTEGER NOT NULL, '
      '$columnProjectTitle TEXT NOT NULL, '
      '$columnProjectDesc TEXT NOT NULL, '
      '$columnProjectCreatedAt TEXT NOT NULL, '
      '$columnProjectUpdatedAt TEXT NOT NULL)';

  static final String createNoteTable = 'CREATE TABLE $noteTable('
      '$columnNoteId INTEGER PRIMARY KEY AUTOINCREMENT,'
      //'$columnNoteProject TEXT NOT NULL, '
      '$columnProjectRandom INTEGER NOT NULL, '
      //'$columnProjectId TEXT NOT NULL, '
      '$columnNoteType TEXT NOT NULL, '
      '$columnNoteTitle TEXT NOT NULL, '
      '$columnNoteDescription TEXT, '
      '$columnNoteContent TEXT NOT NULL, '
      '$columnNoteCreatedAt TEXT NOT NULL, '
      '$columnNoteUpdatedAt TEXT NOT NULL)';

  Future<Database> get db async {
    return _db != null ? _db : _db = await initDb();
  }

  Future<Database> initDb() async {
    final String databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, projectTable);
    final Database db = await openDatabase(
      path,
      version: DB_VERSION,
      onCreate: _onCreate,
    );
    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(createProjectTable);
    await db.execute(createNoteTable);
  }

  Future<int> insertProject({@required Project project}) async {
    final Database db = await this.db;
    final int result = await db.insert(
      projectTable,
      project.toMap(),
    );
    return result;
  }

  Future<Project> getProject({@required int id}) async {
    final Database db = await this.db;
    final List<Map> maps = await db.query(
      projectTable,
      where: '$columnProjectId = ?',
      whereArgs: [id],
      orderBy: '$columnProjectCreatedAt ASC',
    );
    return maps.isNotEmpty ? Project.fromMap(maps.first) : null;
  }

  Future<List> getAllProjects() async {
    final Database db = await this.db;
    final List<Map<String, dynamic>> result = await db.query(
      projectTable,
      orderBy: '$columnProjectCreatedAt ASC',
    );
    return result.toList();
  }

  Future<int> deleteProject({@required int id}) async {
    final Database db = await this.db;
    return await db.delete(
      projectTable,
      where: '$columnProjectId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllProjects() async {
    final Database db = await this.db;
    return await db.delete(projectTable);
  }

  Future<int> updateProject({@required Project newProject}) async {
    final Database db = await this.db;
    final int result = await db.update(
      projectTable,
      newProject.toMap(),
      where: '$columnProjectId = ?',
      whereArgs: [newProject.id],
    );
    print('UPDATE');
    return result;
  }

  Future<int> getProjectCount() async {
    final Database db = await this.db;
    return Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT (*) FROM $projectTable'),
    );
  }

  //Future<List> getNotesOfProject({@required String id}) async {
  Future<List<Note>> getNotesOfProject({@required int random}) async {
    final db = await this.db;
    //final List<Map<String, dynamic>> maps = await db.query(
    var res = await db.query(
      noteTable,
      //where: '$columnNoteProject = ?',
      where: '$columnProjectRandom = ?',
      //whereArgs: [id],
      whereArgs: [random],
      //orderBy: '$columnNoteCreatedAt DESC',
    );
    //return maps.toList();
    List<Note> list =
        res.isNotEmpty ? res.map((c) => Note.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Note>> getAllNotes() async {
    final db = await this.db;
    var res = await db.query(noteTable);
    List<Note> list =
        res.isNotEmpty ? res.map((c) => Note.fromMap(c)).toList() : [];
    return list;
  }

  Future<int> insertNote({@required Note note}) async {
    final Database db = await this.db;
    final int result = await db.insert(
      noteTable,
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('SAVED');
    return result;
  }

  Future<Note> getNote({@required int id}) async {
    final Database db = await this.db;
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

  Future<int> deleteNote({@required int id}) async {
    final Database db = await this.db;
    print('DELETE: $id');
    return await db.delete(
      noteTable,
      where: '$columnNoteId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllNotes() async {
    final Database db = await this.db;
    return await db.delete(noteTable);
  }

  Future<int> deleteAllNotesFromProject({@required int random}) async {
    final Database db = await this.db;
    return await db.delete(
      noteTable,
      where: '$columnProjectRandom= ?',
      //where: '$columnNoteId = ?',
      whereArgs: [random],
    );
  }

  Future<int> updateNote({@required Note newNote}) async {
    final Database db = await this.db;
    final int result = await db.update(
      noteTable,
      newNote.toMap(),
      where: '$columnNoteId = ?',
      whereArgs: [newNote.id],
    );
    return result;
  }

  Future<int> getCount() async {
    final Database db = await this.db;
    return Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT (*) FROM $noteTable'),
    );
  }

  Future<void> close() async {
    final Database db = await this.db;
    return db.close();
  }
}
