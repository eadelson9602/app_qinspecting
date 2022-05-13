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

  late Empresa selectedEmpresa;
  late UserData userDataLogged;

  String baseUrl = 'https://apis.qinspecting.com/pflutter';
  Options options = Options(
    headers: {
      'x-access-token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTIzNDU2Nzg5LCJpYXQiOjE2NTI0MDg5NTcsImV4cCI6MTY1MjQ5NTM1N30.ufyCwGVWC9x6vmYusL-9GhgrabBlbM3rDuWw98wnHe0'
    }
  );

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

    Response response = await dio.post('${baseUrl}/send_email_remember_data', options: options, data: empresa.toJson());
    
    isLoading = false;
    notifyListeners();
    return response.data;
  }

  Future<UserData> getUserData(Empresa empresa) async {
    isLoading = true;
    notifyListeners();
    final baseEmpresa = empresa.nombreBase;
    final usuario = empresa.usuarioUser;

    Response response = await dio.get('${baseUrl}/get_user_data/$baseEmpresa/$usuario', options: options);

    final tempUserData = UserData.fromJson(response.toString());

    await storage.write(key: 'usuario', value: '${empresa.usuarioUser}');

    await storage.write(key: 'idEmpresa', value: '${empresa.empId}');

    userDataLogged = tempUserData;

    DBProvider.db.nuevoUser(tempUserData);
    DBProvider.db.nuevaEmpresa(empresa);

    isLoading = false;
    notifyListeners();

    return tempUserData;
  }

  Future logout() async {
    await storage.delete(key: 'usuario');
    await storage.delete(key: 'idEmpresa');
  }

  Future<String> readToken() async {
    final userData = await storage.read(key: 'usuario') ?? '';
    String idEmpresa = await storage.read(key: 'idEmpresa') ?? '';
    if (userData.isNotEmpty && idEmpresa.isNotEmpty) {
      final tempDataUser = await DBProvider.db.getUserById(int.parse(userData)) as UserData;
      userDataLogged = tempDataUser;

      final tempDataEmp = await DBProvider.db.getEmpresaById(int.parse(idEmpresa)) as Empresa;
      selectedEmpresa = tempDataEmp;
    }
    return userData;
  }

  Future<Map<String, dynamic>> assingDataUserLogged() async {
    String usuario = await storage.read(key: 'usuario') ?? '';
    String idEmpresa = await storage.read(key: 'idEmpresa') ?? '';
    if (usuario.isNotEmpty && idEmpresa.isNotEmpty) {
      final tempDataUser =
          await DBProvider.db.getUserById(int.parse(usuario)) as UserData;
      userDataLogged = tempDataUser;

      final tempDataEmp =
          await DBProvider.db.getEmpresaById(int.parse(idEmpresa)) as Empresa;
      selectedEmpresa = tempDataEmp;
    }

    return {"usuario": usuario, "idEmpresa": idEmpresa};
  }
}
