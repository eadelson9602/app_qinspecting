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
        CREATE TABLE ResumenPreoperacional(Id INTEGER PRIMARY KEY AUTOINCREMENT, ResuPre_Fecha TEXT, ResuPre_UbicExpPre TEXT, ResuPre_Kilometraje TEXT, tanque_galones TEXT, ResuPre_Fotokm TEXT, Pers_NumeroDoc TEXT, ResuPre_guia TEXT, ResuPre_Fotoguia TEXT, Veh_Id INTEGER, Remol_Id INTEGER, Ciu_Id INTEGER, Respuestas TEXT, base TEXT);
      ''');
      await db.execute('''
        CREATE TABLE RespuestasPreoperacional(Id INTEGER PRIMARY KEY AUTOINCREMENT, id_item INTEGER, item TEXT, respuesta TEXT, adjunto TEXT, observaciones TEXT, base TEXT, fk_preoperacional INTEGER, CONSTRAINT fk_preoperacional FOREIGN KEY (Id) REFERENCES ResumenPreoperacional(Id) ON DELETE CASCADE) ;
      ''');
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
      await db.execute('''
        CREATE TABLE Vehiculos(id_vehiculo INTEGER PRIMARY KEY, placa TEXT, id_tipo_vehiculo INTEGER, modelo INTEGER, marca TEXT, color TEXT, licencia_transito INTEGER);
      ''');
      await db.execute('''
        CREATE TABLE Remolques(id_remolque INTEGER PRIMARY KEY, placa TEXT, id_tipo_vehiculo INTEGER, modelo INTEGER, marca TEXT, color TEXT, matricula INTEGER, numero_ejes INTEGER);
      ''');
      await db.execute('''
        CREATE TABLE ItemsInspeccion(placa TEXT, tipo_vehiculo INTEGER, id_categoria INTEGER, categoria TEXT, id_item INTEGER PRIMARY KEY, item TEXT);
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

  Future<List<Empresa>?> getAllEmpresas() async {
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

  Future<List<Ciudades>?> getCiudadesByIdDepartamento(int id) async {
    final db = await database;
    final res = await db
        ?.query('Ciudades', where: 'id_departamento = ?', whereArgs: [id]);
    return res!.isNotEmpty ? res.map((s) => Ciudades.fromMap(s)).toList() : [];
  }

  Future<int?> nuevoVehiculo(Vehiculo nuevoVehiculo) async {
    final db = await database;
    final res = await db?.insert('Vehiculos', nuevoVehiculo.toMap());
    return res;
  }

  Future<int?> nuevoRemolque(Remolque nuevoRemolque) async {
    final db = await database;
    final res = await db?.insert('Remolques', nuevoRemolque.toMap());
    return res;
  }

  Future<Vehiculo?> getVehiculoById(int id) async {
    final db = await database;
    final res =
        await db?.query('Vehiculos', where: 'id_vehiculo = ?', whereArgs: [id]);
    return res!.isNotEmpty ? Vehiculo.fromMap(res.first) : null;
  }

  Future<Remolque?> getRemolqueById(int id) async {
    final db = await database;
    final res =
        await db?.query('Remolques', where: 'id_remolque = ?', whereArgs: [id]);
    return res!.isNotEmpty ? Remolque.fromMap(res.first) : null;
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

  Future<List<Vehiculo>?> getAllVehiculos() async {
    final db = await database;
    final res = await db?.query('Vehiculos');

    return res!.isNotEmpty ? res.map((s) => Vehiculo.fromMap(s)).toList() : [];
  }

  Future<List<Remolque>?> getAllRemolques() async {
    final db = await database;
    final res = await db?.query('Remolques');

    return res!.isNotEmpty ? res.map((s) => Remolque.fromMap(s)).toList() : [];
  }

  Future<int?> nuevoItem(ItemInspeccion nuevoVehiculo) async {
    final db = await database;
    final res = await db?.insert('ItemsInspeccion', nuevoVehiculo.toMap());
    return res;
  }

  Future<ItemInspeccion?> getItemById(int id) async {
    final db = await database;
    final res = await db
        ?.query('ItemsInspeccion', where: 'id_item = ?', whereArgs: [id]);
    return res!.isNotEmpty ? ItemInspeccion.fromMap(res.first) : null;
  }

  Future<List<ItemInspeccion>?> getAllItems() async {
    final db = await database;
    final res = await db?.query('ItemsInspeccion');

    return res!.isNotEmpty
        ? res.map((s) => ItemInspeccion.fromMap(s)).toList()
        : [];
  }

  Future<List<ItemsVehiculo>?> getItemsInspectionByPlaca(String placa) async {
    final db = await database;
    final res = await db?.rawQuery('''
      SELECT  id_categoria,categoria,('['|| GROUP_CONCAT( ( '{"id_item":"'|| id_item || '"'|| ',"item":"'|| item|| '"}' ) )|| ']' ) as items  from ItemsInspeccion  WHERE placa='${placa}' GROUP BY id_categoria
    ''');
    List<Map<String, dynamic>> lsitItems = [];

    res?.forEach((categoria) {
      var json = jsonDecode(categoria['items'].toString());

      Map<String, dynamic> tempData = {
        "id_categoria": categoria['id_categoria'],
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
    final res =
        await db?.insert('ResumenPreoperacional', nuevoInspeccion.toMap());
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
    final res = await db
        ?.delete('RespuestasPreoperacional', where: '', whereArgs: [idResumen]);
    return res;
  }

  Future<List<ResumenPreoperacional>?> getAllInspections() async {
    final db = await database;
    final res = await db?.query('ResumenPreoperacional');

    return res!.isNotEmpty
        ? res.map((s) => ResumenPreoperacional.fromMap(s)).toList()
        : [];
  }

  Future<List<Item>?> getAllRespuestasByIdResumen(int fk_preoperacional) async {
    final db = await database;
    final res = await db?.query('RespuestasPreoperacional',
        where: 'fk_preoperacional = ?', whereArgs: [fk_preoperacional]);

    return res!.isNotEmpty ? res.map((s) => Item.fromMap(s)).toList() : [];
  }
}
