import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:app_qinspecting/models/models.dart';

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
        CREATE TABLE Empresas( Emp_Id INTEGER PRIMARY KEY, aut_create_cap INTEGER, Rol_Id INTEGER, CantF INTEGER, nombre_QI TEXT, nombre_base TEXT, ruta_logo TEXT, url_QI TEXT, Razon_social TEXT, Pers_Imagen TEXT, Carg_Descripcion TEXT, Pers_Email TEXT, Usuario_Contra TEXT, Complete_Name TEXT, Pers_Apellidos TEXT, Pers_Nombres TEXT, Pers_Celular TEXT, UsuarioUser INTEGER );
      ''');
      await db.execute('''
        CREATE TABLE DataUsuario( id INTEGER PRIMARY KEY, UsuarioUser INTEGER, Usuario_Contra TEXT, Pers_LugarExpDoc INTEGER, Ciu_Nombre TEXT, Dpt_Id INTEGER, Departamento TEXT, Pers_FechaNaci TEXT, Pers_Genero TEXT, Pers_Rh TEXT, Pers_Arl TEXT, Pers_Eps TEXT, Pers_Afp TEXT, Pers_Celular TEXT, Pers_Direccion TEXT, Pers_Apellidos TEXT, Pers_Nombres TEXT, Pers_Email TEXT, Pers_Imagen TEXT, Carg_id INTEGER, Carg_Descripcion TEXT, Usuario_Estado INTEGER, estado INTEGER, TipoDoc_Id INTEGER, TipoDoc_Descrip TEXT, Rol_Id INTEGER, Rol_Nombre TEXT, Rol_Descripcion TEXT, DocCond_Id INTEGER, DocCond_Lice_Cond INTEGER, DocCond_CatLiceCond TEXT);
      ''');
      await db.execute('''
        CREATE TABLE Departamentos(value INTEGER PRIMARY KEY, label TEXT);
      ''');
      await db.execute('''
        CREATE TABLE Ciudades(value INTEGER PRIMARY KEY, label TEXT, id_departamento INTEGER, CONSTRAINT fk_departamento FOREIGN KEY (id_departamento) REFERENCES Departamentos(Dpt_Id));
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

  Future<List<Empresa>?> getAllScan() async {
    final db = await database;
    final res = await db?.query('Empresas');

    return res!.isNotEmpty ? res.map((s) => Empresa.fromMap(s)).toList() : [];
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

  // CONSULTAS PARA USER DATA
  Future<int?> nuevoUser(UserData nuevoUser) async {
    final db = await database;
    final res = await db?.insert('DataUsuario', nuevoUser.toMap());
    return res;
  }

  Future<UserData?> getUserById(int id) async {
    final db = await database;
    final res =
        await db?.query('DataUsuario', where: 'id = ?', whereArgs: [id]);
    return res!.isNotEmpty ? UserData.fromMap(res.first) : null;
  }

  Future<int?> updateUser(UserData nuevoDatosUsuario) async {
    final db = await database;
    final res = await db?.update('DataUsuario', nuevoDatosUsuario.toMap(),
        where: 'id= ?', whereArgs: [nuevoDatosUsuario.id]);
    return res;
  }

  // CONSULTAS PARA MODULO INSPECCIONES
  Future<int?> nuevoDepartamento(Departamentos nuevoDepartamento) async {
    final db = await database;
    final res = await db?.insert('Departamentos', nuevoDepartamento.toMap());
    return res;
  }

  Future<Departamentos?> getDepartamentoById(int id) async {
    final db = await database;
    final res =
        await db?.query('Departamentos', where: 'value = ?', whereArgs: [id]);
    return res!.isNotEmpty ? Departamentos.fromMap(res.first) : null;
  }

  Future<List<Departamentos>?> getAllDepartamentos() async {
    final db = await database;
    final res = await db?.query('Departamentos');

    return res!.isNotEmpty
        ? res.map((s) => Departamentos.fromMap(s)).toList()
        : [];
  }

  Future<int?> nuevaCiudad(Ciudades nuevaCiudad) async {
    final db = await database;
    final res = await db?.insert('Ciudades', nuevaCiudad.toMap());
    return res;
  }

  Future<Ciudades?> getCiudadById(int id) async {
    final db = await database;
    final res =
        await db?.query('Ciudades', where: 'value = ?', whereArgs: [id]);
    return res!.isNotEmpty ? Ciudades.fromMap(res.first) : null;
  }
}
