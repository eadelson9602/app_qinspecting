import 'dart:convert';

class Vehiculo {
  Vehiculo({
    required this.idVehiculo,
    required this.placa,
    required this.idTipoVehiculo,
    required this.modelo,
    required this.marca,
    required this.color,
    this.licenciaTransito,
  });

  int idVehiculo;
  String placa;
  int idTipoVehiculo;
  int modelo;
  String marca;
  String color;
  int? licenciaTransito;

  factory Vehiculo.fromJson(String str) => Vehiculo.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Vehiculo.fromMap(Map<String, dynamic> json) => Vehiculo(
        idVehiculo: json["id_vehiculo"],
        placa: json["placa"],
        idTipoVehiculo: json["id_tipo_vehiculo"],
        modelo: json["modelo"],
        marca: json["marca"],
        color: json["color"],
        licenciaTransito: json["licencia_transito"],
      );

  Map<String, dynamic> toMap() => {
        "id_vehiculo": idVehiculo,
        "placa": placa,
        "id_tipo_vehiculo": idTipoVehiculo,
        "modelo": modelo,
        "marca": marca,
        "color": color,
        "licencia_transito": licenciaTransito,
      };
}
