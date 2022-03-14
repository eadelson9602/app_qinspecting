import 'dart:convert';

class Firma {
  Firma({
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
  int? usuario;

  factory Firma.fromJson(String str) => Firma.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Firma.fromMap(Map<String, dynamic> json) => Firma(
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
