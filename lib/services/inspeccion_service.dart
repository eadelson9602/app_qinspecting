import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:app_qinspecting/models/models.dart';
import 'package:app_qinspecting/providers/providers.dart';
import 'package:overlay_support/overlay_support.dart';

class InspeccionService extends ChangeNotifier {
  var dio = Dio();
  bool isLoading = false;
  bool isSaving = false;
  int indexTabaCreateSignature = 0;
  final List<Departamentos> departamentos = [];
  final List<Ciudades> ciudades = [];
  final List<Vehiculo> vehiculos = [];
  final List<Remolque> remolques = [];
  final List<ItemInspeccion> itemsInspeccion = [];

  updateTabIndex(int value) {
    indexTabaCreateSignature = value;
    notifyListeners();
  }

  final resumePreoperacional = ResumenPreoperacional(
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
      base: '');

  Future<List<Departamentos>> getDepartamentos(Empresa empresaSelected) async {
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

  Future<List<Ciudades>> getCiudades(Empresa empresaSelected) async {
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

  Future<List<Vehiculo>> getVehiculos(Empresa empresaSelected) async {
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

  Future<List<Remolque>> getTrailers(Empresa empresaSelected) async {
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

  Future<List<ItemInspeccion>> getItemsInspeccion(
      Empresa empresaSelected) async {
    isLoading = true;
    notifyListeners();
    final baseEmpresa = empresaSelected.nombreBase;

    Response response = await dio.get(
        'https://apis.qinspecting.com/pflutter/list_items_x_placa/$baseEmpresa');
    for (var item in response.data) {
      final tempItem = ItemInspeccion.fromMap(item);
      DBProvider.db.nuevoItem(tempItem);
    }
    isLoading = false;
    notifyListeners();
    return itemsInspeccion;
  }

  Future<Respuesta> insertPreoperacional(
      ResumenPreoperacional inspeccion) async {
    isLoading = true;
    notifyListeners();
    Response response = await dio.post(
        'https://apis.qinspecting.com/pflutter/insert_preoperacional',
        data: inspeccion.toJson());
    final resp = Respuesta.fromMap(response.data);
    isLoading = false;
    notifyListeners();
    return resp;
  }

  Future<Respuesta> insertRespuestasPreoperacional(Item respuesta) async {
    isLoading = true;
    notifyListeners();
    Response response = await dio.post(
        'https://apis.qinspecting.com/pflutter/insert_respuestas_preoperacional',
        data: respuesta.toJson());
    final resp = Respuesta.fromMap(response.data);
    isLoading = false;
    notifyListeners();
    return resp;
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

  Future<Map<String, dynamic>?> uploadImage(
      {required String path,
      required String company,
      required String folder}) async {
    try {
      isLoading = true;
      notifyListeners();
      var fileName = (path.split('/').last);
      var formData = FormData.fromMap({
        'files':
            await MultipartFile.fromFile('${path}', filename: '${fileName}'),
      });
      Response response = await dio.post(
          'https://apis.qinspecting.com/pflutter/upload_file/${company}/${folder}',
          data: formData);
      final resp = ResponseUploadFile.fromMap(response.data);
      isLoading = false;
      notifyListeners();
      return resp.toMap();
    } catch (error) {
      // print('Error al subir foto ${error}');
      showSimpleNotification(Text('Error: ${error}'),
          leading: Icon(Icons.check),
          autoDismiss: true,
          background: Colors.orange,
          position: NotificationPosition.bottom);
    }
  }
}
