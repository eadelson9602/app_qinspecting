import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:app_qinspecting/models/models.dart';

class FirmaService extends ChangeNotifier {
  var dio = Dio();
  bool isLoading = false;
  int indexTabaCreateSignature = 0;
  String aceptaTerminos = 'NO';
  String baseUrl = 'https://apis.qinspecting.com/pflutter';
  Options options = Options(
    headers: {
      'x-access-token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTIzNDU2Nzg5LCJpYXQiOjE2NTI0MDg5NTcsImV4cCI6MTY1MjQ5NTM1N30.ufyCwGVWC9x6vmYusL-9GhgrabBlbM3rDuWw98wnHe0'
    }
  );

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
    Response response = await dio.post('${baseUrl}/insert_signature', options: options, data: jsonEncode(firma));
    isLoading = false;
    notifyListeners();
    return response.data;
  }

  Future<Firma?> getInfoFirma(Empresa empresaSelected) async {
    Response response = await dio.get('${baseUrl}/get_info_firma/${empresaSelected.nombreBase}/${empresaSelected.usuarioUser}', options: options);

    return response.data.toString().isNotEmpty
        ? Firma.fromMap(response.data)
        : null;
  }
}
