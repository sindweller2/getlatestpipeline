import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'database_model.dart';

class DatabaseHelper {
  static final _databaseName = "Parameter.db";
  static final _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
              CREATE TABLE $tableParameter (
                $columnId INTEGER PRIMARY KEY,
                $columnUrl TEXT NULL,
                $columnToken TEXT NULL,
                $columnProject TEXT NULL,
                $columnRef TEXT NULL
              )
              ''');
  }

  Future<Parameter> selectId(int id) async {
    Database db = await database;
    List<Map> maps = await db.query(tableParameter,
        columns: [columnId, columnUrl, columnToken, columnProject, columnRef],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return Parameter.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Parameter>> selectAll() async {
    Database db = await database;
    List<Map> maps = await db.query(tableParameter);

    List<Parameter> parameters = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        parameters.add(Parameter.fromMap(maps[i]));
      }
    }
    return parameters;
  }

  Future<int> insert(Parameter parameter) async {
    Database db = await database;
    return await db.insert(
      tableParameter,
      parameter.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(Parameter parameter) async {
    Database db = await database;
    return await db.update(tableParameter, parameter.toMap(),
        where: '$columnId = ?', whereArgs: [parameter.id]);
  }

  Future<int> delete(int id) async {
    Database db = await database;
    return await db
        .delete(tableParameter, where: '$columnId = ?', whereArgs: [id]);
  }
}
