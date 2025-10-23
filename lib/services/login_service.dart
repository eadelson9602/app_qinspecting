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
  String baseUrl = 'http://192.168.1.10:3012';
  Options options = Options();

  Future<Map<dynamic, dynamic>> getToken(int user, String password) async {
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
        // Guardamos el token el el storage del dispositivo
        await storage.write(key: 'token', value: response.data['token']);
        options.headers = {"x-access-token": response.data['token']};
        print('[LOGIN] Token guardado exitosamente');
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
    String token = await storage.read(key: 'token') ?? '';
    if (idUsuario.isNotEmpty && nombreBase.isNotEmpty && token.isNotEmpty) {
      options.headers = {"x-access-token": token};

      print('🔃base: $nombreBase');
      final tempDataEmp =
          await DBProvider.db.getEmpresaById(nombreBase) as Empresa;
      selectedEmpresa = tempDataEmp;

      final tempDataUser = await DBProvider.db
          .getUser(idUsuario, tempDataEmp.password!, tempDataEmp.nombreBase!);
      userDataLogged = tempDataUser!;
      print('📁token if: $idUsuario');
    }
    print('💻token: $idUsuario');
    return idUsuario;
  }

  Future<Map<String, dynamic>> assingDataUserLogged() async {
    String idUsuario = await storage.read(key: 'usuario') ?? '';
    String nombreBase = await storage.read(key: 'nombreBase') ?? '';
    if (idUsuario.isNotEmpty && nombreBase.isNotEmpty) {
      final tempDataEmp =
          await DBProvider.db.getEmpresaById(nombreBase) as Empresa;
      selectedEmpresa = tempDataEmp;

      final tempDataUser = await DBProvider.db
          .getUser(idUsuario, tempDataEmp.password!, tempDataEmp.nombreBase!);
      userDataLogged = tempDataUser!;
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
