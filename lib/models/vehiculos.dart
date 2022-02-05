import 'dart:convert';

class Vehiculos {
  Vehiculos({
    this.kilometraje,
    this.aplicaRemolque,
    this.docVehId,
    this.vehId,
    this.idIntegracion,
    this.nombreClient,
    this.vehPlaca,
    this.ciuNombre,
    this.ciuId,
    this.dptId,
    this.dptNombre,
    this.vehFechMatricula,
    this.vehColorPlaca,
    this.vehLugarPlaca,
    this.vehMarca,
    this.vehMarcaId,
    this.vehLinea,
    this.vehModelo,
    this.vehCilindraje,
    this.vehColor,
    this.vehCombustible,
    this.vehMotor,
    this.vehSerie,
    this.vehEstado,
    this.state,
    this.provId,
    this.tvId,
    this.provNombre,
    this.tvDescripcion,
    this.docVehCltNumero,
    this.docVehCltFecha,
    this.docVehLicTranNumero,
    this.docVehLicTranFecha,
    this.docVehSoatNumero,
    this.docVehSoatFecha,
    this.docVehReTecNumero,
    this.docVehReTecFecha,
    this.docVehPoExtraNumero,
    this.docVehPoExtraFecha,
    this.docVehRcHidroNumero,
    this.docVehRcHidroFecha,
    this.docVehCertQrNumero,
    this.docVehCertQrFecha,
    this.remolId,
    this.notaClt,
    this.docVehCltFechaFin,
    this.notaLictran,
    this.docVehLicTranFechaFin,
    this.notaSoat,
    this.docVehSoatFechaFin,
    this.notaRetec,
    this.docVehReTecFechaFin,
    this.notaPoextra,
    this.docVehPoExtraFechaFin,
    this.notaRchidro,
    this.docVehRcHidroFechaFin,
    this.notaCertqr,
    this.docVehCertQrFechaFin,
  });

  int? kilometraje;
  int? aplicaRemolque;
  int? docVehId;
  int? vehId;
  int? idIntegracion;
  String? nombreClient;
  String? vehPlaca;
  String? ciuNombre;
  int? ciuId;
  int? dptId;
  String? dptNombre;
  DateTime? vehFechMatricula;
  String? vehColorPlaca;
  int? vehLugarPlaca;
  String? vehMarca;
  int? vehMarcaId;
  String? vehLinea;
  int? vehModelo;
  int? vehCilindraje;
  String? vehColor;
  String? vehCombustible;
  String? vehMotor;
  String? vehSerie;
  int? vehEstado;
  int? state;
  int? provId;
  int? tvId;
  String? provNombre;
  String? tvDescripcion;
  String? docVehCltNumero;
  DateTime? docVehCltFecha;
  int? docVehLicTranNumero;
  DateTime? docVehLicTranFecha;
  int? docVehSoatNumero;
  DateTime? docVehSoatFecha;
  int? docVehReTecNumero;
  DateTime? docVehReTecFecha;
  String? docVehPoExtraNumero;
  DateTime? docVehPoExtraFecha;
  int? docVehRcHidroNumero;
  DateTime? docVehRcHidroFecha;
  int? docVehCertQrNumero;
  DateTime? docVehCertQrFecha;
  String? remolId;
  String? notaClt;
  DateTime? docVehCltFechaFin;
  String? notaLictran;
  DateTime? docVehLicTranFechaFin;
  String? notaSoat;
  DateTime? docVehSoatFechaFin;
  String? notaRetec;
  DateTime? docVehReTecFechaFin;
  String? notaPoextra;
  DateTime? docVehPoExtraFechaFin;
  String? notaRchidro;
  DateTime? docVehRcHidroFechaFin;
  String? notaCertqr;
  DateTime? docVehCertQrFechaFin;

