import 'dart:convert';

class ResumenPreoperacional {
  ResumenPreoperacional({
    this.Id,
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
    required this.base,
  });

  int? Id;
  String resuPreFecha;
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
  String base;

  factory ResumenPreoperacional.fromJson(String str) =>
      ResumenPreoperacional.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ResumenPreoperacional.fromMap(Map<String, dynamic> json) =>
      ResumenPreoperacional(
        Id: json["Id"],
        resuPreFecha: json["ResuPre_Fecha"],
        resuPreUbicExpPre: json["ResuPre_UbicExpPre"],
        resuPreKilometraje: int.parse(json["ResuPre_Kilometraje"]),
        tanqueGalones: json["tanque_galones"] == null
            ? null
            : int.parse(json["tanque_galones"]),
        resuPreFotokm:
            json["ResuPre_Fotokm"] == null ? null : json["ResuPre_Fotokm"],
        persNumeroDoc: int.parse(json["Pers_NumeroDoc"]),
        resuPreGuia: json["ResuPre_guia"] == null ? null : json["ResuPre_guia"],
        resuPreFotoguia:
            json["ResuPre_Fotoguia"] == null ? null : json["ResuPre_Fotoguia"],
        vehId: json["Veh_Id"],
        remolId: json["Remol_Id"] == null ? null : json["Remol_Id"],
        ciuId: json["Ciu_Id"],
        respuestas: json["Respuestas"],
        base: json["base"],
      );

  Map<String, dynamic> toMap() => {
        "Id": Id,
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
        "base": base
      };
}

class Respuesta {
  Respuesta({
    this.message,
    this.ok,
    this.idIsnpeccion,
  });

  String? message;
  bool? ok;
  int? idIsnpeccion;

  factory Respuesta.fromJson(String str) => Respuesta.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Respuesta.fromMap(Map<String, dynamic> json) => Respuesta(
        message: json["message"],
        ok: json["ok"],
        idIsnpeccion: json["idIsnpeccion"],
      );

  Map<String, dynamic> toMap() => {
        "message": message,
        "ok": ok,
        "idIsnpeccion": idIsnpeccion,
      };
}

class ResponseUploadFile {
  ResponseUploadFile({this.saved, this.fileName, this.path});

  bool? saved;
  String? fileName;
  String? path;

  factory ResponseUploadFile.fromJson(String str) =>
      ResponseUploadFile.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ResponseUploadFile.fromMap(Map<String, dynamic> json) =>
      ResponseUploadFile(
        saved: json["saved"],
        fileName: json["fileName"],
        path: json["path"],
      );

  Map<String, dynamic> toMap() => {
        "saved": saved,
        "fileName": fileName,
        "path": path,
      };
}
