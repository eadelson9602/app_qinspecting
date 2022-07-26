import 'dart:convert';
import 'package:app_qinspecting/providers/providers.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';

import 'package:app_qinspecting/models/models.dart';

class LoginService extends ChangeNotifier {
  var dio = Dio();
  bool isLoading = false;
  bool isSaving = false;
  PageController pageController = PageController(initialPage: 0);
  // Create storage
  final storage = new FlutterSecureStorage();

  Empresa selectedEmpresa = Empresa();
  UserData userDataLogged = UserData(urlFoto: '');

  String baseUrl = 'https://apis.qinspecting.com/pflutter';
  // String baseUrl = 'http://192.168.20.3:3012';
  Options options = Options();

  Future<Map<dynamic, dynamic>> getToken(int user, String password) async {
    try {
      isLoading = true;
      notifyListeners();

      Response response = await dio.post('${baseUrl}/get_token', options: options, data: json.encode({
        'usuario': '$user',
        'password': password
      }));
      Map<dynamic, dynamic> resGetToken = response.data;
      if(resGetToken.containsKey('token')){
        // Guardamos el token el el storage del dispositivo
        await storage.write(key: 'token', value: response.data['token']);
        options.headers = {
          "x-access-token" : response.data['token']
        };
      }
      
      return resGetToken;
    } on DioError catch (error) {
      return {
        "message": "No hemos podido obtener el token",
        "error": error.message
      };
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Empresa>> login(int user, String password) async {    
    isLoading = true;
    notifyListeners();

    final List<Empresa> empresas = [];
    Response response = await dio.post('${baseUrl}/login', options: options, data: json.encode({
      'usuario': '$user',
      'password': password
    }));
    var tempRes = response.data;
    if(tempRes.runtimeType == List<dynamic>){
      for (var item in response.data) {
        empresas.add(Empresa.fromMap(item));
      }
    }
    isLoading = false;
    notifyListeners();
    return empresas;
  }

  Future<List<Empresa>> rememberData(int user) async {    
    isLoading = true;
    notifyListeners();

    final List<Empresa> empresas = [];
    Response response = await dio.post('${baseUrl}/remember_data', data: json.encode({
      'usuario': '$user'
    }));
    var tempRes = response.data;
    if(tempRes.runtimeType == List<dynamic>){
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

    Response response = await dio.post('${baseUrl}/send_email_remember_data', data: empresa.toJson());
    
    isLoading = false;
    notifyListeners();
    return response.data;
  }

  Future<UserData> getUserData(Empresa empresa) async {
    isLoading = true;
    notifyListeners();
    final baseEmpresa = empresa.nombreBase;
    final usuario = empresa.numeroDocumento;

    Response response = await dio.get('${baseUrl}/get_user_data/$baseEmpresa/$usuario', options: options);
        
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
      options.headers = {
        "x-access-token": token
      };

      final tempDataEmp = await DBProvider.db.getEmpresaById(nombreBase) as Empresa;
      selectedEmpresa = tempDataEmp;

      final tempDataUser = await DBProvider.db.getUser(idUsuario, tempDataEmp.password!, tempDataEmp.nombreBase!);
      userDataLogged = tempDataUser;
    }
    return idUsuario;
  }

  Future<Map<String, dynamic>> assingDataUserLogged() async {
    String idUsuario = await storage.read(key: 'usuario') ?? '';
    String nombreBase = await storage.read(key: 'nombreBase') ?? '';
    if (idUsuario.isNotEmpty && nombreBase.isNotEmpty) {
      final tempDataEmp = await DBProvider.db.getEmpresaById(nombreBase) as Empresa;
      selectedEmpresa = tempDataEmp;

      final tempDataUser = await DBProvider.db.getUser(idUsuario, tempDataEmp.password!, tempDataEmp.nombreBase!);
      userDataLogged = tempDataUser;
    }

    return {"usuario": idUsuario, "nombreBase": nombreBase};
  }
}
