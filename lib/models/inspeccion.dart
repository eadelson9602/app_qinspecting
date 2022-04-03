import 'dart:convert';

class ResumenPreoperacional {
  ResumenPreoperacional({
    this.id,
    this.resuPreId,
    this.resuPreFecha,
    this.resuPreUbicExpPre,
    this.resuPreKilometraje,
    this.tanqueGalones,
    this.resuPreFotokm,
    this.persNumeroDoc,
    this.resuPreGuia,
    this.resuPreFotoguia,
    this.vehId,
    this.remolId,
    this.ciuId,
    this.base,
    this.respuestas,
  });

  int? id;
  int? resuPreId;
  String? resuPreFecha;
  String? resuPreUbicExpPre;
  int? resuPreKilometraje;
  int? tanqueGalones;
  String? resuPreFotokm;
  int? persNumeroDoc;
  String? resuPreGuia;
  String? resuPreFotoguia;
  int? vehId;
  int? remolId;
  int? ciuId;
  String? base;
  String? respuestas;

  factory ResumenPreoperacional.fromJson(String str) =>
      ResumenPreoperacional.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ResumenPreoperacional.fromMap(Map<String, dynamic> json) =>
      ResumenPreoperacional(
          id: json["Id"],
          resuPreId: json["ResuPre_Id"],
          resuPreFecha: json["ResuPre_Fecha"],
          resuPreUbicExpPre: json["ResuPre_UbicExpPre"],
          resuPreKilometraje: json["ResuPre_Kilometraje"],
          tanqueGalones: json["tanque_galones"],
          resuPreFotokm:
              json["ResuPre_Fotokm"] == null ? null : json["ResuPre_Fotokm"],
          persNumeroDoc: json["Pers_NumeroDoc"],
          resuPreGuia: json["ResuPre_guia"],
          resuPreFotoguia: json["ResuPre_Fotoguia"],
          vehId: json["Veh_Id"],
          remolId: json["Remol_Id"],
          ciuId: json["Ciu_Id"],
          base: json["base"],
          respuestas: json["respuestas"]);

  Map<String, dynamic> toMap() => {
        "Id": id,
        "ResuPre_Id": resuPreId,
        "ResuPre_Fecha": resuPreFecha,
        "ResuPre_UbicExpPre": resuPreUbicExpPre,
        "ResuPre_Kilometraje": resuPreKilometraje,
        "tanque_galones": tanqueGalones,
        "ResuPre_Fotokm": resuPreFotokm == null ? null : resuPreFotokm,
        "Pers_NumeroDoc": persNumeroDoc,
        "ResuPre_guia": resuPreGuia,
        "ResuPre_Fotoguia": resuPreFotoguia,
        "Veh_Id": vehId,
        "Remol_Id": remolId,
        "Ciu_Id": ciuId,
        "base": base,
        "respuestas": respuestas
      };
}

class Respuesta {
  Respuesta({
    this.message,
    this.ok,
    this.idInspeccion,
  });

  String? message;
  bool? ok;
  int? idInspeccion;

  factory Respuesta.fromJson(String str) => Respuesta.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Respuesta.fromMap(Map<String, dynamic> json) => Respuesta(
        message: json["message"],
        ok: json["ok"],
        idInspeccion: json["idInspeccion"],
      );

  Map<String, dynamic> toMap() => {
        "message": message,
        "ok": ok,
        "idInspeccion": idInspeccion,
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

// Esta clase se usara para mostrar las cards del escritorio
class ResumenPreoperacionalServer {
  ResumenPreoperacionalServer({
    this.consecutivo,
    this.resuPreFecha,
    this.creado,
    this.hora,
    this.detalle,
    this.resuPreId,
    this.tanqueo,
    this.resuPreGuia,
    this.grave,
    this.moderada,
    this.estado,
    this.cantFallas,
    this.nota,
  });

  String? consecutivo;
  String? resuPreFecha;
  String? creado;
  String? hora;
  String? detalle;
  int? resuPreId;
  String? tanqueo;
  String? resuPreGuia;
  int? grave;
  int? moderada;
  String? estado;
  String? cantFallas;
  String? nota;

  factory ResumenPreoperacionalServer.fromJson(String str) =>
      ResumenPreoperacionalServer.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ResumenPreoperacionalServer.fromMap(Map<String, dynamic> json) =>
      ResumenPreoperacionalServer(
        consecutivo: json["consecutivo"],
        resuPreFecha: json["resuPreFecha"],
        creado: json["creado"],
        hora: json["hora"],
        detalle: json["detalle"],
        resuPreId: json["resuPreId"],
        tanqueo: json["tanqueo"],
        resuPreGuia: json["resuPreGuia"] == null ? null : json["resuPreGuia"],
        grave: json["grave"],
        moderada: json["moderada"] == null ? null : json["moderada"],
        estado: json["estado"],
        cantFallas: json["cantFallas"],
        nota: json["nota"],
      );

  Map<String, dynamic> toMap() => {
        "consecutivo": consecutivo,
        "resuPreFecha": resuPreFecha,
        "creado": creado,
        "hora": hora,
        "detalle": detalle,
        "resuPreId": resuPreId,
        "tanqueo": tanqueo,
        "resuPreGuia": resuPreGuia == null ? null : resuPreGuia,
        "grave": grave,
        "moderada": moderada == null ? null : moderada,
        "estado": estado,
        "cantFallas": cantFallas,
        "nota": nota,
      };
}
