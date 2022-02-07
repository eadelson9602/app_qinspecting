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
      await db.execute('''
        CREATE TABLE Vehiculos(
          Veh_Id INTEGER PRIMARY KEY, kilometraje INTEGER, aplica_remolque INTEGER, DocVeh_Id INTEGER, id_integracion INTEGER, nombre_client INTEGER, Veh_Placa TEXT, Ciu_Nombre INTEGER, Ciu_Id INTEGER, Dpt_Id INTEGER, Dpt_Nombre TEXT, Veh_Fech_Matricula TEXT, Veh_Color_Placa TEXT, Veh_LugarPlaca INTEGER, Veh_Marca TEXT, Veh_Marca_Id INTEGER, Veh_Linea TEXT, Veh_Modelo INTEGER, Veh_Cilindraje INTEGER, Veh_Color TEXT, Veh_Combustible TEXT, Veh_Motor TEXT, Veh_Serie TEXT, Veh_Estado INTEGER, State INTEGER, Prov_Id INTEGER, Tv_Id INTEGER, Prov_Nombre TEXT, Tv_descripcion TEXT, DocVeh_CltNumero TEXT, DocVeh_CltFecha TEXT, DocVeh_LicTranNumero INTEGER, DocVeh_LicTranFecha TEXT, DocVeh_SoatNumero INTEGER, DocVeh_SoatFecha TEXT, DocVeh_ReTecNumero INTEGER, DocVeh_ReTecFecha TEXT, DocVeh_PoExtraNumero TEXT, DocVeh_PoExtraFecha TEXT, DocVeh_RCHidroNumero INTEGER, DocVeh_RCHidroFecha TEXT, DocVeh_CertQRNumero INTEGER, DocVeh_CertQRFecha TEXT, Remol_Id TEXT, notaClt TEXT, DocVeh_CltFechaFin TEXT, notaLictran TEXT, DocVeh_LicTranFechaFin TEXT, notaSoat TEXT, DocVeh_SoatFechaFin TEXT, notaRetec TEXT, DocVeh_ReTecFechaFin TEXT, notaPoextra TEXT, DocVeh_PoExtraFechaFin TEXT, notaRchidro TEXT, DocVeh_RCHidroFechaFin TEXT, notaCertqr TEXT, DocVeh_CertQRFechaFin TEXT
        );
      ''');
      await db.execute('''
        CREATE TABLE ItemsInspeccion(
          id_categoria INTEGER, categoria TEXT, id_item INTEGER PRIMARY KEY, item TEXT
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

  Future<List<Ciudades>?> getCiudadesByIdDepartamento(int id) async {
    final db = await database;
    final res = await db
        ?.query('Ciudades', where: 'id_departamento = ?', whereArgs: [id]);
    return res!.isNotEmpty ? res.map((s) => Ciudades.fromMap(s)).toList() : [];
  }

  Future<int?> nuevoVehiculo(Vehiculos nuevoVehiculo) async {
    final db = await database;
    final res = await db?.insert('Vehiculos', nuevoVehiculo.toMap());
    return res;
  }

  Future<Vehiculos?> getVehiculoById(int id) async {
    final db = await database;
    final res =
        await db?.query('Vehiculos', where: 'Veh_Id = ?', whereArgs: [id]);
    return res!.isNotEmpty ? Vehiculos.fromMap(res.first) : null;
  }

  Future<Vehiculos?> getVehiculoByPlate(String placa) async {
    final db = await database;
    final res = await db
        ?.query('Vehiculos', where: 'Veh_Placa = ?', whereArgs: [placa]);
    return res!.isNotEmpty ? Vehiculos.fromMap(res.first) : null;
  }

  Future<List<Vehiculos>?> getAllVehiculos() async {
    final db = await database;
    final res = await db?.query('Vehiculos');

    return res!.isNotEmpty ? res.map((s) => Vehiculos.fromMap(s)).toList() : [];
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
}
