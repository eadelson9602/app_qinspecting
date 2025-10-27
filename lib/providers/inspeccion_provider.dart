import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:app_qinspecting/models/models.dart';
import 'package:app_qinspecting/providers/providers.dart';

class InspeccionProvider extends ChangeNotifier {
  bool realizoTanqueo = false;
  bool tieneRemolque = false;
  bool tieneGuia = false;
  bool isSaving = false;
  Vehiculo? vehiculoSelected;
  Remolque? remolqueSelected;

  List<Departamentos> departamentos = [];
  List<Ciudades> ciudades = [];
  List<TipoDocumentos> tipoDocumentos = [];
  List<Vehiculo> vehiculos = [];
  List<Remolque> remolques = [];
  List<ItemsVehiculo> itemsInspeccion = [];
  List<ItemsVehiculo> itemsInspeccionRemolque = [];
  List<ResumenPreoperacional> allInspecciones = [];
  File? pictureKilometraje; //Archivo que se sube al server
  File? pictureCabezote; //Archivo que se sube al server
  File? pictureRemolque; //Archivo que se sube al server
  File? pictureGuia; //Archivo que se sube al server
  String? pathFileKilometraje;
  String? pathFileCabezote;
  String? pathFileRemolque;
  String? pathFileGuia;
  int stepStepper = 0;
  int stepStepperRemolque = 0;

  void clearData() {
    vehiculoSelected = null;
    remolqueSelected = null;
    pathFileKilometraje = null;
    pathFileCabezote = null;
    pathFileRemolque = null;
    stepStepperRemolque = 0;
    stepStepper = 0;
    pathFileGuia = null;
    realizoTanqueo = false;
    tieneRemolque = false;
    tieneGuia = false;
    itemsInspeccion.clear();
    itemsInspeccionRemolque.clear();
  }

  void updateSaving(bool value) {
    isSaving = value;
    notifyListeners();
  }

  void updateSelectedImage(String path) {
    pathFileKilometraje = path;
    pictureKilometraje = File.fromUri(Uri(path: path));
    notifyListeners();
  }

  void updateCabezoteImage(String path) {
    pathFileCabezote = path;
    pictureCabezote = File.fromUri(Uri(path: path));
    notifyListeners();
  }

  void updateRemolqueImage(String path) {
    pathFileRemolque = path;
    pictureRemolque = File.fromUri(Uri(path: path));
    notifyListeners();
  }

  void updateImageGuia(String path) {
    pathFileGuia = path;
    pictureGuia = File.fromUri(Uri(path: path));
    notifyListeners();
  }

  updateStep(int value) {
    stepStepper = value;
    notifyListeners();
  }

  updateStepRemolque(int value) {
    stepStepperRemolque = value;
    notifyListeners();
  }

  updateRealizoTanqueo(bool value) {
    realizoTanqueo = value;
    notifyListeners();
  }

  updateTieneRemolque(bool value) {
    tieneRemolque = value;
    notifyListeners();
  }

  updateTieneGuia(bool value) {
    tieneGuia = value;
    notifyListeners();
  }

  updateVehiculoSelected(Vehiculo? vehiculo) {
    vehiculoSelected = vehiculo;

    // Si se deselecciona el vehículo, limpiar la información asociada
    if (vehiculo == null) {
      realizoTanqueo = false;
      tieneGuia = false;
      pathFileKilometraje = null;
      pathFileCabezote = null;
      pathFileGuia = null;
      pictureKilometraje = null;
      pictureCabezote = null;
      pictureGuia = null;
      stepStepper = 0;
      itemsInspeccion.clear();
    }

    notifyListeners();
  }

  updateRemolqueSelected(Remolque? remolque) {
    remolqueSelected = remolque;

    // Si se deselecciona el remolque, limpiar la información asociada
    if (remolque == null) {
      tieneRemolque = false;
      pathFileRemolque = null;
      pictureRemolque = null;
      stepStepperRemolque = 0;
      itemsInspeccionRemolque.clear();
    }

    notifyListeners();
  }

  Future<bool> listarDataInit(String base) async {
    try {
      print('Starting listarDataInit for base: $base');

      // Load local data with timeout
      await _loadVehiculos(base);
      await _loadDepartamentos();

      print('Local data loaded successfully');
      return true;
    } catch (e) {
      print('Error in listarDataInit: $e');
      rethrow; // Re-throw the exception so FutureBuilder can catch it
    }
  }

  Future<void> _loadVehiculos(String base) async {
    vehiculos.clear();
    final resVehiculos = await DBProvider.db.getAllVehiculos(base);
    vehiculos = [...resVehiculos!];
  }

