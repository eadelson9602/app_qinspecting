import 'dart:convert';
import 'package:app_qinspecting/providers/providers.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';

import 'package:app_qinspecting/models/models.dart';

class LoginService extends ChangeNotifier {
  var dio = Dio();
  final List<Empresa> empresas = [];
  bool isLoading = false;
  bool isSaving = false;
  // Create storage
  final storage = new FlutterSecureStorage();

  late Empresa selectedEmpresa;
  late UserData userDataLogged;

  // LoginService() {
  //   assingDataUserLogged();
  // }

  Future<List<Empresa>> login(int user, String password) async {
    final Map<String, String> loginData = {
      'user': '$user',
      'password': password
    };
    isLoading = true;
    notifyListeners();

    Response response;
    response = await dio.post('https://apis.qinspecting.com/pflutter/new_login',
        data: json.encode(loginData));
    for (var item in response.data) {
      final tempEmpresa = Empresa.fromMap(item);
      final index =
          empresas.indexWhere((element) => element.empId == tempEmpresa.empId);
      if (index == -1) empresas.add(tempEmpresa);
    }
    isLoading = false;
    notifyListeners();

    return empresas;
  }

  Future<UserData> getUserData() async {
    isLoading = true;
    notifyListeners();
    final baseEmpresa = selectedEmpresa.nombreBase;
    final usuario = selectedEmpresa.usuarioUser;

    Response response = await dio.get(
        'https://apis.qinspecting.com/pflutter/list_data_user/$baseEmpresa/$usuario');

    final tempUserData = UserData.fromJson(response.toString());

    await storage.write(
        key: 'userData', value: tempUserData.toJson().toString());

    await storage.write(
        key: 'empresaSelected', value: selectedEmpresa.toJson().toString());

    userDataLogged = tempUserData;

    DBProvider.db.nuevoUser(tempUserData);
    DBProvider.db.nuevaEmpresa(selectedEmpresa);

    isLoading = false;
    notifyListeners();

    return tempUserData;
  }

  Future logout() async {
    await storage.delete(key: 'token');
  }

  Future<String> readToken() async {
    return await storage.read(key: 'userData') ?? '';
  }

  assingDataUserLogged() async {
    String tempUserData = await storage.read(key: 'userData') ?? '';
    UserData userData = UserData.fromJson(tempUserData);
    userDataLogged = userData;

    String tempEmpresa = await storage.read(key: 'empresaSelected') ?? '';
    Empresa empresaSelected = Empresa.fromJson(tempEmpresa);
    selectedEmpresa = empresaSelected;
  }
}
