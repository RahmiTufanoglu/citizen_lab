import 'package:meta/meta.dart';
import 'package:citizen_lab/entries/note.dart';
import 'package:citizen_lab/projects/project.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ProjectDatabaseProvider {
  static final ProjectDatabaseProvider _instance =
      ProjectDatabaseProvider.internal();

  factory ProjectDatabaseProvider() => _instance;

  ProjectDatabaseProvider.internal();

  Database _db;

  static const int DB_VERSION = 1;
  static final String dbName = 'citizen_lab_projects.db';

  static final String projectTable = 'projects';
  static final String columnProjectId = 'id';
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

  Future<Database> get db async {
    return _db != null ? _db : _db = await initDb();
  }

  initDb() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, projectTable);
    var db = await openDatabase(
      path,
      version: DB_VERSION,
      onCreate: _onCreate,
    );
    return db;
  }

  void _onCreate(Database db, int version) async {
    print('DB CREATED');
    await db.execute(
      'CREATE TABLE $projectTable('
      '$columnProjectId INTEGER PRIMARY KEY AUTOINCREMENT,'
      '$columnProjectNoteId INTEGER REFERENCES $noteTable($columnNoteId),'
      '$columnProjectTitle TEXT NOT NULL, '
      '$columnProjectDesc TEXT NOT NULL, '
      '$columnProjectCreatedAt TEXT NOT NULL, '
      '$columnProjectUpdatedAt TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE $noteTable('
      '$columnNoteId INTEGER PRIMARY KEY AUTOINCREMENT,'
      '$columnNoteProject TEXT NOT NULL, '
      '$columnNoteType TEXT NOT NULL, '
      '$columnNoteTitle TEXT NOT NULL, '
      '$columnNoteDescription TEXT, '
      '$columnNoteContent TEXT NOT NULL, '
      '$columnNoteTableColumn INTEGER, '
      '$columnNoteTableRow INTEGER, '
      '$columnNoteCreatedAt TEXT NOT NULL, '
      '$columnNoteUpdatedAt TEXT NOT NULL)',
    );
  }

  Future<int> insertProject({@required Project project}) async {
    final db = await this.db;
    final result = await db.insert(
      projectTable,
      project.toMap(),
    );
    return result;
  }

  Future<Project> getProject({@required int id}) async {
    final db = await this.db;
    final List<Map> maps = await db.query(
      projectTable,
      where: '$columnProjectId = ?',
      whereArgs: [id],
      orderBy: '$columnProjectCreatedAt ASC',
    );
    return maps.isNotEmpty ? Project.fromMap(maps.first) : null;
  }

  Future<List> getAllProjects() async {
    final db = await this.db;
    final result = await db.query(
      projectTable,
      //where: '$columnProjectId = $columnNoteId',
      orderBy: '$columnProjectCreatedAt ASC',
    );
    return result.toList();
  }

  Future<int> deleteProject({@required int id}) async {
    final db = await this.db;
    return await db.delete(
      projectTable,
      where: '$columnProjectId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllProjects() async {
    final db = await this.db;
    return await db.delete(projectTable);
  }

  Future<int> updateProject({@required Project newProject}) async {
    final db = await this.db;
    final result = await db.update(
      projectTable,
      newProject.toMap(),
      where: '$columnProjectId = ?',
      whereArgs: [newProject.id],
    );
    return result;
  }

  Future<int> getProjectCount() async {
    var db = await this.db;
    return Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT (*) FROM $projectTable'),
    );
  }

  /**
   *
   */

  Future<int> insertNote({@required Note note}) async {
    final db = await this.db;
    final result = await db.insert(
      noteTable,
      note.toMap(),
      //conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('SAVED');
    return result;
  }

  Future<Note> getNote({@required int id}) async {
    final db = await this.db;
    final List<Map> maps = await db.query(
      noteTable,
      where: '$columnNoteId = ?',
      whereArgs: [id],
      orderBy: '$columnNoteCreatedAt DESC',
    );
    return maps.isNotEmpty ? Note.fromMap(maps.first) : null;
  }

  //Future<List> getAllNotes({@required int id}) async {
  Future<List> getAllNotes() async {
    final db = await this.db;
    final result = await db.query(
      noteTable,
      //where: '$columnNoteTitle = ?',
      //where: '$columnNoteId = ?',
      //whereArgs: [title],
      //whereArgs: [id],
      orderBy: '$columnNoteCreatedAt DESC',
    );
    return result.toList();
  }

  Future<int> deleteNote({@required int id}) async {
    final db = await this.db;
    print('DELETE: $id');
    return await db.delete(
      noteTable,
      where: '$columnNoteId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllNotes() async {
    final db = await this.db;
    return await db.delete(noteTable);
  }

  Future<int> updateNote({@required Note newNote}) async {
    final db = await this.db;
    final result = await db.update(
      noteTable,
      newNote.toMap(),
      where: '$columnNoteId = ?',
      whereArgs: [newNote.id],
    );
    return result;
  }

  Future<int> getCount() async {
    var db = await this.db;
    return Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT (*) FROM $noteTable'),
    );
  }

  Future close() async {
    var db = await this.db;
    return db.close();
  }
}
