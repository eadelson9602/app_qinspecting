// To parse this JSON data, do
//
//     final remolques = remolquesFromMap(jsonString);

import 'dart:convert';

class Remolques {
  Remolques({
    required this.idRemolque,
    required this.placa,
    required this.color,
    required this.marca,
    required this.modelo,
    required this.idTipoVehiculo,
    this.matricula,
    required this.numeroEjes,
  });

  int idRemolque;
  String placa;
  String color;
  String marca;
  int modelo;
  int idTipoVehiculo;
  String? matricula;
  int numeroEjes;

  factory Remolques.fromJson(String str) => Remolques.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Remolques.fromMap(Map<String, dynamic> json) => Remolques(
        idRemolque: json["id_remolque"],
        placa: json["placa"],
        color: json["color"],
        marca: json["marca"],
        modelo: json["modelo"],
        idTipoVehiculo: json["id_tipo_vehiculo"],
        matricula: json["matricula"],
        numeroEjes: json["numero_ejes"],
      );

  Map<String, dynamic> toMap() => {
        "id_remolque": idRemolque,
        "placa": placa,
        "color": color,
        "marca": marca,
        "modelo": modelo,
        "id_tipo_vehiculo": idTipoVehiculo,
        "matricula": matricula,
        "numero_ejes": numeroEjes,
      };
}
