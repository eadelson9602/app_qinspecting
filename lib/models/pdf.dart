import 'dart:convert';
import 'dart:typed_data';

class Pdf {
  Pdf({
    this.codFormtPreope,
    this.nombreFormatoPreope,
    this.versionFormtPreope,
    this.auditor,
    this.tanque,
    this.fechaVencCurManDef,
    this.fechaVencCurMercPel,
    this.docCondFvss,
    this.fechaVencLicCond,
    this.fechaFinQr,
    this.fechaFinPoExtra,
    this.rcHidroFechaFin,
    this.fechaFinTAforo,
    this.fechaFinCertLinea,
    this.resuPreGuia,
    this.resuPreFotoguia,
    this.firma,
    this.tvDescripcion,
    this.consecutivo,
    this.remolPlaca,
    this.vehPlaca,
    this.resuPreFecha,
    this.cc,
    this.conductor,
    this.mlm,
    this.rutaLogo,
    this.catLiceCond,
    this.fechaFinSoat,
    this.fechaFinReTec,
    this.fechaFinCertProHidro,
    this.kilometraje,
    this.fotoKm,
    required this.detalle,
  });

  String? codFormtPreope;
  String? nombreFormatoPreope;
  String? versionFormtPreope;
  String? auditor;
  String? tanque;
  String? fechaVencCurManDef;
  String? fechaVencCurMercPel;
  String? docCondFvss;
  String? fechaVencLicCond;
  String? fechaFinQr;
  String? fechaFinPoExtra;
  String? rcHidroFechaFin;
  String? fechaFinTAforo;
  String? fechaFinCertLinea;
  String? resuPreGuia;
  String? resuPreFotoguia;
  String? firma;
  String? tvDescripcion;
  String? consecutivo;
  String? remolPlaca;
  String? vehPlaca;
  String? resuPreFecha;
  int? cc;
  String? conductor;
  String? mlm;
  String? rutaLogo;
  String? catLiceCond;
  String? fechaFinSoat;
  String? fechaFinReTec;
  String? fechaFinCertProHidro;
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
        fechaVencCurManDef: json["fechaVencCurManDef"],
        fechaVencCurMercPel: json["fechaVencCurMercPel"],
        docCondFvss: json["docCondFvss"],
        fechaVencLicCond: json["fechaVencLicCond"],
        fechaFinQr: json["fechaFinQr"],
        fechaFinPoExtra: json["fechaFinPoExtra"],
        rcHidroFechaFin: json["rcHidroFechaFin"],
        fechaFinTAforo: json["fechaFinTAforo"],
        fechaFinCertLinea: json["fechaFinCertLinea"],
        resuPreGuia: json["resuPreGuia"],
        resuPreFotoguia: json["resuPreFotoguia"],
        firma: json["firma"],
        tvDescripcion: json["tvDescripcion"],
        consecutivo: json["consecutivo"],
        remolPlaca: json["Remol_Placa"],
        vehPlaca: json["Veh_Placa"],
        resuPreFecha: json["resuPreFecha"],
        cc: json["cc"],
        conductor: json["conductor"],
        mlm: json["mlm"],
        rutaLogo: json["rutaLogo"],
        catLiceCond: json["catLiceCond"],
        fechaFinSoat: json["fechaFinSoat"],
        fechaFinReTec: json["fechaFinReTec"],
        fechaFinCertProHidro: json["fechaFinCertProHidro"],
        kilometraje: json["kilometraje"],
        fotoKm: json["fotoKm"],
        detalle:
            List<Detalle>.from(json["detalle"].map((x) => Detalle.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "codFormtPreope": codFormtPreope,
        "nombreFormatoPreope": nombreFormatoPreope,
        "versionFormtPreope": versionFormtPreope,
        "auditor": auditor,
        "tanque": tanque,
        "fechaVencCurManDef": fechaVencCurManDef,
        "fechaVencCurMercPel": fechaVencCurMercPel,
        "docCondFvss": docCondFvss,
        "fechaVencLicCond": fechaVencLicCond,
        "fechaFinQr": fechaFinQr,
        "fechaFinPoExtra": fechaFinPoExtra,
        "rcHidroFechaFin": rcHidroFechaFin,
        "fechaFinTAforo": fechaFinTAforo,
        "fechaFinCertLinea": fechaFinCertLinea,
        "resuPreGuia": resuPreGuia,
        "resuPreFotoguia": resuPreFotoguia,
        "firma": firma,
        "tvDescripcion": tvDescripcion,
        "consecutivo": consecutivo,
        "Remol_Placa": remolPlaca,
        "Veh_Placa": vehPlaca,
        "resuPreFecha": resuPreFecha,
        "cc": cc,
        "conductor": conductor,
        "mlm": mlm,
        "rutaLogo": rutaLogo,
        "catLiceCond": catLiceCond,
        "fechaFinSoat": fechaFinSoat,
        "fechaFinReTec": fechaFinReTec,
        "fechaFinCertProHidro": fechaFinCertProHidro,
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
        respuestas: List<RespuestaInspeccion>.from(
            json["respuestas"].map((x) => RespuestaInspeccion.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "idCategoria": idCategoria,
        "categoria": categoria,
        "respuestas": List<dynamic>.from(respuestas.map((x) => x.toMap())),
      };
}

class RespuestaInspeccion {
  RespuestaInspeccion(
      {this.foto,
      this.item,
      this.idItem,
      this.observacion,
      this.respuesta,
      this.fotoConverted});

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
