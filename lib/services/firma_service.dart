import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:app_qinspecting/models/models.dart';

class FirmaService extends ChangeNotifier {
  var dio = Dio();
  bool isLoading = false;
  int indexTabaCreateSignature = 0;
  String aceptaTerminos = 'NO';

  updateTabIndex(int value) {
    indexTabaCreateSignature = value;
    notifyListeners();
  }

  updateTerminos(String value) {
    aceptaTerminos = value;
    notifyListeners();
  }

  Future<Map<dynamic, dynamic>> insertSignature(Map firma) async {
    isLoading = true;
    notifyListeners();
    Response response = await dio.post(
        'https://apis.qinspecting.com/pflutter/insert_signature',
        data: jsonEncode(firma));
    isLoading = false;
    notifyListeners();
    return response.data;
  }

  Future<Firma?> getInfoFirma(Empresa empresaSelected) async {
    Response response = await dio.get(
        'https://apis.qinspecting.com/pflutter/get_info_firma/${empresaSelected.nombreBase}/${empresaSelected.usuarioUser}');

    return response.data.toString().isNotEmpty
        ? Firma.fromMap(response.data)
        : null;
  }
}
