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
    print(
        '🔍 DEBUG clearData() llamado - tieneRemolque actual: $tieneRemolque');
    print('🔍 DEBUG Stack trace:');
    print(StackTrace.current);
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
    print(
        '🔍 DEBUG clearData() completado - tieneRemolque ahora: $tieneRemolque');
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
    print('🔍 DEBUG updateTieneRemolque - Nuevo valor: $value');
    tieneRemolque = value;
    // Si se desactiva el remolque, limpiar todos los datos relacionados
    if (!value) {
      remolqueSelected = null;
      pathFileRemolque = null;
      pictureRemolque = null;
      stepStepperRemolque = 0;
      itemsInspeccionRemolque.clear();
    }
    notifyListeners();
  }

  updateTieneGuia(bool value) {
    tieneGuia = value;
    // Si se desactiva la guía, limpiar todos los datos relacionados
    if (!value) {
      pathFileGuia = null;
      pictureGuia = null;
    }
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
    print(
        '🔍 DEBUG updateRemolqueSelected llamado con: ${remolque?.placa ?? "null"}');
    print('🔍 DEBUG tieneRemolque actual: $tieneRemolque');
    print('🔍 DEBUG Stack trace:');
    print(StackTrace.current);

    remolqueSelected = remolque;

    // Si se deselecciona el remolque, limpiar la información asociada
    if (remolque == null) {
      print(
          '🔍 DEBUG Reseteando tieneRemolque a false porque remolque es null');
      tieneRemolque = false;
      pathFileRemolque = null;
      pictureRemolque = null;
      stepStepperRemolque = 0;
      itemsInspeccionRemolque.clear();
    }

    notifyListeners();
    print(
        '🔍 DEBUG updateRemolqueSelected completado - tieneRemolque ahora: $tieneRemolque');
  }

  Future<bool> listarDataInit(String base) async {
    try {
      print('🔍 DEBUG Starting listarDataInit for base: $base');
      print('🔍 DEBUG tieneRemolque ANTES de listarDataInit: $tieneRemolque');

      // Load local data with timeout
      await _loadVehiculos(base);
      await _loadDepartamentos();

      print('🔍 DEBUG Local data loaded successfully');
      print('🔍 DEBUG tieneRemolque DESPUÉS de listarDataInit: $tieneRemolque');
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

  Future<int?> marcarResumenPreoperacionalComoEnviado(int idResumen) async {
    await DBProvider.db.marcarInspeccionComoEnviada(idResumen);
    notifyListeners();
    return 1;
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
