import 'dart:io';
import 'package:meta/meta.dart';
import 'package:citizen_lab/note.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class NoteDatabaseProvider {
  static final NoteDatabaseProvider _instance = NoteDatabaseProvider.internal();

  factory NoteDatabaseProvider() => _instance;

  NoteDatabaseProvider.internal();

  Database _db;

  static const int DB_VERSION = 1;
  static final String dbName = 'citizen_lab_notes.db';
  static final String noteTable = 'note_table';
  static final String columnId = 'id';
  static final String columnProject = 'project';
  static final String columnType = 'type';
  static final String columnTitle = 'title';
  static final String columnContent = 'content';
  static final String columnDateCreated = 'date_created';
  static final String columnDateEdited = 'date_edited';

  Future<Database> get db async {
    return _db != null ? _db : _db = await initDb();
  }

  initDb() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, noteTable);
    var db = await openDatabase(
      path,
      version: DB_VERSION,
      onCreate: _onCreate,
    );
    return db;
  }

  void _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE $noteTable('
          '$columnId INTEGER PRIMARY KEY AUTOINCREMENT,'
          '$columnProject TEXT, '
          '$columnType TEXT, '
          '$columnTitle TEXT, '
          '$columnContent TEXT, '
          '$columnDateCreated TEXT, '
          '$columnDateEdited TEXT)',
    );
  }

  Future<int> insertNote({@required Note note}) async {
    final db = await this.db;
    final result = await db.insert(
      noteTable,
      note.toMap(),
      //conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return result;
  }

  /*Future<Note> getNote2(int id) async {
    var dbClient = await db;
    var result =
        await dbClient.rawQuery('SELECT * FROM $noteTable WHERE id = $id');
    if (result.length == 0) return null;
    return Note.fromMap(result.first);
  }*/

  Future<Note> getNote({@required int id}) async {
    final db = await this.db;
    final List<Map> maps = await db.query(
      noteTable,
      where: '$columnId = ?',
      whereArgs: [id],
      orderBy: '$columnDateCreated ASC',
    );
    return maps.isNotEmpty ? Note.fromMap(maps.first) : null;
  }

  Future<List> getNotes() async {
    final db = await this.db;
    final result = await db.query(
      noteTable,
      orderBy: '$columnDateCreated ASC',
    );
    return result.toList();
  }

  Future<int> deleteNote({@required int id}) async {
    final db = await this.db;
    return await db.delete(
      noteTable,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAll() async {
    final db = await this.db;
    return await db.delete(noteTable);
  }

  Future<int> updateNote({@required Note newNote}) async {
    final db = await this.db;
    final result = await db.update(
      noteTable,
      newNote.toMap(),
      where: '$columnId = ?',
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
