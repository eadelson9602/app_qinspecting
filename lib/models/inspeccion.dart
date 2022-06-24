import 'dart:convert';

class ResumenPreoperacional {
  ResumenPreoperacional({
    this.id,
    this.placa,
    this.resuPreId,
    this.fechaPreoperacional,
    this.ciudadGps,
    this.kilometraje,
    this.cantTanqueoGalones,
    this.urlFotoKm,
    this.usuarioPreoperacional,
    this.numeroGuia,
    this.urlFotoGuia,
    this.placaVehiculo,
    this.placaRemolque,
    this.idCiudad,
    this.ciudad,
    this.base,
    this.respuestas,
  });

  int? id;
  String? placa;
  int? resuPreId;
  String? fechaPreoperacional;
  String? ciudadGps;
  int? kilometraje;
  int? cantTanqueoGalones;
  String? urlFotoKm;
  String? usuarioPreoperacional;
  String? numeroGuia;
  String? urlFotoGuia;
  String? placaVehiculo;
  String? placaRemolque;
  int? idCiudad;
  String? ciudad;
  String? base;
  String? respuestas;

  factory ResumenPreoperacional.fromJson(String str) => ResumenPreoperacional.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ResumenPreoperacional.fromMap(Map<String, dynamic> json) =>
    ResumenPreoperacional(
      id: json["id"],
      placa: json["placa"],
      resuPreId: json["resuPreId"],
      fechaPreoperacional: json["fechaPreoperacional"],
      ciudadGps: json["ciudadGps"],
      kilometraje: json["kilometraje"],
      cantTanqueoGalones: json["cantTanqueoGalones"],
      urlFotoKm: json["urlFotoKm"] == null ? null : json["urlFotoKm"],
      usuarioPreoperacional: json["usuarioPreoperacional"],
      numeroGuia: json["numeroGuia"],
      urlFotoGuia: json["urlFotoGuia"],
      placaVehiculo: json["placaVehiculo"],
      placaRemolque: json["placaRemolque"],
      idCiudad: json["idCiudad"],
      ciudad: json["ciudad"],
      base: json["base"],
      respuestas: json["respuestas"]
    );

  Map<String, dynamic> toMap() => {
    "id": id,
    "placa": placa,
    "resuPreId": resuPreId,
    "fechaPreoperacional": fechaPreoperacional,
    "ciudadGps": ciudadGps,
    "kilometraje": kilometraje,
    "cantTanqueoGalones": cantTanqueoGalones,
    "urlFotoKm": urlFotoKm == null ? null : urlFotoKm,
    "usuarioPreoperacional": usuarioPreoperacional,
    "numeroGuia": numeroGuia,
    "urlFotoGuia": urlFotoGuia,
    "placaVehiculo": placaVehiculo,
    "placaRemolque": placaRemolque,
    "idCiudad": idCiudad,
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
    this.fechaPreoperacional,
    this.creado,
    this.hora,
    this.detalle,
    this.resuPreId,
    this.tanqueo,
    this.numeroGuia,
    this.grave,
    this.moderada,
    this.estado,
    this.cantFallas,
    this.nota,
  });

  String? consecutivo;
  String? fechaPreoperacional;
  String? creado;
  String? hora;
  String? detalle;
  int? resuPreId;
  String? tanqueo;
  String? numeroGuia;
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
        fechaPreoperacional: json["fechaPreoperacional"],
        creado: json["creado"],
        hora: json["hora"],
        detalle: json["detalle"],
        resuPreId: json["resuPreId"],
        tanqueo: json["tanqueo"],
        numeroGuia: json["numeroGuia"] == null ? null : json["numeroGuia"],
        grave: json["grave"],
        moderada: json["moderada"] == null ? null : json["moderada"],
        estado: json["estado"],
        cantFallas: json["cantFallas"],
        nota: json["nota"],
      );

  Map<String, dynamic> toMap() => {
        "consecutivo": consecutivo,
        "fechaPreoperacional": fechaPreoperacional,
        "creado": creado,
        "hora": hora,
        "detalle": detalle,
        "resuPreId": resuPreId,
        "tanqueo": tanqueo,
        "numeroGuia": numeroGuia == null ? null : numeroGuia,
        "grave": grave,
        "moderada": moderada == null ? null : moderada,
        "estado": estado,
        "cantFallas": cantFallas,
        "nota": nota,
      };
}
