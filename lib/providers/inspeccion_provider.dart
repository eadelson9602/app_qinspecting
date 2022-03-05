import 'dart:io';
import 'package:flutter/material.dart';

import 'package:app_qinspecting/models/models.dart';
import 'package:app_qinspecting/providers/providers.dart';

class InspeccionProvider extends ChangeNotifier {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool realizoTanqueo = false;
  bool tieneRemolque = false;
  bool tieneGuia = false;
  Vehiculo? vehiculoSelected;
  Remolque? remolqueSelected;

  List<Departamentos> departamentos = [];
  List<Ciudades> ciudades = [];
  List<Vehiculo> vehiculos = [];
  List<Remolque> remolques = [];
  List<ItemsVehiculo> itemsInspeccion = [];
  List<ItemsVehiculo> itemsInspeccionRemolque = [];
  List<ResumenPreoperacional> allInspecciones = [];
  File? pictureKilometraje; //Archivo que se sube al server
  File? pictureGuia; //Archivo que se sube al server
  String? pathFileKilometraje;
  String? pathFileGuia;
  String aceptaTerminos = 'NO';
  int stepStepper = 0;
  int stepStepperRemolque = 0;

  bool isValidForm() {
    return formKey.currentState?.validate() ?? false;
  }

  void updateSelectedImage(String path) {
    pathFileKilometraje = path;
    pictureKilometraje = File.fromUri(Uri(path: path));
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

  updateTerminos(String value) {
    aceptaTerminos = value;
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

  updateVehiculoSelected(Vehiculo vehiculo) {
    vehiculoSelected = vehiculo;
    notifyListeners();
  }

  updateRemolqueSelected(Remolque remolque) {
    remolqueSelected = remolque;
    notifyListeners();
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

  listarVehiculos() async {
    final resVehiculos = await DBProvider.db.getAllVehiculos();
    vehiculos = [...resVehiculos!];
    notifyListeners();
  }

  listarRemolques() async {
    final resRemolques = await DBProvider.db.getAllRemolques();
    remolques = [...resRemolques!];
    notifyListeners();
  }

  listarCategoriaItemsVehiculo() async {
    final resCategorias =
        await DBProvider.db.getItemsInspectionByPlaca(vehiculoSelected!.placa);
    itemsInspeccion = [...resCategorias!];
    notifyListeners();
  }

  listarCategoriaItemsRemolque() async {
    final resCategorias =
        await DBProvider.db.getItemsInspectionByPlaca(remolqueSelected!.placa);
    itemsInspeccionRemolque = [...resCategorias!];
    notifyListeners();
  }

  saveInspecicon(ResumenPreoperacional nuevoInspeccion) async {
    final idEncabezado = await DBProvider.db.nuevoInspeccion(nuevoInspeccion);
    notifyListeners();
    return idEncabezado;
  }

  saveRespuestaInspeccion(Item nuevaRespuesta) async {
    final idRespuesta =
        await DBProvider.db.nuevoRespuestaInspeccion(nuevaRespuesta);
    notifyListeners();
    return idRespuesta;
  }

  cargarTodosInspecciones() async {
    final inspecciones = await DBProvider.db.getAllInspections();
    allInspecciones = [...?inspecciones];
    notifyListeners();
  }

  cargarTodasRespuestas(int idResumen) async {
    final respuestas =
        await DBProvider.db.getAllRespuestasByIdResumen(idResumen);
    notifyListeners();
    return respuestas;
  }

  eliminarResumenPreoperacional(int idResumen) async {
    final respuestas =
        await DBProvider.db.deleteResumenPreoperacional(idResumen);
    notifyListeners();
    return respuestas;
  }

  eliminarRespuestaPreoperacional(int idResumen) async {
    final respuestas =
        await DBProvider.db.deleteRespuestaPreoperacional(idResumen);
    notifyListeners();
    return respuestas;
  }
}
