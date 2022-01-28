import 'dart:io';

import 'package:app_qinspecting/models/models.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  static Database? _database;
  static final DBProvider db = DBProvider._();

  DBProvider._();

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await initDB();

    return _database;
  }

  Future<Database?> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = p.join(documentsDirectory.path, 'qinspecting.db');

    // Se crea la base de datos
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute('''
        CREATE TABLE Empresas(
          Emp_Id INTEGER PRIMARY KEY,
          aut_create_cap INTEGER,
          Rol_Id INTEGER,
          CantF INTEGER,
          nombre_QI TEXT,
          nombre_base TEXT,
          ruta_logo TEXT,
          url_QI TEXT,
          Razon_social TEXT,
          Pers_Imagen TEXT,
          Carg_Descripcion TEXT,
          Pers_Email TEXT,
          Usuario_Contra TEXT,
          Complete_Name TEXT,
          Pers_Apellidos TEXT,
          Pers_Nombres TEXT,
          Pers_Celular TEXT,
          UsuarioUser INTEGER
        );
      ''');
    });
  }

  // Forma corta
  Future<int?> nuevaEmpresa(Empresa nuevaEmpresa) async {
    final db = await database;
    final res = await db?.insert('Empresas', nuevaEmpresa.toMap());
    return res;
  }

  Future<Empresa?> getEmpresaById(int id) async {
    final db = await database;
    final res =
        await db?.query('Empresas', where: 'Emp_Id = ?', whereArgs: [id]);
    return res!.isNotEmpty ? Empresa.fromMap(res.first) : null;
  }

  Future<int?> deleteEmpresa(int id) async {
    final db = await database;
    final res =
        await db?.delete('Empresas', where: 'Emp_Id= ?', whereArgs: [id]);

    return res;
  }

  Future<int?> deleteAllEmpresas() async {
    final db = await database;
    final res = await db?.delete('Empresas');

    return res;
  }

  // Future<List<ScanModel>?> getAllScan() async {
  //   final db = await database;
  //   final res = await db?.query('Scans');

  //   return res!.isNotEmpty
  //       ? res.map((s) => ScanModel.fromJson(s)).toList()
  //       : [];
  // }

  // Future<int?> updateScan(ScanModel nuevoScan) async {
  //   final db = await database;
  //   final res = await db?.update('Scans', nuevoScan.toJson(),
  //       where: 'id= ?', whereArgs: [nuevoScan.id]);

  //   return res;
  // }

}
