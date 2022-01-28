import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'package:app_qinspecting/models/models.dart';

class LoginService extends ChangeNotifier {
  var dio = Dio();

  final String _baseUrl = 'apis.qinspecting.com';
  final List<Empresa> empresas = [];
  bool isLoading = false;
  bool isSaving = false;

  Future<List<Empresa>> login(int user, String password) async {
    final Map<String, String> loginData = {
      'user': '$user',
      'password': password
    };
    isLoading = true;
    notifyListeners();

    Response response;
    // final response = await http.post(url, body: json.encode(loginData));
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
}
