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

    // Se crea la base de datos con configuración optimizada
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        // Crear tablas primero
        await db.execute('''
          CREATE TABLE ResumenPreoperacional(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            placa TEXT, 
            fechaPreoperacional TEXT, 
            ciudadGps TEXT, 
            kilometraje NUMERIC, 
            cantTanqueoGalones NUMERIC, 
            urlFotoKm TEXT, 
            usuarioPreoperacional TEXT, 
            numeroGuia TEXT, 
            urlFotoGuia TEXT, 
            urlFotoCabezote TEXT, 
            urlFotoRemolque TEXT, 
            placaVehiculo TEXT, 
            placaRemolque TEXT, 
            idCiudad NUMERIC, 
            ciudad TEXT, 
            respuestas TEXT, 
            base TEXT
          );
        ''');

        await db.execute('''
          CREATE TABLE RespuestasPreoperacional(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            idCategoria INTEGER, 
            idItem INTEGER, 
            item TEXT, 
            respuesta TEXT, 
            adjunto TEXT, 
            observaciones TEXT, 
            base TEXT, 
            fkPreoperacional INTEGER, 
            CONSTRAINT fkPreoperacional FOREIGN KEY (fkPreoperacional) REFERENCES ResumenPreoperacional(id) ON DELETE CASCADE
          );
        ''');

        await db.execute('''
          CREATE TABLE Empresas(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            idEmpresa INTEGER, 
            nombreBase TEXT UNIQUE, 
            autCreateCap NUMERIC, 
            numeroDocumento TEXT, 
            password TEXT, 
            apellidos TEXT, 
            nombres TEXT, 
            numeroCelular TEXT, 
            email TEXT, 
            nombreCargo TEXT, 
            urlFoto TEXT, 
            idRol NUMERIC, 
            tieneFirma NUMERIC, 
            razonSocial TEXT, 
            nombreQi TEXT, 
            urlQi TEXT, 
            rutaLogo TEXT
          );
        ''');

        await db.execute('''
          CREATE TABLE personal(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            empresa TEXT UNIQUE, 
            numeroDocumento TEXT, 
            password TEXT, 
            lugarExpDocumento NUMERIC, 
            nombreCiudad TEXT, 
            fkIdDepartamento NUMERIC, 
            departamento TEXT, 
            fechaNacimiento TEXT, 
            genero TEXT, 
            rh TEXT, 
            arl TEXT, 
            eps TEXT, 
            afp TEXT, 
            numeroCelular TEXT, 
            direccion TEXT, 
            apellidos TEXT, 
            nombres TEXT, 
            email TEXT, 
            urlFoto TEXT, 
            idCargo NUMERIC, 
            nombreCargo TEXT, 
            estadoPersonal NUMERIC, 
            idTipoDocumento NUMERIC, 
            nombreTipoDocumento TEXT, 
            rolId NUMERIC, 
            rolNombre TEXT, 
            rolDescripcion TEXT, 
            idFirma NUMERIC, 
            base TEXT
          );
        ''');

        await db.execute('''
          CREATE TABLE TipoDocumentos(value INTEGER PRIMARY KEY, label TEXT);
        ''');

        await db.execute('''
          CREATE TABLE Departamentos(value INTEGER PRIMARY KEY, label TEXT);
        ''');

        await db.execute('''
          CREATE TABLE Ciudades(
            value INTEGER PRIMARY KEY, 
            label TEXT, 
            id_departamento INTEGER, 
            CONSTRAINT fk_departamento FOREIGN KEY (id_departamento) REFERENCES Departamentos(value)
          );
        ''');

        await db.execute('''
          CREATE TABLE Vehiculos(
            idVehiculo INTEGER PRIMARY KEY AUTOINCREMENT, 
            placa TEXT UNIQUE, 
            idTpVehiculo INTEGER, 
            modelo INTEGER, 
            nombreMarca TEXT, 
            color TEXT, 
            licenciaTransito TEXT, 
            base TEXT
          );
        ''');

        await db.execute('''
          CREATE TABLE Remolques(
            idRemolque INTEGER PRIMARY KEY AUTOINCREMENT, 
            placa TEXT UNIQUE, 
            idTpVehiculo INTEGER, 
            modelo INTEGER, 
            nombreMarca TEXT, 
            color TEXT, 
            numeroMatricula TEXT, 
            numeroEjes INTEGER, 
            base TEXT
          );
        ''');

        await db.execute('''
          CREATE TABLE ItemsInspeccion(
            id TEXT PRIMARY KEY, 
            placa TEXT, 
            tipoVehiculo INTEGER, 
            idCategoria INTEGER, 
            categoria TEXT, 
            idItem INTEGER, 
            item TEXT, 
            base TEXT
          );
        ''');

        // Crear índices para optimizar consultas frecuentes
        await db.execute(
            'CREATE INDEX idx_empresas_nombre_base ON Empresas(nombreBase);');
        await db.execute(
            'CREATE INDEX idx_empresas_documento_password ON Empresas(numeroDocumento, password);');

        await db.execute(
            'CREATE INDEX idx_personal_documento_password_base ON personal(numeroDocumento, password, base);');
        await db.execute('CREATE INDEX idx_personal_base ON personal(base);');

        await db.execute(
            'CREATE INDEX idx_ciudades_departamento ON Ciudades(id_departamento);');

        await db
            .execute('CREATE INDEX idx_vehiculos_placa ON Vehiculos(placa);');
        await db.execute('CREATE INDEX idx_vehiculos_base ON Vehiculos(base);');

        await db
            .execute('CREATE INDEX idx_remolques_placa ON Remolques(placa);');
        await db.execute('CREATE INDEX idx_remolques_base ON Remolques(base);');

        await db
            .execute('CREATE INDEX idx_items_placa ON ItemsInspeccion(placa);');
        await db
            .execute('CREATE INDEX idx_items_base ON ItemsInspeccion(base);');
        await db.execute(
            'CREATE INDEX idx_items_categoria ON ItemsInspeccion(idCategoria);');

        await db.execute(
            'CREATE INDEX idx_resumen_usuario_base ON ResumenPreoperacional(usuarioPreoperacional, base);');
        await db.execute(
            'CREATE INDEX idx_resumen_placa ON ResumenPreoperacional(placa);');

        await db.execute(
            'CREATE INDEX idx_respuestas_fk ON RespuestasPreoperacional(fkPreoperacional);');
      },
      onOpen: (db) async {
        // Configurar la base de datos para mejor rendimiento después de abrir
        try {
          await db.rawQuery('PRAGMA journal_mode=WAL');
          await db.rawQuery('PRAGMA synchronous=NORMAL');
          await db.rawQuery('PRAGMA cache_size=10000');
          await db.rawQuery('PRAGMA temp_store=MEMORY');
          await db.rawQuery('PRAGMA mmap_size=268435456');
          await db.rawQuery('PRAGMA page_size=4096');
          await db.rawQuery('PRAGMA auto_vacuum=INCREMENTAL');
          await db.rawQuery('PRAGMA busy_timeout=30000');
          print('✅ Database optimized successfully');
        } catch (e) {
          print('⚠️ Warning: Could not set all database optimizations: $e');
          // Continuar con configuración básica
          try {
            await db.rawQuery('PRAGMA cache_size=10000');
            await db.rawQuery('PRAGMA temp_store=MEMORY');
            await db.rawQuery('PRAGMA busy_timeout=30000');
            print('✅ Basic database optimizations applied');
          } catch (e2) {
            print('⚠️ Warning: Could not apply basic optimizations: $e2');
          }
        }
      },
    );
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
    // Usar índice idx_empresas_nombre_base
    final res = await db?.query('Empresas',
        where: 'nombreBase = ?',
        whereArgs: [base],
        limit: 1 // Optimización: limitar a 1 resultado
        );
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
    // Usar índice idx_empresas_documento_password
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

  Future<UserData?> getUser(
      String numeroDocumento, String password, String base) async {
    final db = await database;
    // Usar índice idx_personal_documento_password_base
    final res = await db?.query('personal',
        where: 'numeroDocumento = ? AND password = ? AND base = ?',
        whereArgs: [numeroDocumento, password, base],
        limit: 1 // Optimización: limitar a 1 resultado
        );
    print('$numeroDocumento, $password, $base');
    return res!.isNotEmpty ? UserData.fromMap(res.first) : null;
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
    final res = await db?.query('Departamentos',
        where: 'value = ?',
        whereArgs: [id],
        limit: 1 // Optimización: limitar a 1 resultado
        );
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
    final res = await db?.query('Ciudades',
        where: 'value = ?',
        whereArgs: [id],
        limit: 1 // Optimización: limitar a 1 resultado
        );
    return res!.isNotEmpty ? Ciudades.fromMap(res.first) : null;
  }

  Future<List<Ciudades>?> getCiudadesByIdDepartamento(int id) async {
    final db = await database;
    // Usar índice idx_ciudades_departamento
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

  // Función para limpiar la tabla Departamentos
  Future<int?> clearDepartamentos() async {
    final db = await database;
    final res = await db?.delete('Departamentos');
    return res;
  }

  // Función para limpiar la tabla Ciudades
  Future<int?> clearCiudades() async {
    final db = await database;
    final res = await db?.delete('Ciudades');
    return res;
  }

  // Función para limpiar la tabla ItemsInspeccion
  Future<int?> clearItemsInspeccion() async {
    final db = await database;
    final res = await db?.delete('ItemsInspeccion');
    return res;
  }

  // Función para limpiar la tabla TipoDocumentos
  Future<int?> clearTipoDocumentos() async {
    final db = await database;
    final res = await db?.delete('TipoDocumentos');
    return res;
  }

  // Función para limpiar todas las tablas de inspección
  Future<void> clearAllInspectionTables() async {
    final db = await database;
    if (db == null) return;

    try {
      await db.transaction((txn) async {
        await txn.delete('Vehiculos');
        await txn.delete('Remolques');
        await txn.delete('Departamentos');
        await txn.delete('Ciudades');
        await txn.delete('ItemsInspeccion');
        await txn.delete('TipoDocumentos');
      });
      print('✅ All inspection tables cleared successfully');
    } catch (e) {
      print('❌ Error clearing inspection tables: $e');
      rethrow;
    }
  }

  Future<int?> nuevoRemolque(Remolque nuevoRemolque) async {
    final db = await database;
    final res = await db?.insert('Remolques', nuevoRemolque.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  Future<Vehiculo?> getVehiculoByPlate(String placa) async {
    final db = await database;
    // Usar índice idx_vehiculos_placa
    final res = await db?.query('Vehiculos',
        where: 'placa = ?',
        whereArgs: [placa],
        limit: 1 // Optimización: limitar a 1 resultado
        );
    return res!.isNotEmpty ? Vehiculo.fromMap(res.first) : null;
  }

  Future<Remolque?> getRemolqueByPlate(String placa) async {
    final db = await database;
    // Usar índice idx_remolques_placa
    final res = await db?.query('Remolques',
        where: 'placa = ?',
        whereArgs: [placa],
        limit: 1 // Optimización: limitar a 1 resultado
        );
    return res!.isNotEmpty ? Remolque.fromMap(res.first) : null;
  }

  Future<List<Vehiculo>?> getAllVehiculos(String base) async {
    final db = await database;
    // Usar índice idx_vehiculos_base
    final res =
        await db?.query('Vehiculos', where: 'base = ?', whereArgs: [base]);

    return res!.isNotEmpty ? res.map((s) => Vehiculo.fromMap(s)).toList() : [];
  }

  Future<List<Remolque>?> getAllRemolques(String base) async {
    final db = await database;
    // Usar índice idx_remolques_base
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
    final res = await db?.query('ItemsInspeccion',
        where: 'idItem = ?',
        whereArgs: [id],
        limit: 1 // Optimización: limitar a 1 resultado
        );
    return res!.isNotEmpty ? ItemInspeccion.fromMap(res.first) : null;
  }

  Future<List<ItemInspeccion>?> getAllItems(String base) async {
    final db = await database;
    // Usar índice idx_items_base
    final res = await db
        ?.query('ItemsInspeccion', where: 'base = ?', whereArgs: [base]);

    return res!.isNotEmpty
        ? res.map((s) => ItemInspeccion.fromMap(s)).toList()
        : [];
  }

  Future<List<ItemsVehiculo>?> getItemsInspectionByPlaca(String placa) async {
    final db = await database;
    // Usar índice idx_items_placa y optimizar la consulta
    final res = await db?.rawQuery('''
      SELECT 
        idCategoria, 
        categoria, 
        ('['|| GROUP_CONCAT( ( '{"idItem":"'|| idItem || '"'|| ',"item":"'|| item|| '"}' ) )|| ']' ) AS items 
      FROM ItemsInspeccion 
      WHERE placa = ? 
      GROUP BY idCategoria
    ''', [placa]);

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
    print('urlFotoCabezote ${nuevoInspeccion.urlFotoCabezote}');
    print('urlFotoRemolque ${nuevoInspeccion.urlFotoRemolque}');

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
      "urlFotoCabezote": nuevoInspeccion.urlFotoCabezote,
      "urlFotoRemolque": nuevoInspeccion.urlFotoRemolque,
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
    // Usar índice idx_respuestas_fk
    final res = await db?.delete('RespuestasPreoperacional',
        where: 'fkPreoperacional = ?', whereArgs: [idResumen]);
    return res;
  }

  Future<List<ResumenPreoperacional>?> getAllInspections(
      String idUsuario, String base) async {
    final db = await database;
    // Usar índice idx_resumen_usuario_base
    final res = await db?.query('ResumenPreoperacional',
        where: 'usuarioPreoperacional = ? AND base = ?',
        whereArgs: [idUsuario, base]);

    return res!.isNotEmpty
        ? res.map((s) => ResumenPreoperacional.fromMap(s)).toList()
        : [];
  }

  Future<List<Item>?> getAllRespuestasByIdResumen(int fkPreoperacional) async {
    final db = await database;
    // Usar índice idx_respuestas_fk
    final res = await db?.query('RespuestasPreoperacional',
        where: 'fkPreoperacional = ?', whereArgs: [fkPreoperacional]);

    return res!.isNotEmpty ? res.map((s) => Item.fromMap(s)).toList() : [];
  }

  // Método para optimizar la base de datos
  Future<void> optimizeDatabase() async {
    final db = await database;
    if (db != null) {
      await db.rawQuery('VACUUM');
      await db.rawQuery('ANALYZE');
      await db.rawQuery('PRAGMA optimize');
      print('✅ Database optimized successfully');
    }
  }

  // Método para limpiar datos antiguos
  Future<int?> cleanOldData(int daysOld) async {
    final db = await database;
    if (db == null) return null;

    final cutoffDate =
        DateTime.now().subtract(Duration(days: daysOld)).toIso8601String();

    // Limpiar inspecciones antiguas
    final res = await db.delete('ResumenPreoperacional',
        where: 'fechaPreoperacional < ?', whereArgs: [cutoffDate]);

    print('✅ Cleaned $res old records');
    return res;
  }

  // Método para verificar el estado de la base de datos
  Future<Map<String, dynamic>> getDatabaseStats() async {
    final db = await database;
    if (db == null) return {};

    final stats = <String, dynamic>{};

    // Obtener estadísticas de cada tabla
    final tables = [
      'ResumenPreoperacional',
      'RespuestasPreoperacional',
      'Empresas',
      'personal',
      'Vehiculos',
      'Remolques',
      'ItemsInspeccion'
    ];

    for (final table in tables) {
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM $table');
      stats[table] = result.first['count'] as int;
    }

    return stats;
  }

  // Método para cerrar la conexión de la base de datos
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      print('✅ Database connection closed');
    }
  }

  // Método para ejecutar operaciones en una transacción
  Future<void> executeInTransaction(
      Future<void> Function(Transaction txn) operations) async {
    final db = await database;
    if (db == null) {
      throw Exception('Database is not available');
    }

    try {
      await db.transaction(operations);
    } catch (e) {
      print('❌ Transaction failed: $e');
      rethrow;
    }
  }

  // Método para reiniciar la conexión de la base de datos
  Future<void> resetDatabase() async {
    await closeDatabase();
    _database = await initDB();
    print('✅ Database connection reset');
  }

  // Método optimizado para inserción masiva de vehículos
  Future<void> insertVehiculosBatch(List<Vehiculo> vehiculos) async {
    final db = await database;
    if (db == null) return;

    await db.transaction((txn) async {
      for (final vehiculo in vehiculos) {
        await txn.insert('Vehiculos', vehiculo.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
    print('✅ Inserted ${vehiculos.length} vehicles in batch');
  }

  // Método optimizado para inserción masiva de remolques
  Future<void> insertRemolquesBatch(List<Remolque> remolques) async {
    final db = await database;
    if (db == null) return;

    await db.transaction((txn) async {
      for (final remolque in remolques) {
        await txn.insert('Remolques', remolque.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
    print('✅ Inserted ${remolques.length} trailers in batch');
  }

  // Método optimizado para inserción masiva de items
  Future<void> insertItemsBatch(List<ItemInspeccion> items) async {
    final db = await database;
    if (db == null) return;

    await db.transaction((txn) async {
      for (final item in items) {
        await txn.insert('ItemsInspeccion', item.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
    print('✅ Inserted ${items.length} items in batch');
  }

  // Método optimizado para inserción masiva de respuestas
  Future<void> insertRespuestasBatch(List<Item> respuestas) async {
    final db = await database;
    if (db == null) return;

    await db.transaction((txn) async {
      for (final respuesta in respuestas) {
        await txn.insert('RespuestasPreoperacional', respuesta.toMap());
      }
    });
    print('✅ Inserted ${respuestas.length} responses in batch');
  }
}
