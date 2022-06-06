import 'dart:convert';

class Firma {
  Firma({
    required this.idFirma,
    this.fechaControl,
    this.terminosCondiciones,
    this.firma,
    this.fkNumeroDoc,
  });

  int idFirma;
  String? fechaControl;
  String? terminosCondiciones;
  String? firma;
  String? fkNumeroDoc;

  factory Firma.fromJson(String str) => Firma.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Firma.fromMap(Map<String, dynamic> json) => Firma(
        idFirma: json["idFirma"],
        fechaControl: json["fechaControl"],
        terminosCondiciones: json["terminosCondiciones"],
        firma: json["firma"],
        fkNumeroDoc: json["fkNumeroDoc"],
      );

  Map<String, dynamic> toMap() => {
        "idFirma": idFirma,
        "fechaControl": fechaControl,
        "terminosCondiciones": terminosCondiciones,
        "firma": firma,
        "fkNumeroDoc": fkNumeroDoc,
      };
}
