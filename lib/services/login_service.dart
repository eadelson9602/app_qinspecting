import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:app_qinspecting/models/models.dart';

class LoginService extends ChangeNotifier {
  final String _baseUrl = 'apis.qinspecting.com';
  final List<Empresa> empresas = [];
  bool isLoading = false;
  bool isSaving = false;

  Future<List<Empresa>> login(int user, String password) async {
    final Map<String, dynamic> loginData = {"user": user, "password": password};
    isLoading = true;
    notifyListeners();

    final url = Uri.https(_baseUrl, '/pflutter/new_login');
    final response = await http.post(url, body: json.encode(loginData));
    print(response.body);
    // final Map<String, dynamic> empresasMap = json.decode(response.body);
    // print(empresasMap);
    // empresasMap.forEach((key, value) {
    //   final tempProduct = Empresa.fromMap(value);
    //   empresas.add(tempProduct);
    // });

    isLoading = false;
    notifyListeners();

    return empresas;
  }
}
