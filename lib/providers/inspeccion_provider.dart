import 'package:flutter/material.dart';

import 'package:app_qinspecting/models/models.dart';
import 'package:app_qinspecting/providers/providers.dart';

class InspeccionProvider extends ChangeNotifier {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool realizoTanqueo = false;
  bool tieneRemolque = false;
  bool tieneGuia = false;
  Vehiculos? vehiculoSelected;

  List<Departamentos> departamentos = [];
  List<Ciudades> ciudades = [];
  List<Vehiculos> vehiculos = [];

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

  updateVehiculoSelected(Vehiculos vehiculo) {
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
}
