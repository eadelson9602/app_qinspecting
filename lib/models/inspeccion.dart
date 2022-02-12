import 'dart:convert';

class ResumePreoperacional {
  ResumePreoperacional({
    required this.resuPreId,
    required this.resuPreFecha,
    required this.resuPreUbicExpPre,
    required this.resuPreKilometraje,
    this.tanqueGalones,
    this.resuPreFotokm,
    required this.persNumeroDoc,
    this.resuPreGuia,
    this.resuPreFotoguia,
    required this.vehId,
    this.remolId,
    required this.ciuId,
    required this.respuestas,
  });

  int resuPreId;
  DateTime resuPreFecha;
  String resuPreUbicExpPre;
  int resuPreKilometraje;
  int? tanqueGalones;
  String? resuPreFotokm;
  int persNumeroDoc;
  String? resuPreGuia;
  String? resuPreFotoguia;
  int vehId;
  int? remolId;
  int ciuId;
  String respuestas;

  factory ResumePreoperacional.fromJson(String str) =>
      ResumePreoperacional.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ResumePreoperacional.fromMap(Map<String, dynamic> json) =>
      ResumePreoperacional(
        resuPreId: json["ResuPre_Id"],
        resuPreFecha: DateTime.parse(json["ResuPre_Fecha"]),
        resuPreUbicExpPre: json["ResuPre_UbicExpPre"],
        resuPreKilometraje: json["ResuPre_Kilometraje"],
        tanqueGalones:
            json["tanque_galones"] == null ? null : json["tanque_galones"],
        resuPreFotokm:
            json["ResuPre_Fotokm"] == null ? null : json["ResuPre_Fotokm"],
        persNumeroDoc: json["Pers_NumeroDoc"],
        resuPreGuia: json["ResuPre_guia"] == null ? null : json["ResuPre_guia"],
        resuPreFotoguia:
            json["ResuPre_Fotoguia"] == null ? null : json["ResuPre_Fotoguia"],
        vehId: json["Veh_Id"],
        remolId: json["Remol_Id"] == null ? null : json["Remol_Id"],
        ciuId: json["Ciu_Id"],
        respuestas: json["Respuestas"],
      );

  Map<String, dynamic> toMap() => {
        "ResuPre_Id": resuPreId,
        "ResuPre_Fecha": resuPreFecha,
        "ResuPre_UbicExpPre": resuPreUbicExpPre,
        "ResuPre_Kilometraje": resuPreKilometraje,
        "tanque_galones": tanqueGalones,
        "ResuPre_Fotokm": resuPreFotokm,
        "Pers_NumeroDoc": persNumeroDoc,
        "ResuPre_guia": resuPreGuia,
        "ResuPre_Fotoguia": resuPreFotoguia,
        "Veh_Id": vehId,
        "Remol_Id": remolId,
        "Ciu_Id": ciuId,
        "Respuestas": respuestas,
      };
}
