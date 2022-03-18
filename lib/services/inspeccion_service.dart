import 'package:app_qinspecting/services/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:app_qinspecting/models/models.dart';
import 'package:app_qinspecting/providers/providers.dart';
import 'package:overlay_support/overlay_support.dart';

class InspeccionService extends ChangeNotifier {
  final loginService = LoginService();
  var dio = Dio();
  bool isLoading = false;
  bool isSaving = false;
  final List<Departamentos> departamentos = [];
  final List<Ciudades> ciudades = [];
  final List<Vehiculo> vehiculos = [];
  final List<Remolque> remolques = [];
  final List<ItemInspeccion> itemsInspeccion = [];

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
      base: '');

  Future<List<ResumenPreoperacional>> getLatesInspections(
      Empresa selectedEmpresa) async {
    final connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      try {
        isLoading = true;
        // notifyListeners();

        Response response = await dio.get(
            'https://apis.qinspecting.com/pflutter/get_latest_inspections/${selectedEmpresa.nombreBase}/${selectedEmpresa.usuarioUser}');
        List<ResumenPreoperacional> tempData = [];
        for (var item in response.data) {
          tempData.add(ResumenPreoperacional.fromMap(item));
        }

        isLoading = false;
        // notifyListeners();
        return tempData;
      } catch (error) {
        showSimpleNotification(
          Text('ERROR AL OBTENER INSPECCIONES: ${error.toString()}'),
          leading: Icon(Icons.wifi_tethering_error_rounded_outlined),
          autoDismiss: true,
          background: Colors.orange,
          position: NotificationPosition.bottom,
        );
        return Future.error(error.toString());
      }
    } else {
      showSimpleNotification(
        Text('Sin conexión a internet'),
        leading: Icon(Icons.wifi_tethering_error_rounded_outlined),
        autoDismiss: true,
        background: Colors.orange,
        position: NotificationPosition.bottom,
      );
      return [];
    }
  }

  Future<List<Departamentos>> getDepartamentos(Empresa empresaSelected) async {
    isLoading = true;
    notifyListeners();
    final baseEmpresa = empresaSelected.nombreBase;

    Response response = await dio.get(
        'https://apis.qinspecting.com/pflutter/list_departments/$baseEmpresa');
    departamentos.clear();
    for (var item in response.data) {
      final tempDepartamento = Departamentos.fromMap(item);
      departamentos.add(tempDepartamento);
      DBProvider.db.nuevoDepartamento(tempDepartamento);
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
    ciudades.clear();
    for (var item in response.data) {
      final tempCiudad = Ciudades.fromMap(item);
      ciudades.add(tempCiudad);
      DBProvider.db.nuevaCiudad(tempCiudad);
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
    vehiculos.clear();
    for (var item in response.data) {
      final tempVehiculo = Vehiculo.fromMap(item);
      vehiculos.add(tempVehiculo);
      DBProvider.db.nuevoVehiculo(tempVehiculo);
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
    remolques.clear();
    for (var item in response.data) {
      final tempRemolque = Remolque.fromMap(item);
      remolques.add(tempRemolque);
      DBProvider.db.nuevoRemolque(tempRemolque);
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
    itemsInspeccion.clear();
    for (var item in response.data) {
      final tempItem = ItemInspeccion.fromMap(item);
      itemsInspeccion.add(tempItem);
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

  Future<bool> getData(Empresa selectedEmpresa) async {
    try {
      final baseEmpresa = selectedEmpresa.nombreBase;
      await loginService.getUserData(selectedEmpresa);
      Response response = await dio.get(
          'https://apis.qinspecting.com/pflutter/show_placas_cabezote/$baseEmpresa');
      for (var item in response.data) {
        final tempVehiculo = Vehiculo.fromMap(item);
        DBProvider.db.nuevoVehiculo(tempVehiculo);
      }
      Response responseTrailer = await dio.get(
          'https://apis.qinspecting.com/pflutter/show_placas_trailer/$baseEmpresa');
      for (var item in responseTrailer.data) {
        final tempRemolque = Remolque.fromMap(item);
        DBProvider.db.nuevoRemolque(tempRemolque);
      }
      Response responseDepartamentos = await dio.get(
          'https://apis.qinspecting.com/pflutter/list_departments/$baseEmpresa');
      for (var item in responseDepartamentos.data) {
        final tempDepartamento = Departamentos.fromMap(item);
        DBProvider.db.nuevoDepartamento(tempDepartamento);
      }
      Response responseCiudades = await dio
          .get('https://apis.qinspecting.com/pflutter/list_city/$baseEmpresa');
      for (var item in responseCiudades.data) {
        final tempCiudad = Ciudades.fromMap(item);
        DBProvider.db.nuevaCiudad(tempCiudad);
      }
      Response responseItems = await dio.get(
          'https://apis.qinspecting.com/pflutter/list_items_x_placa/$baseEmpresa');
      for (var item in responseItems.data) {
        final tempItem = ItemInspeccion.fromMap(item);
        DBProvider.db.nuevoItem(tempItem);
      }

      return true;
    } catch (error) {
      // print('Error al subir foto ${error}');
      showSimpleNotification(Text('Error: ${error}'),
          leading: Icon(Icons.check),
          autoDismiss: true,
          background: Colors.orange,
          position: NotificationPosition.bottom);

      Future.error(error);
      return false;
    }
  }
}
