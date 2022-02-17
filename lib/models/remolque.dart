// To parse this JSON data, do
//
//     final remolques = remolquesFromMap(jsonString);

import 'dart:convert';

class Remolque {
  Remolque({
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

  factory Remolque.fromJson(String str) => Remolque.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Remolque.fromMap(Map<String, dynamic> json) => Remolque(
        idRemolque: json["id_remolque"],
        placa: json["placa"],
        color: json["color"],
        marca: json["marca"],
        modelo: json["modelo"],
        idTipoVehiculo: json["id_tipo_vehiculo"],
        matricula: json["matricula"].toString(),
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
