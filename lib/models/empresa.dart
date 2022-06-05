// To parse this JSON data, do
//
//     final empresa = empresaFromMap(jsonString);

import 'dart:convert';

class Empresa {
  Empresa(
      {this.nombreBase,
      this.autCreateCap,
      this.numeroDocumento,
      this.password,
      this.apellidos,
      this.nombres,
      this.numeroCelular,
      this.email,
      this.nombreCargo,
      this.urlFoto,
      this.idEmpresa,
      this.idRol,
      this.razonSocial,
      this.nombreQi,
      this.urlQi,
      this.rutaLogo});

  String? nombreBase;
  int? autCreateCap;
  String? numeroDocumento;
  String? password;
  String? apellidos;
  String? nombres;
  String? numeroCelular;
  String? email;
  String? nombreCargo;
  String? urlFoto;
  int? idEmpresa;
  int? idRol;
  int? cantF;
  String? razonSocial;
  String? nombreQi;
  String? urlQi;
  String? rutaLogo;

  factory Empresa.fromJson(String str) => Empresa.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Empresa.fromMap(Map<String, dynamic> json) => Empresa(
        nombreBase: json["nombreBase"],
        autCreateCap: json["autCreateCap"],
        numeroDocumento: json["numeroDocumento"],
        password: json["password"],
        apellidos: json["apellidos"],
        nombres: json["nombres"],
        numeroCelular: json["numeroCelular"],
        email: json["email"],
        nombreCargo: json["nombreCargo"],
        urlFoto: json["urlFoto"],
        idEmpresa: json["idEmpresa"],
        idRol: json["idRol"],
        razonSocial: json["razonSocial"],
        nombreQi: json["nombreQi"],
        urlQi: json["urlQi"],
        rutaLogo: json["rutaLogo"],
      );

  Map<String, dynamic> toMap() => {
        "nombreBase": nombreBase,
        "autCreateCap": autCreateCap,
        "numeroDocumento": numeroDocumento,
        "password": password,
        "apellidos": apellidos,
        "nombres": nombres,
        "numeroCelular": numeroCelular,
        "email": email,
        "nombreCargo": nombreCargo,
        "urlFoto": urlFoto,
        "idEmpresa": idEmpresa,
        "idRol": idRol,
        "razonSocial": razonSocial,
        "nombreQi": nombreQi,
        "urlQi": urlQi,
        "rutaLogo": rutaLogo,
      };
  // Crea una copia del modelo
  Empresa copy() => Empresa(
      nombreBase: nombreBase,
      autCreateCap: autCreateCap,
      numeroDocumento: numeroDocumento,
      password: password,
      apellidos: apellidos,
      nombres: nombres,
      numeroCelular: numeroCelular,
      email: email,
      nombreCargo: nombreCargo,
      urlFoto: urlFoto,
      idEmpresa: idEmpresa,
      idRol: idRol,
      razonSocial: razonSocial,
      nombreQi: nombreQi,
      urlQi: urlQi,
      rutaLogo: rutaLogo);
}
