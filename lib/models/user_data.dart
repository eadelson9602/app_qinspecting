// To parse this JSON data, do
//
//     final userData = userDataFromMap(jsonString);

import 'dart:convert';

class UserData {
  UserData(
      {this.id,
      this.usuarioUser,
      this.usuarioContra,
      this.persLugarExpDoc,
      this.ciuNombre,
      this.dptId,
      this.departamento,
      this.persFechaNaci,
      this.persGenero,
      this.persRh,
      this.persArl,
      this.persEps,
      this.persAfp,
      this.persCelular,
      this.persDireccion,
      this.persApellidos,
      this.persNombres,
      this.persEmail,
      this.persImagen,
      this.cargId,
      this.cargDescripcion,
      this.usuarioEstado,
      this.estado,
      this.tipoDocId,
      this.tipoDocDescrip,
      this.rolId,
      this.rolNombre,
      this.rolDescripcion,
      this.docCondId,
      this.docCondLiceCond,
      this.docCondCatLiceCond,
      this.firmaId});

  int? id;
  int? usuarioUser;
  String? usuarioContra;
  int? persLugarExpDoc;
  String? ciuNombre;
  int? dptId;
  String? departamento;
  DateTime? persFechaNaci;
  String? persGenero;
  String? persRh;
  String? persArl;
  String? persEps;
  String? persAfp;
  String? persCelular;
  String? persDireccion;
  String? persApellidos;
  String? persNombres;
  String? persEmail;
  String? persImagen;
  int? cargId;
  String? cargDescripcion;
  int? usuarioEstado;
  int? estado;
  int? tipoDocId;
  String? tipoDocDescrip;
  int? rolId;
  String? rolNombre;
  String? rolDescripcion;
  int? docCondId;
  int? docCondLiceCond;
  String? docCondCatLiceCond;
  int? firmaId;

  factory UserData.fromJson(String str) => UserData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory UserData.fromMap(Map<String, dynamic> json) => UserData(
      id: json["id"],
      usuarioUser: json["UsuarioUser"],
      usuarioContra: json["Usuario_Contra"],
      persLugarExpDoc: json["Pers_LugarExpDoc"],
      ciuNombre: json["Ciu_Nombre"],
      dptId: json["Dpt_Id"],
      departamento: json["Departamento"],
      persFechaNaci: DateTime.parse(json["Pers_FechaNaci"]),
      persGenero: json["Pers_Genero"],
      persRh: json["Pers_Rh"],
      persArl: json["Pers_Arl"],
      persEps: json["Pers_Eps"],
      persAfp: json["Pers_Afp"],
      persCelular: json["Pers_Celular"],
      persDireccion: json["Pers_Direccion"],
      persApellidos: json["Pers_Apellidos"],
      persNombres: json["Pers_Nombres"],
      persEmail: json["Pers_Email"],
      persImagen: json["Pers_Imagen"],
      cargId: json["Carg_id"],
      cargDescripcion: json["Carg_Descripcion"],
      usuarioEstado: json["Usuario_Estado"],
      estado: json["estado"],
      tipoDocId: json["TipoDoc_Id"],
      tipoDocDescrip: json["TipoDoc_Descrip"],
      rolId: json["Rol_Id"],
      rolNombre: json["Rol_Nombre"],
      rolDescripcion: json["Rol_Descripcion"],
      docCondId: json["DocCond_Id"],
      docCondLiceCond: json["DocCond_Lice_Cond"],
      docCondCatLiceCond: json["DocCond_CatLiceCond"],
      firmaId: json["Firma_Id"]);

  Map<String, dynamic> toMap() => {
        "id": id,
        "UsuarioUser": usuarioUser,
        "Usuario_Contra": usuarioContra,
        "Pers_LugarExpDoc": persLugarExpDoc,
        "Ciu_Nombre": ciuNombre,
        "Dpt_Id": dptId,
        "Departamento": departamento,
        "Pers_FechaNaci":
            "${persFechaNaci!.year.toString().padLeft(4, '0')}-${persFechaNaci!.month.toString().padLeft(2, '0')}-${persFechaNaci!.day.toString().padLeft(2, '0')}",
        "Pers_Genero": persGenero,
        "Pers_Rh": persRh,
        "Pers_Arl": persArl,
        "Pers_Eps": persEps,
        "Pers_Afp": persAfp,
        "Pers_Celular": persCelular,
        "Pers_Direccion": persDireccion,
        "Pers_Apellidos": persApellidos,
        "Pers_Nombres": persNombres,
        "Pers_Email": persEmail,
        "Pers_Imagen": persImagen,
        "Carg_id": cargId,
        "Carg_Descripcion": cargDescripcion,
        "Usuario_Estado": usuarioEstado,
        "estado": estado,
        "TipoDoc_Id": tipoDocId,
        "TipoDoc_Descrip": tipoDocDescrip,
        "Rol_Id": rolId,
        "Rol_Nombre": rolNombre,
        "Rol_Descripcion": rolDescripcion,
        "DocCond_Id": docCondId,
        "DocCond_Lice_Cond": docCondLiceCond,
        "DocCond_CatLiceCond": docCondCatLiceCond,
        "Firma_Id": firmaId
      };
}
