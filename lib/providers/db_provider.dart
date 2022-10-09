import 'dart:convert';
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
        CREATE TABLE ResumenPreoperacional(id INTEGER PRIMARY KEY AUTOINCREMENT, placa TEXT, fechaPreoperacional TEXT, ciudadGps TEXT, kilometraje NUMERIC, cantTanqueoGalones NUMERIC, urlFotoKm TEXT, usuarioPreoperacional TEXT, numeroGuia TEXT, urlFotoGuia TEXT, placaVehiculo TEXT, placaRemolque TEXT, idCiudad NUMERIC, ciudad TEXT, respuestas TEXT, base TEXT);
      ''');
      await db.execute('''
        CREATE TABLE RespuestasPreoperacional(id INTEGER PRIMARY KEY AUTOINCREMENT, idCategoria INTEGER, idItem INTEGER, item TEXT, respuesta TEXT, adjunto TEXT, observaciones TEXT, base TEXT, fkPreoperacional INTEGER, CONSTRAINT fkPreoperacional FOREIGN KEY (id) REFERENCES ResumenPreoperacional(id) ON DELETE CASCADE) ;
      ''');
      await db.execute('''
        CREATE TABLE Empresas(id INTEGER PRIMARY KEY AUTOINCREMENT, idEmpresa INTEGER, nombreBase TEXT UNIQUE, autCreateCap NUMERIC, numeroDocumento TEXT, password TEXT, apellidos TEXT, nombres TEXT, numeroCelular TEXT, email TEXT, nombreCargo TEXT, urlFoto TEXT, idRol NUMERIC, tieneFirma NUMERIC, razonSocial TEXT, nombreQi TEXT, urlQi TEXT, rutaLogo TEXT);
      ''');
      await db.execute('''
        CREATE TABLE personal(id INTEGER PRIMARY KEY AUTOINCREMENT, empresa TEXT UNIQUE, numeroDocumento TEXT, password TEXT, lugarExpDocumento NUMERIC, nombreCiudad TEXT, fkIdDepartamento NUMERIC, departamento TEXT, fechaNacimiento TEXT, genero TEXT, rh TEXT, arl TEXT, eps TEXT, afp TEXT, numeroCelular TEXT, direccion TEXT, apellidos TEXT, nombres TEXT, email TEXT, urlFoto TEXT, idCargo NUMERIC, nombreCargo TEXT, estadoPersonal NUMERIC, idTipoDocumento NUMERIC, nombreTipoDocumento TEXT, rolId NUMERIC, rolNombre TEXT, rolDescripcion TEXT, idFirma NUMERIC, base TEXT);
      ''');
      await db.execute('''
        CREATE TABLE TipoDocumentos(value INTEGER PRIMARY KEY, label TEXT);
      ''');
      await db.execute('''
        CREATE TABLE Departamentos(value INTEGER PRIMARY KEY, label TEXT);
      ''');
      await db.execute('''
        CREATE TABLE Ciudades(value INTEGER PRIMARY KEY, label TEXT, id_departamento INTEGER, CONSTRAINT fk_departamento FOREIGN KEY (id_departamento) REFERENCES Departamentos(Dpt_Id));
      ''');
      await db.execute('''
        CREATE TABLE Vehiculos(idVehiculo INTEGER PRIMARY KEY AUTOINCREMENT, placa TEXT UNIQUE, idTpVehiculo INTEGER, modelo INTEGER, nombreMarca TEXT, color TEXT, licenciaTransito TEXT, base TEXT);
      ''');
      await db.execute('''
        CREATE TABLE Remolques(idRemolque INTEGER PRIMARY KEY AUTOINCREMENT, placa TEXT UNIQUE, idTpVehiculo INTEGER, modelo INTEGER, nombreMarca TEXT, color TEXT, numeroMatricula TEXT, numeroEjes INTEGER, base TEXT);
      ''');
      await db.execute('''
        CREATE TABLE ItemsInspeccion(id TEXT PRIMARY KEY, placa TEXT, tipoVehiculo INTEGER, idCategoria INTEGER, categoria TEXT, idItem, item TEXT, base TEXT);
      ''');
    });
  }

  // Forma corta
  Future<int?> nuevaEmpresa(Empresa nuevaEmpresa) async {
    final db = await database;
    print(nuevaEmpresa.toJson());
    final res = await db?.insert('Empresas', nuevaEmpresa.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  Future<Empresa?> getEmpresaById(String base) async {
    final db = await database;
    final res =
        await db?.query('Empresas', where: 'nombreBase = ?', whereArgs: [base]);
    return res!.isNotEmpty ? Empresa.fromMap(res.first) : null;
  }

  Future<List<Empresa>?> getAllEmpresas() async {
    final db = await database;
    final res = await db?.query('Empresas');

    return res!.isNotEmpty ? res.map((s) => Empresa.fromMap(s)).toList() : [];
  }

  Future<List<Empresa>?> getAllEmpresasByUsuario(
      String usuario, password) async {
    final db = await database;
    final res = await db?.query('Empresas',
        where: 'numeroDocumento = ? AND password = ?',
        whereArgs: [usuario, password]);

    return res!.isNotEmpty ? res.map((s) => Empresa.fromMap(s)).toList() : [];
  }

  Future<int?> deleteEmpresa(int id) async {
    final db = await database;
    final res =
        await db?.delete('Empresas', where: 'idEmpresa= ?', whereArgs: [id]);

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
    final res = await db?.insert('personal', nuevoUser.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  Future<UserData> getUser(
      String numeroDocumento, String password, String base) async {
    final db = await database;
    final res = await db?.query('personal',
        where: 'numeroDocumento = ? AND password = ? AND base = ?',
        whereArgs: [numeroDocumento, password, base]);
    print('$numeroDocumento, $password, $base');
    return UserData.fromMap(res!.first);
  }

  Future<int?> updateUser(UserData nuevoDatosUsuario) async {
    final db = await database;
    final res = await db?.update('personal', nuevoDatosUsuario.toMap(),
        where: 'numeroDocumento= ? AND base = ?',
        whereArgs: [nuevoDatosUsuario.id, nuevoDatosUsuario.base]);
    return res;
  }

  Future<int?> nuevoTipoDocumento(TipoDocumentos nuevoTipoDoc) async {
    final db = await database;
    final res = await db?.insert('TipoDocumentos', nuevoTipoDoc.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  Future<List<TipoDocumentos>?> getAllTipoDocs() async {
    final db = await database;
    final res = await db?.query('TipoDocumentos');

    return res!.isNotEmpty
        ? res.map((s) => TipoDocumentos.fromMap(s)).toList()
        : [];
  }

  // CONSULTAS PARA MODULO INSPECCIONES
  Future<int?> nuevoDepartamento(Departamentos nuevoDepartamento) async {
    final db = await database;
    final res = await db?.insert('Departamentos', nuevoDepartamento.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
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
    final res = await db?.insert('Ciudades', nuevaCiudad.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  Future<Ciudades?> getCiudadById(int id) async {
    final db = await database;
    final res =
        await db?.query('Ciudades', where: 'value = ?', whereArgs: [id]);
    return res!.isNotEmpty ? Ciudades.fromMap(res.first) : null;
  }

  Future<List<Ciudades>?> getCiudadesByIdDepartamento(int id) async {
    final db = await database;
    final res = await db
        ?.query('Ciudades', where: 'id_departamento = ?', whereArgs: [id]);
    return res!.isNotEmpty ? res.map((s) => Ciudades.fromMap(s)).toList() : [];
  }

  Future<int?> nuevoVehiculo(Vehiculo nuevoVehiculo) async {
    final db = await database;
    final res = await db?.insert('Vehiculos', nuevoVehiculo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  Future<int?> clearsVehiculos() async {
    final db = await database;
    final res = await db?.delete('Vehiculos');
    return res;
  }

  Future<int?> clearsRemolques() async {
    final db = await database;
    final res = await db?.delete('Remolques');
    return res;
  }

  Future<int?> nuevoRemolque(Remolque nuevoRemolque) async {
    final db = await database;
    final res = await db?.insert('Remolques', nuevoRemolque.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  Future<Vehiculo?> getVehiculoByPlate(String placa) async {
    final db = await database;
    final res =
        await db?.query('Vehiculos', where: 'placa = ?', whereArgs: [placa]);
    return res!.isNotEmpty ? Vehiculo.fromMap(res.first) : null;
  }

  Future<Remolque?> getRemolqueByPlate(String placa) async {
    final db = await database;
    final res =
        await db?.query('Remolques', where: 'placa = ?', whereArgs: [placa]);
    return res!.isNotEmpty ? Remolque.fromMap(res.first) : null;
  }

  Future<List<Vehiculo>?> getAllVehiculos(String base) async {
    final db = await database;
    final res =
        await db?.query('Vehiculos', where: 'base = ?', whereArgs: [base]);

    return res!.isNotEmpty ? res.map((s) => Vehiculo.fromMap(s)).toList() : [];
  }

  Future<List<Remolque>?> getAllRemolques(String base) async {
    final db = await database;
    final res =
        await db?.query('Remolques', where: 'base = ?', whereArgs: [base]);

    return res!.isNotEmpty ? res.map((s) => Remolque.fromMap(s)).toList() : [];
  }

  Future<int?> nuevoItem(ItemInspeccion nuevoItem) async {
    final db = await database;

    final res = await db?.insert('ItemsInspeccion', nuevoItem.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  Future<ItemInspeccion?> getItemById(String id) async {
    final db = await database;
    final res = await db
        ?.query('ItemsInspeccion', where: 'idItem = ?', whereArgs: [id]);
    return res!.isNotEmpty ? ItemInspeccion.fromMap(res.first) : null;
  }

  Future<List<ItemInspeccion>?> getAllItems(String base) async {
    final db = await database;
    final res = await db
        ?.query('ItemsInspeccion', where: 'base = ?', whereArgs: [base]);

    return res!.isNotEmpty
        ? res.map((s) => ItemInspeccion.fromMap(s)).toList()
        : [];
  }

  Future<List<ItemsVehiculo>?> getItemsInspectionByPlaca(String placa) async {
    final db = await database;
    final res = await db?.rawQuery('''
      SELECT idCategoria, categoria, ('['|| GROUP_CONCAT( ( '{"idItem":"'|| idItem || '"'|| ',"item":"'|| item|| '"}' ) )|| ']' ) AS items FROM ItemsInspeccion WHERE placa='${placa}' GROUP BY idCategoria
    ''');
    List<Map<String, dynamic>> lsitItems = [];

    res?.forEach((categoria) {
      var json = jsonDecode(categoria['items'].toString());

      Map<String, dynamic> tempData = {
        "idCategoria": categoria['idCategoria'],
        "categoria": categoria['categoria'],
        "items": json,
      };
      lsitItems.add(tempData);
    });
    return res!.isNotEmpty
        ? lsitItems.map((s) => ItemsVehiculo.fromMap(s)).toList()
        : [];
  }

  Future<int?> nuevoInspeccion(ResumenPreoperacional nuevoInspeccion) async {
    final db = await database;
    Map<String, dynamic> resumenSave = {
      "placa": nuevoInspeccion.placa,
      "fechaPreoperacional": nuevoInspeccion.fechaPreoperacional,
      "ciudadGps": nuevoInspeccion.ciudadGps ?? nuevoInspeccion.idCiudad,
      "kilometraje": nuevoInspeccion.kilometraje,
      "cantTanqueoGalones": nuevoInspeccion.cantTanqueoGalones,
      "urlFotoKm": nuevoInspeccion.urlFotoKm,
      "usuarioPreoperacional": nuevoInspeccion.usuarioPreoperacional,
      "numeroGuia": nuevoInspeccion.numeroGuia,
      "urlFotoGuia": nuevoInspeccion.urlFotoGuia,
      "placaVehiculo": nuevoInspeccion.placaVehiculo,
      "placaRemolque": nuevoInspeccion.placaRemolque,
      "idCiudad": nuevoInspeccion.idCiudad,
      "ciudad": nuevoInspeccion.ciudad,
      "respuestas": nuevoInspeccion.respuestas,
      "base": nuevoInspeccion.base,
    };
    final res = await db?.insert('ResumenPreoperacional', resumenSave);
    return res;
  }

  Future<int?> nuevoRespuestaInspeccion(Item nuevaRespuesta) async {
    final db = await database;
    final res =
        await db?.insert('RespuestasPreoperacional', nuevaRespuesta.toMap());
    return res;
  }

  Future<int?> deleteResumenPreoperacional(int idResumen) async {
    final db = await database;
    final res = await db?.delete('ResumenPreoperacional',
        where: 'id = ?', whereArgs: [idResumen]);
    return res;
  }

  Future<int?> deleteRespuestaPreoperacional(int idResumen) async {
    final db = await database;
    final res = await db?.delete('RespuestasPreoperacional',
        where: 'fkPreoperacional = ?', whereArgs: [idResumen]);
    return res;
  }

  Future<List<ResumenPreoperacional>?> getAllInspections(
      String idUsuario, String base) async {
    final db = await database;
    final res = await db?.query('ResumenPreoperacional',
        where: 'usuarioPreoperacional = ? AND base = ?',
        whereArgs: [idUsuario, base]);

    return res!.isNotEmpty
        ? res.map((s) => ResumenPreoperacional.fromMap(s)).toList()
        : [];
  }

  Future<List<Item>?> getAllRespuestasByIdResumen(int fkPreoperacional) async {
    final db = await database;
    final res = await db?.query('RespuestasPreoperacional',
        where: 'fkPreoperacional = ?', whereArgs: [fkPreoperacional]);

    return res!.isNotEmpty ? res.map((s) => Item.fromMap(s)).toList() : [];
  }
}
