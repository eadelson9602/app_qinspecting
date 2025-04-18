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
    this.fechaPreoperacional,
    this.numeroDocumento,
    this.conductor,
    this.mlm,
    this.rutaLogo,
    this.kilometraje,
    this.urlFotoKm,
    this.urlFotoCabezote,
    this.urlFotoRemolque,
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
  List<Documento>? docConductor;
  List<Documento>? docVehiculos;
  String? fechaPreoperacional;
  String? numeroDocumento;
  String? conductor;
  String? mlm;
  String? rutaLogo;
  int? kilometraje;
  String? urlFotoKm;
  String? urlFotoCabezote;
  String? urlFotoRemolque;
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
    docConductor: List<Documento>.from(json["docConductor"].map((x) => Documento.fromMap(x))),
    docVehiculos: List<Documento>.from(json["docVehiculos"].map((x) => Documento.fromMap(x))),
    fechaPreoperacional: json["fechaPreoperacional"],
    numeroDocumento: json["numeroDocumento"],
    conductor: json["conductor"],
    mlm: json["mlm"],
    rutaLogo: json["rutaLogo"],
    kilometraje: json["kilometraje"],
    urlFotoKm: json["urlFotoKm"],
    urlFotoCabezote: json["urlFotoCabezote"],
    urlFotoRemolque: json["urlFotoRemolque"],
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
    "fechaPreoperacional": fechaPreoperacional,
    "numeroDocumento": numeroDocumento,
    "conductor": conductor,
    "mlm": mlm,
    "rutaLogo": rutaLogo,
    "kilometraje": kilometraje,
    "urlFotoKm": urlFotoKm,
    "urlFotoCabezote": urlFotoCabezote,
    "urlFotoRemolque": urlFotoRemolque,
    "detalle": List<dynamic>.from(detalle.map((x) => x.toMap())),
  };
}


class Documento {
  Documento({
    this.urlDocumento,
    required this.fkIdDocumento,
    required this.numeroRegistro,
    required this.nombreDocumento,
    this.fechaVencimiento
  });

  String?  urlDocumento;
  int  fkIdDocumento;
  String  numeroRegistro;
  String  nombreDocumento;
  String?  fechaVencimiento;

  factory Documento.fromJson(String str) => Documento.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Documento.fromMap(Map<String, dynamic> json) => Documento(
    urlDocumento: json['urlDocumento'],
    fkIdDocumento: json['fkIdDocumento'],
    numeroRegistro: json['numeroRegistro'],
    nombreDocumento: json['nombreDocumento'],
    fechaVencimiento: json['fechaVencimiento']
  );

  Map<String, dynamic> toMap() => {
    "urlDocumento": urlDocumento,
    "fkIdDocumento": fkIdDocumento,
    "numeroRegistro": numeroRegistro,
    "nombreDocumento": nombreDocumento,
    "fechaVencimiento": fechaVencimiento
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
    this.fotoConverted,
    this.fechaVencimiento
  });

  String? foto;
  Uint8List? fotoConverted;
  String? item;
  int? idItem;
  String? respuesta;
  String? observacion;
  String? fechaVencimiento;

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
      fechaVencimiento: json["fechaVencimiento"]
    );

  Map<String, dynamic> toMap() => {
    "foto": foto,
    "fotoConverted": fotoConverted,
    "item": item,
    "idItem": idItem,
    "respuesta": respuesta,
    "observacion": observacion,
    "fechaVencimiento": fechaVencimiento,
  };
}

class PdfData {
  PdfData({required this.file, required this.bytes});

  File file;
  Uint8List bytes;
}
