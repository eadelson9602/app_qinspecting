import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:app_qinspecting/models/models.dart';

class InspeccionService extends ChangeNotifier {
  var dio = Dio();
  bool isLoading = false;
  bool isSaving = false;
  final List<Departamentos> departamentos = [];

  Empresa empresaSelected;

  InspeccionService(this.empresaSelected) {
    getDepartamentos();
  }

  Future<List<Departamentos>> getDepartamentos() async {
    isLoading = true;
    notifyListeners();
    final baseEmpresa = empresaSelected.nombreBase;

    Response response = await dio.get(
        'https://apis.qinspecting.com/pflutter/list_departments/$baseEmpresa');
    for (var item in response.data) {
      final tempDepartamento = Departamentos.fromMap(item);
      final index = departamentos
          .indexWhere((element) => element.value == tempDepartamento.value);
      if (index == -1) departamentos.add(tempDepartamento);
    }
    isLoading = false;
    notifyListeners();
    return departamentos;
  }
}
