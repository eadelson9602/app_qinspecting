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
  final List<Vehiculo> vehiculos = [];
  final List<Remolque> remolques = [];
  final List<ItemInspeccion> itemsInspeccion = [];

  final resumePreoperacional = ResumePreoperacional(
    resuPreFecha: '',
    resuPreUbicExpPre: '',
    resuPreKilometraje: 0,
    tanqueGalones: 0,
    resuPreFotokm: '',
    persNumeroDoc: 0,
    resuPreGuia: '',
    resuPreFotoguia: '',
    vehId: 0,
    remolId: 0,
    ciuId: 0,
    respuestas: '',
  );

  Empresa empresaSelected;

  InspeccionService(this.empresaSelected) {
    getDepartamentos();
    getCiudades();
    getVehiculos();
    getItemsInspeccion();
    getTrailers();
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

  Future<List<Vehiculo>> getVehiculos() async {
    isLoading = true;
    notifyListeners();
    final baseEmpresa = empresaSelected.nombreBase;

    Response response = await dio.get(
        'https://apis.qinspecting.com/pflutter/show_placas_cabezote/$baseEmpresa');
    for (var item in response.data) {
      final tempVehiculo = Vehiculo.fromMap(item);
      final index = vehiculos
          .indexWhere((element) => element.placa == tempVehiculo.placa);
      if (index == -1) {
        vehiculos.add(tempVehiculo);
        DBProvider.db
            .getVehiculoById(tempVehiculo.idVehiculo)
            .then((resultVehiculo) => {
                  if (resultVehiculo?.idVehiculo == null)
                    DBProvider.db.nuevoVehiculo(tempVehiculo)
                });
      }
    }
    isLoading = false;
    notifyListeners();
    return vehiculos;
  }

  Future<List<Remolque>> getTrailers() async {
    isLoading = true;
    notifyListeners();
    final baseEmpresa = empresaSelected.nombreBase;

    Response response = await dio.get(
        'https://apis.qinspecting.com/pflutter/show_placas_trailer/$baseEmpresa');
    for (var item in response.data) {
      final tempRemolque = Remolque.fromMap(item);
      final index = vehiculos
          .indexWhere((element) => element.placa == tempRemolque.placa);
      if (index == -1) {
        remolques.add(tempRemolque);
        DBProvider.db
            .getRemolqueById(tempRemolque.idRemolque)
            .then((resultVehiculo) => {
                  if (resultVehiculo?.idRemolque == null)
                    DBProvider.db.nuevoRemolque(tempRemolque)
                });
      }
    }
    isLoading = false;
    notifyListeners();
    return remolques;
  }

  Future<List<ItemInspeccion>> getItemsInspeccion() async {
    isLoading = true;
    notifyListeners();
    final baseEmpresa = empresaSelected.nombreBase;

    Response response = await dio.get(
        'https://apis.qinspecting.com/pflutter/list_items_x_placa/$baseEmpresa');
    for (var item in response.data) {
      final tempItem = ItemInspeccion.fromMap(item);
      final index = itemsInspeccion
          .indexWhere((element) => element.idItem == tempItem.idItem);
      if (index == -1) {
        itemsInspeccion.add(tempItem);
        DBProvider.db.getItemById(tempItem.idItem).then((resultVehiculo) => {
              if (resultVehiculo?.idItem == null)
                DBProvider.db.nuevoItem(tempItem)
            });
      }
    }
    isLoading = false;
    notifyListeners();
    return itemsInspeccion;
  }
}
