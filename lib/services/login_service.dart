import 'dart:convert';
import 'package:app_qinspecting/providers/providers.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';

import 'package:app_qinspecting/models/models.dart';

class LoginService extends ChangeNotifier {
  var dio = Dio(BaseOptions(
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
    sendTimeout: Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));
  bool isLoading = false;
  bool isSaving = false;
  PageController pageController = PageController(initialPage: 0);
  // Create storage
  final storage = new FlutterSecureStorage();

  Empresa selectedEmpresa = Empresa();
  UserData userDataLogged = UserData(urlFoto: '');

  // String baseUrl = 'https:/apis.qinspecting.com/pflutter';
  String baseUrl = 'https://apis.qinspecting.com/apflutterNew';
  // String baseUrl = 'http://192.168.1.10:3013';

  /// Obtiene el token desde FlutterSecureStorage y lo configura en headers
  Future<void> setTokenFromStorage() async {
    try {
      // Leer el usuario para construir la clave del token
      String idUsuario = await storage.read(key: 'usuario') ?? '';
      String tokenKey = 'token_$idUsuario';

      String token = await storage.read(key: tokenKey) ?? '';

      print('[SET TOKEN] ✅ Tokens: ${await storage.readAll()}');

      if (token.isNotEmpty) {
        dio.options.headers = {"x-access-token": token};
        options.headers = {"x-access-token": token};
        print(
            '[SET TOKEN] ✅ Token configurado en headers (dio.options y options) desde secure storage');
        print('[SET TOKEN] ✅ Clave usada: $tokenKey');
      } else {
        print(
            '[SET TOKEN] ⚠️ No hay token en secure storage con clave: $tokenKey');
      }
    } catch (e) {
      print('[SET TOKEN] ❌ Error al leer token: $e');
    }
  }

  Options options = Options();

