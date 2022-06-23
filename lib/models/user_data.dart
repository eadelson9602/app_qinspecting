// To parse this JSON data, do
//
//     final userData = userDataFromMap(jsonString);

import 'dart:convert';

class UserData {
  UserData({
    this.id,
    this.numeroDocumento,
    this.password,
    this.lugarExpDocumento,
    this.nombreCiudad,
    this.fkIdDepartamento,
    this.departamento,
    this.fechaNacimiento,
    this.genero,
    this.rh,
    this.arl,
    this.eps,
    this.afp,
    this.numeroCelular,
    this.direccion,
    this.apellidos,
    this.nombres,
    this.email,
    required this.urlFoto,
    this.idCargo,
    this.nombreCargo,
    this.estadoPersonal,
    this.idTipoDocumento,
    this.nombreTipoDocumento,
    this.rolId,
    this.rolNombre,
    this.rolDescripcion,
    this.idFirma,
    this.empresa,
    this.base
  });

  int? id;
  String? numeroDocumento;
  String? password;
  int? lugarExpDocumento;
  String? nombreCiudad;
  int? fkIdDepartamento;
  String? departamento;
  String? fechaNacimiento;
  String? genero;
  String? rh;
  String? arl;
  String? eps;
  String? afp;
  String? numeroCelular;
  String? direccion;
  String? apellidos;
  String? nombres;
  String? email;
  String urlFoto;
  int? idCargo;
  String? nombreCargo;
  int? estadoPersonal;
  int? idTipoDocumento;
  String? nombreTipoDocumento;
  int? rolId;
  String? rolNombre;
  String? rolDescripcion;
  int? docCondId;
  int? docCondLiceCond;
  String? docCondCatLiceCond;
  int? idFirma;
  String? empresa;
  String? base;

  factory UserData.fromJson(String str) => UserData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory UserData.fromMap(Map<String, dynamic> json) => UserData(
    id: json["id"],
    numeroDocumento: json["numeroDocumento"],
    password: json["password"],
    lugarExpDocumento: json["lugarExpDocumento"],
    nombreCiudad: json["nombreCiudad"],
    fkIdDepartamento: json["fkIdDepartamento"],
    departamento: json["departamento"],
    fechaNacimiento: json["fechaNacimiento"],
    genero: json["genero"],
    rh: json["rh"],
    arl: json["arl"],
    eps: json["eps"],
    afp: json["afp"],
    numeroCelular: json["numeroCelular"],
    direccion: json["direccion"],
    apellidos: json["apellidos"],
    nombres: json["nombres"],
    email: json["email"],
    urlFoto: json["urlFoto"],
    idCargo: json["idCargo"],
    nombreCargo: json["nombreCargo"],
    estadoPersonal: json["estadoPersonal"],
    idTipoDocumento: json["idTipoDocumento"],
    nombreTipoDocumento: json["nombreTipoDocumento"],
    rolId: json["rolId"],
    rolNombre: json["rolNombre"],
    rolDescripcion: json["rolDescripcion"],
    idFirma: json["idFirma"],
    empresa: json["empresa"],
    base: json["base"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "numeroDocumento": numeroDocumento,
    "password": password,
    "lugarExpDocumento": lugarExpDocumento,
    "nombreCiudad": nombreCiudad,
    "fkIdDepartamento": fkIdDepartamento,
    "departamento": departamento,
    "fechaNacimiento": fechaNacimiento,
    "genero": genero,
    "rh": rh,
    "arl": arl,
    "eps": eps,
    "afp": afp,
    "numeroCelular": numeroCelular,
    "direccion": direccion,
    "apellidos": apellidos,
    "nombres": nombres,
    "email": email,
    "urlFoto": urlFoto,
    "idCargo": idCargo,
    "nombreCargo": nombreCargo,
    "estadoPersonal": estadoPersonal,
    "idTipoDocumento": idTipoDocumento,
    "nombreTipoDocumento": nombreTipoDocumento,
    "rolId": rolId,
    "rolNombre": rolNombre,
    "rolDescripcion": rolDescripcion,
    "idFirma": idFirma,
    "empresa": empresa,
    "base": base,
  };
}

class TipoDocumentos {
  TipoDocumentos({
    this.value,
    this.label,
  });

  int? value;
  String? label;

  factory TipoDocumentos.fromJson(String str) =>
      TipoDocumentos.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory TipoDocumentos.fromMap(Map<String, dynamic> json) => TipoDocumentos(
    value: json["value"],
    label: json["label"],
  );

  Map<String, dynamic> toMap() => {
    "value": value,
    "label": label,
  };
}