  Future<void> _loadDepartamentos() async {
    departamentos.clear();
    final resDepartamentos = await DBProvider.db.getAllDepartamentos();
    departamentos = [...resDepartamentos!];
  }

  listarDepartamentos() async {
    final resDepartamentos = await DBProvider.db.getAllDepartamentos();
    departamentos = [...resDepartamentos!];
    notifyListeners();
  }

  listarCiudades(int idDepartamento) async {
    final resCiudades =
        await DBProvider.db.getCiudadesByIdDepartamento(idDepartamento);
    ciudades = [...resCiudades!];
    notifyListeners();
  }

  listarTipoDocs() async {
    final resTipoDocs = await DBProvider.db.getAllTipoDocs();
    tipoDocumentos = [...resTipoDocs!];
    notifyListeners();
  }

  listarVehiculos(String base) async {
    final resVehiculos = await DBProvider.db.getAllVehiculos(base);
    vehiculos = [...resVehiculos!];
    notifyListeners();
  }

  listarRemolques(String base) async {
    final resRemolques = await DBProvider.db.getAllRemolques(base);
    remolques = [...resRemolques!];
    notifyListeners();
  }

  Future<List<ItemsVehiculo>> listarCategoriaItemsVehiculo(String placa) async {
    final resCategorias = await DBProvider.db.getItemsInspectionByPlaca(placa);
    itemsInspeccion = [...resCategorias!];
    notifyListeners();
    return resCategorias;
  }

  Future<List<ItemsVehiculo>> listarCategoriaItemsRemolque(String placa) async {
    final resCategorias = await DBProvider.db.getItemsInspectionByPlaca(placa);
    itemsInspeccionRemolque = [...resCategorias!];
    return resCategorias.isEmpty ? [] : resCategorias;
  }

  saveInspecicon(ResumenPreoperacional nuevoInspeccion) async {
    notifyListeners();
    final idEncabezado = await DBProvider.db.nuevoInspeccion(nuevoInspeccion);
    clearData();
    notifyListeners();
    return idEncabezado;
  }

  saveRespuestaInspeccion(Item nuevaRespuesta) async {
    notifyListeners();
    final idRespuesta =
        await DBProvider.db.nuevoRespuestaInspeccion(nuevaRespuesta);
    notifyListeners();
    return idRespuesta;
  }

  Future<List<ResumenPreoperacional>?> cargarTodosInspecciones(
      String idUsuario, String base) async {
    final inspecciones = await DBProvider.db.getAllInspections(idUsuario, base);
    return inspecciones!.isNotEmpty ? inspecciones : [];
  }

  cargarTodasRespuestas(int idResumen) async {
    final respuestas =
        await DBProvider.db.getAllRespuestasByIdResumen(idResumen);
    notifyListeners();
    return respuestas;
  }

  Future<int?> eliminarResumenPreoperacional(int idResumen) async {
    final respuestas =
        await DBProvider.db.deleteResumenPreoperacional(idResumen);
    notifyListeners();
    return respuestas;
  }

  Future<int?> eliminarRespuestaPreoperacional(int idResumen) async {
    final respuestas =
        await DBProvider.db.deleteRespuestaPreoperacional(idResumen);
    notifyListeners();
    return respuestas;
  }

  // Validación de permisos
  Future<bool> requestCameraPermission() async {
    // Solicitar permiso de cámara
    final cameraStatus = await Permission.camera.request();

    if (cameraStatus != PermissionStatus.granted) {
      return await openAppSettings();
    }

    // Solicitar permisos de almacenamiento/fotos para Android
    if (Platform.isAndroid) {
      Permission? storagePermission;

      try {
        // Intentar con Permission.photos (Android 13+)
        storagePermission = Permission.photos;
        final photosStatus = await storagePermission.request();
        if (photosStatus == PermissionStatus.granted) {
          return true;
        }
      } catch (e) {
        // Fallback para versiones anteriores
        print('⚠️ Permission.photos no disponible, usando Permission.storage');
        try {
          storagePermission = Permission.storage;
          final storageStatus = await storagePermission.request();
          if (storageStatus == PermissionStatus.granted) {
            return true;
          }
        } catch (e2) {
          print('⚠️ Permission.storage tampoco disponible');
        }
      }

      // Si los permisos de almacenamiento fueron denegados, abrir configuración
      return await openAppSettings();
    }

    return true;
  }

  Future<bool> requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();

    if (status == PermissionStatus.granted) {
      return true;
    } else {
      return await openAppSettings();
    }
  }
}
