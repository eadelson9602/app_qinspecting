import 'dart:convert';

class ResumenPreoperacional {
  ResumenPreoperacional({
    this.id,
    this.placa,
    this.resuPreId,
    this.fechaPreoperacional,
    this.ciudaGpsPreope,
    this.kilometrajePreope,
    this.cantTanqueoGalones,
    this.urlFotoKm,
    this.usuarioPreoperacional,
    this.guiaPreoperacional,
    this.urlFotoGuia,
    this.idVehiculoPreo,
    this.idRemolquePreo,
    this.remolquePlaca,
    this.idCiudadPreop,
    this.ciudad,
    this.base,
    this.respuestas,
  });

  int? id;
  String? placa;
  int? resuPreId;
  String? fechaPreoperacional;
  String? ciudaGpsPreope;
  int? kilometrajePreope;
  int? cantTanqueoGalones;
  String? urlFotoKm;
  String? usuarioPreoperacional;
  String? guiaPreoperacional;
  String? urlFotoGuia;
  int? idVehiculoPreo;
  int? idRemolquePreo;
  String? remolquePlaca;
  int? idCiudadPreop;
  String? ciudad;
  String? base;
  String? respuestas;

  factory ResumenPreoperacional.fromJson(String str) => ResumenPreoperacional.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ResumenPreoperacional.fromMap(Map<String, dynamic> json) =>
    ResumenPreoperacional(
      id: json["Id"],
      placa: json["placa"],
      resuPreId: json["resuPreId"],
      fechaPreoperacional: json["fechaPreoperacional"],
      ciudaGpsPreope: json["ciudaGpsPreope"],
      kilometrajePreope: json["kilometrajePreope"],
      cantTanqueoGalones: json["cantTanqueoGalones"],
      urlFotoKm: json["urlFotoKm"] == null ? null : json["urlFotoKm"],
      usuarioPreoperacional: json["usuarioPreoperacional"],
      guiaPreoperacional: json["guiaPreoperacional"],
      urlFotoGuia: json["urlFotoGuia"],
      idVehiculoPreo: json["idVehiculoPreo"],
      idRemolquePreo: json["idRemolquePreo"],
      remolquePlaca: json["remolquePlaca"],
      idCiudadPreop: json["idCiudadPreop"],
      ciudad: json["ciudad"],
      base: json["base"],
      respuestas: json["respuestas"]
    );

  Map<String, dynamic> toMap() => {
    "Id": id,
    "placa": placa,
    "resuPreId": resuPreId,
    "fechaPreoperacional": fechaPreoperacional,
    "ciudaGpsPreope": ciudaGpsPreope,
    "kilometrajePreope": kilometrajePreope,
    "cantTanqueoGalones": cantTanqueoGalones,
    "urlFotoKm": urlFotoKm == null ? null : urlFotoKm,
    "usuarioPreoperacional": usuarioPreoperacional,
    "guiaPreoperacional": guiaPreoperacional,
    "urlFotoGuia": urlFotoGuia,
    "idVehiculoPreo": idVehiculoPreo,
    "idRemolquePreo": idRemolquePreo,
    "remolquePlaca": remolquePlaca,
    "idCiudadPreop": idCiudadPreop,
    "ciudad": ciudad,
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
