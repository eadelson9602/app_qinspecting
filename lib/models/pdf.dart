import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class Pdf {
  Pdf({
    this.codFormtPreope,
    this.nombreFormatoPreope,
    this.versionFormtPreope,
    this.auditor,
    this.tanque,
    this.numeroGuia,
    this.urlFotoGuia,
    this.firma,
    this.firmaAuditor,
    this.tvDescripcion,
    this.consecutivo,
    this.placaRemolque,
    this.placaVehiculo,
    this.docConductor,
    this.docVehiculos,
    this.resuPreFecha,
    this.numeroDocumento,
    this.conductor,
    this.mlm,
    this.rutaLogo,
    this.kilometraje,
    this.fotoKm,
    required this.detalle,
  });

  String? codFormtPreope;
  String? nombreFormatoPreope;
  String? versionFormtPreope;
  String? auditor;
  String? tanque;
  String? numeroGuia;
  String? urlFotoGuia;
  String? firma;
  String? firmaAuditor;
  String? tvDescripcion;
  String? consecutivo;
  String? placaRemolque;
  String? placaVehiculo;
  String? docConductor;
  String? docVehiculos;
  String? resuPreFecha;
  String? numeroDocumento;
  String? conductor;
  String? mlm;
  String? rutaLogo;
  int? kilometraje;
  String? fotoKm;
  List<Detalle> detalle;

  factory Pdf.fromJson(String str) => Pdf.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Pdf.fromMap(Map<String, dynamic> json) => Pdf(
    codFormtPreope: json["codFormtPreope"],
    nombreFormatoPreope: json["nombreFormatoPreope"],
    versionFormtPreope: json["versionFormtPreope"],
    auditor: json["auditor"],
    tanque: json["tanque"],
    numeroGuia: json["numeroGuia"],
    urlFotoGuia: json["urlFotoGuia"],
    firma: json["firma"],
    firmaAuditor: json["firmaAuditor"],
    tvDescripcion: json["tvDescripcion"],
    consecutivo: json["consecutivo"],
    placaRemolque: json["placaRemolque"],
    placaVehiculo: json["placaVehiculo"],
    docConductor: json["docConductor"],
    docVehiculos: json["docVehiculos"],
    resuPreFecha: json["resuPreFecha"],
    numeroDocumento: json["numeroDocumento"],
    conductor: json["conductor"],
    mlm: json["mlm"],
    rutaLogo: json["rutaLogo"],
    kilometraje: json["kilometraje"],
    fotoKm: json["fotoKm"],
    detalle: List<Detalle>.from(json["detalle"].map((x) => Detalle.fromMap(x))),
  );

  Map<String, dynamic> toMap() => {
    "codFormtPreope": codFormtPreope,
    "nombreFormatoPreope": nombreFormatoPreope,
    "versionFormtPreope": versionFormtPreope,
    "auditor": auditor,
    "tanque": tanque,
    "numeroGuia": numeroGuia,
    "urlFotoGuia": urlFotoGuia,
    "firma": firma,
    "firmaAuditor": firmaAuditor,
    "tvDescripcion": tvDescripcion,
    "consecutivo": consecutivo,
    "placaRemolque": placaRemolque,
    "placaVehiculo": placaVehiculo,
    "resuPreFecha": resuPreFecha,
    "numeroDocumento": numeroDocumento,
    "conductor": conductor,
    "mlm": mlm,
    "rutaLogo": rutaLogo,
    "kilometraje": kilometraje,
    "fotoKm": fotoKm,
    "detalle": List<dynamic>.from(detalle.map((x) => x.toMap())),
  };
}

class Detalle {
  Detalle({
    this.idCategoria,
    this.categoria,
    required this.respuestas,
  });

  int? idCategoria;
  String? categoria;
  List<RespuestaInspeccion> respuestas;

  factory Detalle.fromJson(String str) => Detalle.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Detalle.fromMap(Map<String, dynamic> json) => Detalle(
    idCategoria: json["idCategoria"],
    categoria: json["categoria"],
    respuestas: List<RespuestaInspeccion>.from(json["respuestas"].map((x) => RespuestaInspeccion.fromMap(x))),
  );

  Map<String, dynamic> toMap() => {
    "idCategoria": idCategoria,
    "categoria": categoria,
    "respuestas": List<dynamic>.from(respuestas.map((x) => x.toMap())),
  };
}

class RespuestaInspeccion {
  RespuestaInspeccion({
    this.foto,
    this.item,
    this.idItem,
    this.observacion,
    this.respuesta,
    this.fotoConverted
  });

  String? foto;
  Uint8List? fotoConverted;
  String? item;
  int? idItem;
  String? respuesta;
  String? observacion;

  factory RespuestaInspeccion.fromJson(String str) =>
      RespuestaInspeccion.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory RespuestaInspeccion.fromMap(Map<String, dynamic> json) =>
    RespuestaInspeccion(
      foto: json["foto"],
      fotoConverted: json["fotoConverted"],
      item: json["item"],
      idItem: json["idItem"],
      respuesta: json["respuesta"],
      observacion: json["observacion"],
    );

  Map<String, dynamic> toMap() => {
    "foto": foto,
    "fotoConverted": fotoConverted,
    "item": item,
    "idItem": idItem,
    "respuesta": respuesta,
    "observacion": observacion,
  };
}

class PdfData {
  PdfData({required this.file, required this.bytes});

  File file;
  Uint8List bytes;
}