  Future<Map<dynamic, dynamic>> getToken(int user, String password,
      {String? nombreBase}) async {
    try {
      isLoading = true;
      notifyListeners();

      print('[GET TOKEN] 🔍 Iniciando solicitud de token...');
      print('[GET TOKEN] 📝 Usuario: $user');
      print('[GET TOKEN] 📝 Password length: ${password.length}');
      print('[GET TOKEN] 📝 URL: ${baseUrl}/get_token');

      final requestData = {'usuario': '$user', 'password': password};
      print(
          '[GET TOKEN] 📤 Datos enviados: {usuario: "$user", password: "${password.length > 0 ? "***" : "VACÍA"}"}');

      Response response = await dio.post('${baseUrl}/get_token',
          options: options, data: json.encode(requestData));

      print('[GET TOKEN] 📥 Respuesta recibida:');
      print('[GET TOKEN]    - Status Code: ${response.statusCode}');
      print('[GET TOKEN]    - Data: ${response.data}');
      print('[GET TOKEN]    - Data type: ${response.data.runtimeType}');

      Map<dynamic, dynamic> resGetToken = response.data;

      // Verificar si la respuesta contiene un token
      if (!resGetToken.containsKey('token')) {
        print('[GET TOKEN] ❌ ERROR: La respuesta NO contiene "token"');
        print(
            '[GET TOKEN]    - Keys disponibles: ${resGetToken.keys.toList()}');
        print('[GET TOKEN]    - Respuesta completa: $resGetToken');
        return {
          "message": resGetToken['message'] ?? "No se pudo obtener el token",
          "error": resGetToken['error'] ?? "Token no encontrado en la respuesta"
        };
      }

      // Siempre usar clave específica del usuario
      String tokenKey = 'token_$user';
      String tokenValue = resGetToken['token']?.toString() ?? '';

      if (tokenValue.isEmpty) {
        print('[GET TOKEN] ❌ ERROR: El token está vacío');
        return {
          "message": "El token recibido está vacío",
          "error": "Token vacío"
        };
      }

      print('[GET TOKEN] ✅ Token recibido (longitud: ${tokenValue.length})');

      // 1. Guardar token en FlutterSecureStorage
      await storage.write(key: tokenKey, value: tokenValue);
      print('[GET TOKEN] 💾 Token guardado con clave: $tokenKey');

      // 2. Verificar inmediatamente que se guardó
      final savedToken = await storage.read(key: tokenKey);
      if (savedToken == null || savedToken.isEmpty) {
        print(
            '[GET TOKEN] ❌ ERROR: El token NO se guardó en FlutterSecureStorage');
        throw Exception('El token no se pudo guardar en FlutterSecureStorage');
      }
      print('[GET TOKEN] ✅ Token verificado en FlutterSecureStorage');

      // 3. Configurar headers
      dio.options.headers = {"x-access-token": tokenValue};
      options.headers = {"x-access-token": tokenValue};
      print('[GET TOKEN] ✅ Headers configurados con el token');

      return resGetToken;
    } on DioException catch (error) {
      print('[GET TOKEN] ❌ DioException capturada:');
      print('[GET TOKEN]    - Type: ${error.type}');
      print('[GET TOKEN]    - Message: ${error.message}');
      print('[GET TOKEN]    - Response: ${error.response?.data}');
      print('[GET TOKEN]    - Status Code: ${error.response?.statusCode}');

      String errorMessage = "No hemos podido obtener el token";
      if (error.response?.statusCode == 401 ||
          error.response?.statusCode == 403) {
        errorMessage = "Usuario o contraseña incorrectos";
      } else if (error.response?.data != null && error.response!.data is Map) {
        errorMessage = error.response!.data['message'] ?? errorMessage;
      }

      return {
        "message": errorMessage,
        "error": error.message ?? "Error desconocido",
        "statusCode": error.response?.statusCode
      };
    } catch (e, stackTrace) {
      print('[GET TOKEN] ❌ Error inesperado: $e');
      print('[GET TOKEN]    - Stack trace: $stackTrace');
      return {"message": "Error inesperado", "error": e.toString()};
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Empresa>> login(int user, String password) async {
    isLoading = true;
    notifyListeners();

    final List<Empresa> empresas = [];
    try {
      print('[LOGIN] 🔍 Iniciando solicitud de login...');
      print('[LOGIN] 📝 Usuario: $user');
      print('[LOGIN] 📝 Password length: ${password.length}');
      print('[LOGIN] 📝 URL: ${baseUrl}/login');
      print('[LOGIN] 📝 Headers actuales: ${dio.options.headers}');

      final requestData = {'usuario': '$user', 'password': password};
      print(
          '[LOGIN] 📤 Datos enviados: {usuario: "$user", password: "${password.length > 0 ? "***" : "VACÍA"}"}');

      Response response = await dio.post('${baseUrl}/login',
          options: options, data: json.encode(requestData));

      print('[LOGIN] 📥 Respuesta recibida:');
      print('[LOGIN]    - Status Code: ${response.statusCode}');
      print('[LOGIN]    - Data type: ${response.data.runtimeType}');
      print('[LOGIN]    - Data: ${response.data}');

      var tempRes = response.data;
      if (tempRes.runtimeType == List<dynamic>) {
        print(
            '[LOGIN] ✅ Respuesta es una lista con ${(response.data as List).length} elementos');
        for (var item in response.data) {
          try {
            empresas.add(Empresa.fromMap(item));
            print(
                '[LOGIN] ✅ Empresa agregada: ${item['nombreQi'] ?? 'Sin nombre'}');
          } catch (e) {
            print('[LOGIN] ⚠️ Error al parsear empresa: $e');
            print('[LOGIN]    - Item: $item');
          }
        }
        print('[LOGIN] ✅ Total empresas procesadas: ${empresas.length}');
      } else {
        print('[LOGIN] ⚠️ La respuesta NO es una lista');
        print('[LOGIN]    - Tipo recibido: ${tempRes.runtimeType}');
        print('[LOGIN]    - Contenido: $tempRes');
      }
    } on DioException catch (error) {
      print('[LOGIN] ❌ DioException capturada:');
      print('[LOGIN]    - Type: ${error.type}');
      print('[LOGIN]    - Message: ${error.message}');
      print('[LOGIN]    - Response: ${error.response?.data}');
      print('[LOGIN]    - Status Code: ${error.response?.statusCode}');

      if (error.response?.statusCode == 401 ||
          error.response?.statusCode == 403) {
        print('[LOGIN] ❌ Error de autenticación: Credenciales inválidas');
      }
    } catch (e, stackTrace) {
      print('[LOGIN] ❌ Error inesperado: $e');
      print('[LOGIN]    - Stack trace: $stackTrace');
    }

    isLoading = false;
    notifyListeners();
    return empresas;
  }

  Future<Map<String, dynamic>> rememberData(int user) async {
    try {
      isLoading = true;
      notifyListeners();

      Response response = await dio.post('${baseUrl}/remember_data',
          options: options, data: json.encode({'usuario': '$user'}));

      // El backend ahora realiza el envío del correo y retorna estado
      return Map<String, dynamic>.from(response.data is Map
          ? response.data
          : {"message": "Operación realizada"});
    } on DioException catch (error) {
      return {
        "message": "No hemos podido procesar la solicitud",
        "error": error.message
      };
    } catch (e) {
      return {"message": "Error inesperado", "error": e.toString()};
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> sendEmailRememberData(Empresa empresa) async {
    // Wrapper de compatibilidad: delega a rememberData
    final numeroDoc = int.tryParse('${empresa.numeroDocumento}') ?? 0;
    return await rememberData(numeroDoc);
  }

  Future<UserData> getUserData(Empresa empresa) async {
    isLoading = true;
    notifyListeners();
    final baseEmpresa = empresa.nombreBase;
    final usuario = empresa.numeroDocumento;

    Response response = await dio.get(
        '${baseUrl}/get_user_data/$baseEmpresa/$usuario',
        options: options);

    final tempUserData = UserData.fromJson(response.toString());

    await storage.write(key: 'usuario', value: '${empresa.numeroDocumento}');
    await storage.write(key: 'nombreBase', value: '${empresa.nombreBase}');

    // Verificar que los datos se guardaron correctamente
    final savedUsuario = await storage.read(key: 'usuario');
    final savedNombreBase = await storage.read(key: 'nombreBase');
    print('[GET USER DATA] ✅ Datos guardados:');
    print('   - Usuario: $savedUsuario');
    print('   - Nombre Base: $savedNombreBase');

    // Asegurar headers actualizados desde storage
    await setTokenFromStorage();

    userDataLogged = tempUserData;

    tempUserData.empresa = empresa.nombreQi;

    DBProvider.db.nuevoUser(tempUserData);
    DBProvider.db.nuevaEmpresa(empresa);

    isLoading = false;
    notifyListeners();

    return tempUserData;
  }

  Future<bool> logout() async {
    await storage.deleteAll();
    return true;
  }

  Future<String> readToken() async {
    // await storage.deleteAll();
    String idUsuario = await storage.read(key: 'usuario') ?? '';
    String nombreBase = await storage.read(key: 'nombreBase') ?? '';

    // Leer el token usando la clave específica del usuario
    String tokenKey = 'token_$idUsuario';
    String token = await storage.read(key: tokenKey) ?? '';

    print('🔍 [READ TOKEN] Verificando datos en storage:');
    print(
        '   - Usuario: ${idUsuario.isEmpty ? "VACÍO" : idUsuario.substring(0, idUsuario.length > 10 ? 10 : idUsuario.length) + "..."}');
    print('   - Base: ${nombreBase.isEmpty ? "VACÍO" : nombreBase}');
    print('   - Token Key: $tokenKey');
    print(
        '   - Token: ${token.isEmpty ? "VACÍO" : token.substring(0, token.length > 20 ? 20 : token.length) + "..."}');

    // Cargar datos desde SQLite si hay usuario y base (funciona con o sin token)
    if (idUsuario.isNotEmpty && nombreBase.isNotEmpty) {
      try {
        // Configurar headers solo si hay token
        if (token.isNotEmpty) {
          dio.options.headers = {"x-access-token": token};
          options.headers = {"x-access-token": token};
          print(
              '✅ [READ TOKEN] Token configurado en headers (dio.options y options)');
        } else {
          print('⚠️ [READ TOKEN] Modo offline (sin token)');
        }

        print('🔃 [READ TOKEN] Cargando datos de SQLite...');
        print('   - Base: $nombreBase');
        final tempDataEmp = await DBProvider.db.getEmpresaById(nombreBase);

        if (tempDataEmp == null || tempDataEmp.nombreBase == null) {
          print('❌ [READ TOKEN] Error: No se encontró empresa en SQLite');
          print(
              '⚠️ [READ TOKEN] Datos incompletos en storage, redirigiendo a login');
          return '';
        }

        selectedEmpresa = tempDataEmp;

        print('📊 [READ TOKEN] Empresa cargada y asignada:');
        print('   - nombreBase: ${selectedEmpresa.nombreBase}');
        print('   - numeroDocumento: ${selectedEmpresa.numeroDocumento}');
        print('   - nombreQi: ${selectedEmpresa.nombreQi}');
        print('   - idEmpresa: ${selectedEmpresa.idEmpresa}');

        final tempDataUser = await DBProvider.db
            .getUserByDocumentoAndBase(idUsuario, tempDataEmp.nombreBase!);

        if (tempDataUser == null) {
          print('❌ [READ TOKEN] Error: No se encontró usuario en SQLite');
          print(
              '⚠️ [READ TOKEN] Datos incompletos en storage, redirigiendo a login');
          return '';
        }

        userDataLogged = tempDataUser;
        print('✅ [READ TOKEN] Datos cargados correctamente');
        print(
            '   - Usuario numeroDocumento: ${userDataLogged.numeroDocumento}');

        // Verificar nuevamente selectedEmpresa después de asignar
        print('🔍 [READ TOKEN] Verificación final de selectedEmpresa:');
        print('   - nombreBase: ${selectedEmpresa.nombreBase}');
        print('   - numeroDocumento: ${selectedEmpresa.numeroDocumento}');
      } catch (e) {
        print('❌ [READ TOKEN] Error al cargar datos: $e');
        print(
            '⚠️ [READ TOKEN] Datos incompletos en storage, redirigiendo a login');
        return '';
      }
    } else {
      print(
          '⚠️ [READ TOKEN] Datos incompletos en storage, redirigiendo a login');
      return '';
    }
    print(
        '💻 [READ TOKEN] Retornando: ${idUsuario.isEmpty ? "vacío" : idUsuario}');
    return idUsuario;
  }

  Future<Map<String, dynamic>> assingDataUserLogged() async {
    String idUsuario = await storage.read(key: 'usuario') ?? '';
    String nombreBase = await storage.read(key: 'nombreBase') ?? '';

    print('[ASSING DATA] Verificando datos:');
    print('   - Usuario: $idUsuario');
    print('   - Base: $nombreBase');

    if (idUsuario.isNotEmpty && nombreBase.isNotEmpty) {
      final tempDataEmp = await DBProvider.db.getEmpresaById(nombreBase);

      if (tempDataEmp == null) {
        print('❌ [ASSING DATA] No se encontró empresa en SQLite');
        return {"usuario": idUsuario, "nombreBase": nombreBase};
      }

      if (tempDataEmp.nombreBase == null || tempDataEmp.nombreBase!.isEmpty) {
        print('❌ [ASSING DATA] La empresa cargada no tiene nombreBase válido');
        return {"usuario": idUsuario, "nombreBase": nombreBase};
      }

      selectedEmpresa = tempDataEmp;
      print('✅ [ASSING DATA] Empresa asignada:');
      print('   - nombreBase: ${selectedEmpresa.nombreBase}');
      print('   - numeroDocumento: ${selectedEmpresa.numeroDocumento}');

      final tempDataUser = await DBProvider.db
          .getUser(idUsuario, tempDataEmp.password!, tempDataEmp.nombreBase!);

      if (tempDataUser == null) {
        print('❌ [ASSING DATA] No se encontró usuario en SQLite');
      } else {
        userDataLogged = tempDataUser;
        print('✅ [ASSING DATA] Usuario asignado correctamente');
      }
    }

    return {"usuario": idUsuario, "nombreBase": nombreBase};
  }

  Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> userData) async {
    // Verificar que el token esté presente
    if (options.headers == null ||
        !options.headers!.containsKey('x-access-token')) {
      print('[UPDATE PROFILE] ERROR: No se encontró token de autenticación');
      return {
        "message": "Error de autenticación",
        "error":
            "Token de autenticación no encontrado. Por favor, inicia sesión nuevamente."
      };
    }

    try {
      isLoading = true;
      notifyListeners();
      Response response = await dio.put('${baseUrl}/update_profile',
          options: options, data: userData);

      // Si la actualización fue exitosa, refrescar los datos del usuario
      if (response.statusCode == 200) {
        print(
            '[UPDATE PROFILE] Actualización exitosa, refrescando datos del usuario...');
        await _refreshUserData();
      }

      return response.data;
    } on DioException catch (error) {
      if (error.response?.statusCode == 403) {
        return {
          "message": "Error de autorización. Token inválido o expirado.",
          "error": "Token de autenticación requerido"
        };
      }

      return {
        "message": "Error al actualizar perfil",
        "error": error.message ?? "Error desconocido"
      };
    } catch (e) {
      print('[UPDATE PROFILE] Error inesperado: $e');
      return {"message": "Error inesperado", "error": e.toString()};
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Refresca los datos del usuario desde el servidor después de una actualización
  Future<void> _refreshUserData() async {
    try {
      // Obtener datos actualizados del servidor directamente
      final baseEmpresa = selectedEmpresa.nombreBase;
      final usuario = selectedEmpresa.numeroDocumento;

      Response response = await dio.get(
          '${baseUrl}/get_user_data/$baseEmpresa/$usuario',
          options: options);

      final tempUserData = UserData.fromJson(response.toString());
      tempUserData.empresa = selectedEmpresa.nombreQi;

      // Actualizar en SQLite usando updateUser en lugar de nuevoUser
      await DBProvider.db.updateUser(tempUserData);

      // Actualizar datos en memoria
      userDataLogged = tempUserData;
      notifyListeners();
    } catch (e) {
      print('[REFRESH USER DATA] Error al refrescar datos: $e');
      // No lanzamos el error para no interrumpir el flujo de actualización
    }
  }
}
