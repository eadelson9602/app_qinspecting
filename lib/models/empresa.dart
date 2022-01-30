// To parse this JSON data, do
//
//     final empresa = empresaFromMap(jsonString);

import 'dart:convert';

class Empresa {
  Empresa(
      {this.nombreBase,
      this.autCreateCap,
      this.usuarioUser,
      this.usuarioContra,
      this.completeName,
      this.persApellidos,
      this.persNombres,
      this.persCelular,
      this.persEmail,
      this.cargDescripcion,
      this.persImagen,
      this.empId,
      this.rolId,
      this.cantF,
      this.razonSocial,
      this.nombreQi,
      this.urlQi,
      this.rutaLogo});

  String? nombreBase;
  int? autCreateCap;
  int? usuarioUser;
  String? usuarioContra;
  String? completeName;
  String? persApellidos;
  String? persNombres;
  String? persCelular;
  String? persEmail;
  String? cargDescripcion;
  String? persImagen;
  int? empId;
  int? rolId;
  int? cantF;
  String? razonSocial;
  String? nombreQi;
  String? urlQi;
  String? rutaLogo;

  factory Empresa.fromJson(String str) => Empresa.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Empresa.fromMap(Map<String, dynamic> json) => Empresa(
        nombreBase: json["nombre_base"],
        autCreateCap: json["aut_create_cap"],
        usuarioUser: json["UsuarioUser"],
        usuarioContra: json["Usuario_Contra"],
        completeName: json["Complete_Name"],
        persApellidos: json["Pers_Apellidos"],
        persNombres: json["Pers_Nombres"],
        persCelular: json["Pers_Celular"],
        persEmail: json["Pers_Email"],
        cargDescripcion: json["Carg_Descripcion"],
        persImagen: json["Pers_Imagen"],
        empId: json["Emp_Id"],
        rolId: json["Rol_Id"],
        cantF: json["CantF"],
        razonSocial: json["Razon_social"],
        nombreQi: json["nombre_QI"],
        urlQi: json["url_QI"],
        rutaLogo: json["ruta_logo"],
      );

  Map<String, dynamic> toMap() => {
        "nombre_base": nombreBase,
        "aut_create_cap": autCreateCap,
        "UsuarioUser": usuarioUser,
        "Usuario_Contra": usuarioContra,
        "Complete_Name": completeName,
        "Pers_Apellidos": persApellidos,
        "Pers_Nombres": persNombres,
        "Pers_Celular": persCelular,
        "Pers_Email": persEmail,
        "Carg_Descripcion": cargDescripcion,
        "Pers_Imagen": persImagen,
        "Emp_Id": empId,
        "Rol_Id": rolId,
        "CantF": cantF,
        "Razon_social": razonSocial,
        "nombre_QI": nombreQi,
        "url_QI": urlQi,
        "ruta_logo": rutaLogo,
      };
  // Crea una copia del modelo
  Empresa copy() => Empresa(
      nombreBase: nombreBase,
      autCreateCap: autCreateCap,
      usuarioUser: usuarioUser,
      usuarioContra: usuarioContra,
      completeName: completeName,
      persApellidos: persApellidos,
      persNombres: persNombres,
      persCelular: persCelular,
      persEmail: persEmail,
      cargDescripcion: cargDescripcion,
      persImagen: persImagen,
      empId: empId,
      rolId: rolId,
      cantF: cantF,
      razonSocial: razonSocial,
      nombreQi: nombreQi,
      urlQi: urlQi,
      rutaLogo: rutaLogo);
}
