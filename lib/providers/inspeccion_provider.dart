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

  List<Departamentos> departamentos = [];
  List<Ciudades> ciudades = [];
  List<Vehiculo> vehiculos = [];
  List<Remolque> remolques = [];
  List<ItemsVehiculo> itemsInspeccion = [];
  File? pictureKilometraje; //Archivo que se sube al server
  File? pictureGuia; //Archivo que se sube al server
  String? pathFileKilometraje;
  String? pathFileGuia;
  String aceptaTerminos = 'NO';
  int stepStepper = 0;

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

  listarCategoriaItems() async {
    final resCategorias =
        await DBProvider.db.getItemsInspectionByPlaca(vehiculoSelected!.placa);
    itemsInspeccion = [...resCategorias!];
    notifyListeners();
  }

  saveInspecicon(ResumePreoperacional nuevoInspeccion) async {
    await DBProvider.db.nuevoInspeccion(nuevoInspeccion);
    notifyListeners();
  }
}
