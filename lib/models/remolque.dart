// To parse this JSON data, do
//
//     final remolques = remolquesFromMap(jsonString);

import 'dart:convert';

class Remolque {
  Remolque({
    required this.placa,
    required this.color,
    required this.nombreMarca,
    required this.modelo,
    required this.idTpVehiculo,
    this.numeroMatricula,
    required this.numeroEjes,
  });

  String placa;
  String color;
  String nombreMarca;
  int modelo;
  int idTpVehiculo;
  String? numeroMatricula;
  int numeroEjes;

  factory Remolque.fromJson(String str) => Remolque.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Remolque.fromMap(Map<String, dynamic> json) => Remolque(
    placa: json["placa"],
    color: json["color"],
    nombreMarca: json["nombreMarca"],
    modelo: json["modelo"],
    idTpVehiculo: json["idTpVehiculo"],
    numeroMatricula: json["numeroMatricula"],
    numeroEjes: json["numeroEjes"],
  );

  Map<String, dynamic> toMap() => {
    "placa": placa,
    "color": color,
    "nombreMarca": nombreMarca,
    "modelo": modelo,
    "idTpVehiculo": idTpVehiculo,
    "numeroMatricula": numeroMatricula,
    "numeroEjes": numeroEjes,
  };
}