  factory Vehiculos.fromJson(String str) => Vehiculos.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Vehiculos.fromMap(Map<String, dynamic> json) => Vehiculos(
        kilometraje: json["kilometraje"],
        aplicaRemolque: json["aplica_remolque"],
        docVehId: json["DocVeh_Id"],
        vehId: json["Veh_Id"],
        idIntegracion: json["id_integracion"],
        nombreClient: json["nombre_client"],
        vehPlaca: json["Veh_Placa"],
        ciuNombre: json["Ciu_Nombre"],
        ciuId: json["Ciu_Id"],
        dptId: json["Dpt_Id"],
        dptNombre: json["Dpt_Nombre"],
        vehFechMatricula: DateTime.parse(json["Veh_Fech_Matricula"]),
        vehColorPlaca: json["Veh_Color_Placa"],
        vehLugarPlaca: json["Veh_LugarPlaca"],
        vehMarca: json["Veh_Marca"],
        vehMarcaId: json["Veh_Marca_Id"],
        vehLinea: json["Veh_Linea"],
        vehModelo: json["Veh_Modelo"],
        vehCilindraje: json["Veh_Cilindraje"],
        vehColor: json["Veh_Color"],
        vehCombustible: json["Veh_Combustible"],
        vehMotor: json["Veh_Motor"],
        vehSerie: json["Veh_Serie"],
        vehEstado: json["Veh_Estado"],
        state: json["State"],
        provId: json["Prov_Id"],
        tvId: json["Tv_Id"],
        provNombre: json["Prov_Nombre"],
        tvDescripcion: json["Tv_descripcion"],
        docVehCltNumero: json["DocVeh_CltNumero"],
        docVehCltFecha: DateTime.parse(json["DocVeh_CltFecha"]),
        docVehLicTranNumero: json["DocVeh_LicTranNumero"],
        docVehLicTranFecha: DateTime.parse(json["DocVeh_LicTranFecha"]),
        docVehSoatNumero: json["DocVeh_SoatNumero"],
        docVehSoatFecha: DateTime.parse(json["DocVeh_SoatFecha"]),
        docVehReTecNumero: json["DocVeh_ReTecNumero"],
        docVehReTecFecha: DateTime.parse(json["DocVeh_ReTecFecha"]),
        docVehPoExtraNumero: json["DocVeh_PoExtraNumero"],
        docVehPoExtraFecha: DateTime.parse(json["DocVeh_PoExtraFecha"]),
        docVehRcHidroNumero: json["DocVeh_RCHidroNumero"],
        docVehRcHidroFecha: DateTime.parse(json["DocVeh_RCHidroFecha"]),
        docVehCertQrNumero: json["DocVeh_CertQRNumero"],
        docVehCertQrFecha: DateTime.parse(json["DocVeh_CertQRFecha"]),
        remolId: json["Remol_Id"],
        notaClt: json["notaClt"],
        docVehCltFechaFin: json["DocVeh_CltFechaFin"] == null
            ? null
            : DateTime.parse(json["DocVeh_CltFechaFin"]),
        notaLictran: json["notaLictran"],
        docVehLicTranFechaFin: json["DocVeh_LicTranFechaFin"] == null
            ? null
            : DateTime.parse(json["DocVeh_LicTranFechaFin"]),
        notaSoat: json["notaSoat"],
        docVehSoatFechaFin: json["DocVeh_SoatFechaFin"] == null
            ? null
            : DateTime.parse(json["DocVeh_SoatFechaFin"]),
        notaRetec: json["notaRetec"],
        docVehReTecFechaFin: json["DocVeh_ReTecFechaFin"] == null
            ? null
            : DateTime.parse(json["DocVeh_ReTecFechaFin"]),
        notaPoextra: json["notaPoextra"],
        docVehPoExtraFechaFin: json["DocVeh_PoExtraFechaFin"] == null
            ? null
            : DateTime.parse(json["DocVeh_PoExtraFechaFin"]),
        notaRchidro: json["notaRchidro"],
        docVehRcHidroFechaFin: json["DocVeh_RCHidroFechaFin"] == null
            ? null
            : DateTime.parse(json["DocVeh_RCHidroFechaFin"]),
        notaCertqr: json["notaCertqr"],
        docVehCertQrFechaFin: json["DocVeh_CertQRFechaFin"] == null
            ? null
            : DateTime.parse(json["DocVeh_CertQRFechaFin"]),
      );

  Map<String, dynamic> toMap() => {
        "kilometraje": kilometraje,
        "aplica_remolque": aplicaRemolque,
        "DocVeh_Id": docVehId,
        "Veh_Id": vehId,
        "id_integracion": idIntegracion,
        "nombre_client": nombreClient,
        "Veh_Placa": vehPlaca,
        "Ciu_Nombre": ciuNombre,
        "Ciu_Id": ciuId,
        "Dpt_Id": dptId,
        "Dpt_Nombre": dptNombre,
        "Veh_Fech_Matricula": vehFechMatricula,
        "Veh_Color_Placa": vehColorPlaca,
        "Veh_LugarPlaca": vehLugarPlaca,
        "Veh_Marca": vehMarca,
        "Veh_Marca_Id": vehMarcaId,
        "Veh_Linea": vehLinea,
        "Veh_Modelo": vehModelo,
        "Veh_Cilindraje": vehCilindraje,
        "Veh_Color": vehColor,
        "Veh_Combustible": vehCombustible,
        "Veh_Motor": vehMotor,
        "Veh_Serie": vehSerie,
        "Veh_Estado": vehEstado,
        "State": state,
        "Prov_Id": provId,
        "Tv_Id": tvId,
        "Prov_Nombre": provNombre,
        "Tv_descripcion": tvDescripcion,
        "DocVeh_CltNumero": docVehCltNumero,
        "DocVeh_CltFecha": docVehCltFecha,
        "DocVeh_LicTranNumero": docVehLicTranNumero,
        "DocVeh_LicTranFecha": docVehLicTranFecha,
        "DocVeh_SoatNumero": docVehSoatNumero,
        "DocVeh_SoatFecha": docVehSoatFecha,
        "DocVeh_ReTecNumero": docVehReTecNumero,
        "DocVeh_ReTecFecha": docVehReTecFecha,
        "DocVeh_PoExtraNumero": docVehPoExtraNumero,
        "DocVeh_PoExtraFecha": docVehPoExtraFecha,
        "DocVeh_RCHidroNumero": docVehRcHidroNumero,
        "DocVeh_RCHidroFecha": docVehRcHidroFecha,
        "DocVeh_CertQRNumero": docVehCertQrNumero,
        "DocVeh_CertQRFecha": docVehCertQrFecha,
        "Remol_Id": remolId,
        "notaClt": notaClt,
        "DocVeh_CltFechaFin": docVehCltFechaFin,
        "notaLictran": notaLictran,
        "DocVeh_LicTranFechaFin": docVehLicTranFechaFin,
        "notaSoat": notaSoat,
        "DocVeh_SoatFechaFin": docVehSoatFechaFin,
        "notaRetec": notaRetec,
        "DocVeh_ReTecFechaFin": docVehReTecFechaFin,
        "notaPoextra": notaPoextra,
        "DocVeh_PoExtraFechaFin": docVehPoExtraFechaFin,
        "notaRchidro": notaRchidro,
        "DocVeh_RCHidroFechaFin": docVehRcHidroFechaFin,
        "notaCertqr": notaCertqr,
        "DocVeh_CertQRFechaFin": docVehCertQrFechaFin,
      };
}
