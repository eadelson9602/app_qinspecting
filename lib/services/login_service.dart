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

  // String baseUrl = 'https://apis.qinspecting.com/pflutter';
  // String baseUrl = 'https://apis.qinspecting.com/apflutterNew';
  String baseUrl = 'http://192.168.1.10:3013';

  /// Obtiene el token desde FlutterSecureStorage y lo configura en headers
  Future<void> setTokenFromStorage() async {
    try {
      // Usar la clave específica de la empresa si está disponible
      String nombreBase = await storage.read(key: 'nombreBase') ?? '';
      String tokenKey =
          nombreBase.isNotEmpty ? _getTokenKey(nombreBase) : 'token';

      String token = await storage.read(key: tokenKey) ?? '';

      // Si no hay token para la base, pero existe uno temporal, moverlo
      if (token.isEmpty && nombreBase.isNotEmpty) {
        final tempToken = await storage.read(key: 'token');
        if (tempToken != null && tempToken.isNotEmpty) {
          await storage.write(key: tokenKey, value: tempToken);
          await storage.delete(key: 'token');
          token = tempToken;
          print(
              '[SET TOKEN] 🔁 Token temporal movido a clave específica: $tokenKey');
        }
      }

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

  /// Obtiene la clave del token para una empresa específica
  String _getTokenKey(String nombreBase) {
    return 'token_$nombreBase';
  }

  Future<Map<dynamic, dynamic>> getToken(int user, String password,
      {String? nombreBase}) async {
    try {
      isLoading = true;
      notifyListeners();

      Response response = await dio.post('${baseUrl}/get_token',
          options: options,
          data: json.encode({'usuario': '$user', 'password': password}));

      print('[LOGIN] Response status: ${response.statusCode}');
      print('[LOGIN] Response data: ${response.data}');

      Map<dynamic, dynamic> resGetToken = response.data;
      if (resGetToken.containsKey('token')) {
        // Si no se pasa nombreBase, guardar en clave temporal
        // Si se pasa nombreBase, guardar en clave específica de la empresa
        String tokenKey =
            nombreBase != null ? _getTokenKey(nombreBase) : 'token';

        await storage.write(key: tokenKey, value: response.data['token']);
        dio.options.headers = {"x-access-token": response.data['token']};
        options.headers = {"x-access-token": response.data['token']};

        // Si no se pasó nombreBase pero ya hay una empresa seleccionada, mover a su clave
        if (nombreBase == null &&
            selectedEmpresa.nombreBase != null &&
            selectedEmpresa.nombreBase!.isNotEmpty) {
          final baseKey = _getTokenKey(selectedEmpresa.nombreBase!);
          await storage.write(key: baseKey, value: response.data['token']);
          await storage.delete(key: 'token');
          print(
              '[LOGIN] 🔁 Token temporal movido a clave específica: $baseKey');
        }

        // Verificar que el token se guardó correctamente
        final savedToken = await storage.read(key: tokenKey);
        print('[LOGIN] ✅ Token guardado exitosamente en secure storage');
        print('[LOGIN] ✅ Clave del token: $tokenKey');
        print('[LOGIN] ✅ Token configurado en headers (dio.options y options)');
        print(
            '[LOGIN] Token guardado: ${savedToken != null ? savedToken.substring(0, savedToken.length > 30 ? 30 : savedToken.length) + "..." : "NULL"}');
      } else {
        print('[LOGIN] ⚠️ No se recibió token en la respuesta');
      }

      return resGetToken;
    } on DioException catch (error) {
      print('[LOGIN] DioException: ${error.type}');
      print('[LOGIN] Error message: ${error.message}');
      print('[LOGIN] Error response: ${error.response?.data}');
      print('[LOGIN] Error status: ${error.response?.statusCode}');
      return {
        "message": "No hemos podido obtener el token",
        "error": error.message
      };
    } catch (e) {
      print('[LOGIN] Error inesperado: $e');
      return {"message": "Error inesperado", "error": e.toString()};
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Empresa>> login(int user, String password) async {
    isLoading = true;
    notifyListeners();

    print('[LOGIN] Iniciando login...');
    print('[LOGIN] URL: ${baseUrl}/login');
    print('[LOGIN] Usuario: $user');
    print('[LOGIN] Headers: ${options.headers}');

    final List<Empresa> empresas = [];
    try {
      Response response = await dio.post('${baseUrl}/login',
          options: options,
          data: json.encode({'usuario': '$user', 'password': password}));

      print('[LOGIN] Login response status: ${response.statusCode}');
      print('[LOGIN] Login response data: ${response.data}');

      var tempRes = response.data;
      if (tempRes.runtimeType == List<dynamic>) {
        for (var item in response.data) {
          empresas.add(Empresa.fromMap(item));
        }
      }
    } on DioException catch (error) {
      print('[LOGIN] Login DioException: ${error.type}');
      print('[LOGIN] Login Error message: ${error.message}');
      print('[LOGIN] Login Error response: ${error.response?.data}');
      print('[LOGIN] Login Error status: ${error.response?.statusCode}');
    } catch (e) {
      print('[LOGIN] Login Error inesperado: $e');
    }

    isLoading = false;
    notifyListeners();
    return empresas;
  }

  Future<List<Empresa>> rememberData(int user) async {
    isLoading = true;
    notifyListeners();

    final List<Empresa> empresas = [];
    Response response = await dio.post('${baseUrl}/remember_data',
        data: json.encode({'usuario': '$user'}));
    var tempRes = response.data;
    if (tempRes.runtimeType == List<dynamic>) {
      for (var item in response.data) {
        empresas.add(Empresa.fromMap(item));
      }
    }
    isLoading = false;
    notifyListeners();
    return empresas;
  }

  Future<Map<String, dynamic>> sendEmailRememberData(Empresa empresa) async {
    isLoading = true;
    notifyListeners();

    Response response = await dio.post('${baseUrl}/send_email_remember_data',
        data: empresa.toJson());

    isLoading = false;
    notifyListeners();
    return response.data;
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

    // Si hay un token temporal ('token'), moverlo a la clave específica de la empresa
    final tempToken = await storage.read(key: 'token');
    if (tempToken != null && tempToken.isNotEmpty) {
      String tokenKey = _getTokenKey(empresa.nombreBase!);
      await storage.write(key: tokenKey, value: tempToken);
      print(
          '[GET USER DATA] ✅ Token movido de clave temporal a clave específica: $tokenKey');
      // Eliminar el token temporal
      await storage.delete(key: 'token');
    }

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

    // Leer el token usando la clave específica de la empresa
    String tokenKey =
        nombreBase.isNotEmpty ? _getTokenKey(nombreBase) : 'token';
    String token = await storage.read(key: tokenKey) ?? '';

    // Si no hay token para la base pero existe uno temporal, moverlo
    if (token.isEmpty && nombreBase.isNotEmpty) {
      final tempToken = await storage.read(key: 'token');
      if (tempToken != null && tempToken.isNotEmpty) {
        await storage.write(key: tokenKey, value: tempToken);
        await storage.delete(key: 'token');
        token = tempToken;
        print(
            '[READ TOKEN] 🔁 Token temporal movido a clave específica: $tokenKey');
      }
    }

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
