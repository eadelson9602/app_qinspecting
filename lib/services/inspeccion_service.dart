import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:app_qinspecting/models/models.dart';
import 'package:app_qinspecting/providers/providers.dart';

class InspeccionService extends ChangeNotifier {
  var dio = Dio();
  bool isLoading = false;
  bool isSaving = false;
  final List<Departamentos> departamentos = [];
  final List<Ciudades> ciudades = [];
  final List<Vehiculos> vehiculos = [];

  Empresa empresaSelected;

  InspeccionService(this.empresaSelected) {
    getDepartamentos();
    getCiudades();
    getVehiculos();
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
      if (index == -1) {
        departamentos.add(tempDepartamento);
        DBProvider.db
            .getDepartamentoById(tempDepartamento.value)
            .then((resultFindDepartamento) => {
                  if (resultFindDepartamento?.value == null)
                    {DBProvider.db.nuevoDepartamento(tempDepartamento)}
                });
      }
      ;
    }
    isLoading = false;
    notifyListeners();
    return departamentos;
  }

  Future<List<Ciudades>> getCiudades() async {
    isLoading = true;
    notifyListeners();
    final baseEmpresa = empresaSelected.nombreBase;

    Response response = await dio
        .get('https://apis.qinspecting.com/pflutter/list_city/$baseEmpresa');
    for (var item in response.data) {
      final tempCiudad = Ciudades.fromMap(item);
      final index =
          ciudades.indexWhere((element) => element.value == tempCiudad.value);
      if (index == -1) {
        ciudades.add(tempCiudad);
        DBProvider.db
            .getCiudadById(tempCiudad.value)
            .then((resultFindCiudad) => {
                  if (resultFindCiudad?.value == null)
                    {DBProvider.db.nuevaCiudad(tempCiudad)}
                });
      }
      ;
    }
    isLoading = false;
    notifyListeners();
    return ciudades;
  }

  Future<List<Vehiculos>> getVehiculos() async {
    isLoading = true;
    notifyListeners();
    final baseEmpresa = empresaSelected.nombreBase;

    Response response = await dio.get(
        'https://apis.qinspecting.com/pflutter/show_vehicles/$baseEmpresa');
    for (var item in response.data) {
      final tempVehiculo = Vehiculos.fromMap(item);
      final index = vehiculos
          .indexWhere((element) => element.vehPlaca == tempVehiculo.vehPlaca);
      if (index == -1) {
        vehiculos.add(tempVehiculo);
        DBProvider.db.getVehiculoById(tempVehiculo.vehId!).then(
            (resultVehiculo) => {
                  if (resultVehiculo?.vehId == null)
                    DBProvider.db.nuevoVehiculo(tempVehiculo)
                });
      }
      ;
    }
    isLoading = false;
    notifyListeners();
    return vehiculos;
  }
}
