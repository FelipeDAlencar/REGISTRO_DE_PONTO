import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final _nomeBase = "bd";
  static final _versaoBase = 1;
  static final tbPonto = "ponto";

  static final colunaId = '_id';
  static final colunaDataHora = 'data_hora';
  static final colunaDiaDaSemana = 'dia_da_semana';
  static final colunaCod = 'cod';

  DatabaseHelper._();
  static final DatabaseHelper dbHelper = DatabaseHelper._();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDataBase();
    return _database;
  }

  _initDataBase() async {
    Directory docDir = await getApplicationDocumentsDirectory();
    String caminho = join(docDir.path, _nomeBase);
    return await openDatabase(caminho,
        version: _versaoBase, onCreate: _onCreate);
  }

  Future<dynamic> _onCreate(Database db, int version) async {
    await db.execute(''' CREATE TABLE IF NOT EXISTS $tbPonto (
      $colunaId INTEGER PRIMARY KEY,
      $colunaDataHora TEXT NOT NULL,
      $colunaDiaDaSemana INT NOT NULL,
      $colunaCod INT NOT NULL
      );
    
    ''');
  }
  /*
  Future<dynamic> _onCreate(Database db, int version) async {
    await db.execute(''' CREATE TABLE IF NOT EXISTS $tbUsuario (
      $colunaId INTEGER PRIMARY KEY,
      $colunaLogin TEXT NOT NULL,
      $colunaEmail TEXT NOT NULL,
      $colunaNome TEXT NOT NULL,
      $colunaPerfil TEXT NOT NULL
      );
    
    ''');
  }
 */

  Future<int> insert(Map<String, dynamic> linha) async {
    Database db = await dbHelper.database;
    return await db.insert(tbPonto, linha);
  }

  /*SELECT * FROM usuario where _id = (SELECT MAX(_id) FROM usuario)*/
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await dbHelper.database;
    return await db.query(tbPonto);
  }

  deletar() async {
    Database db = await dbHelper.database;
    db.execute("DROP TABLE $tbPonto");
  }

  limparDados() async {
    Database db = await dbHelper.database;
    return db.rawDelete('DELETE FROM $tbPonto');
  }
}
