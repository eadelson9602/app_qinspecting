import 'dart:convert';

class Respuesta {
  Respuesta({
    required this.idFirma,
    this.fechaFirma,
    this.terminosCondiciones,
    this.firma,
    this.usuario,
  });

  int idFirma;
  String? fechaFirma;
  String? terminosCondiciones;
  String? firma;
  String? usuario;

  factory Respuesta.fromJson(String str) => Respuesta.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Respuesta.fromMap(Map<String, dynamic> json) => Respuesta(
        idFirma: json["idFirma"],
        fechaFirma: json["fechaFirma"],
        terminosCondiciones: json["terminosCondiciones"],
        firma: json["firma"],
        usuario: json["usuario"],
      );

  Map<String, dynamic> toMap() => {
        "idFirma": idFirma,
        "fechaFirma": fechaFirma,
        "terminosCondiciones": terminosCondiciones,
        "firma": firma,
        "usuario": usuario,
      };
}
