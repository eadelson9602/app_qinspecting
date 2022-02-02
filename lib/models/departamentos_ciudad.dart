import 'dart:convert';

class Departamentos {
  Departamentos({
    required this.value,
    required this.label,
  });

  int value;
  String label;

  factory Departamentos.fromJson(String str) =>
      Departamentos.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Departamentos.fromMap(Map<String, dynamic> json) => Departamentos(
        value: json["value"],
        label: json["label"],
      );

  Map<String, dynamic> toMap() => {
        "value": value,
        "label": label,
      };
}

class Ciudades {
  Ciudades({
    required this.value,
    required this.label,
    required this.idDepartamento,
  });

  int value;
  String label;
  int idDepartamento;

  factory Ciudades.fromJson(String str) => Ciudades.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Ciudades.fromMap(Map<String, dynamic> json) => Ciudades(
        value: json["value"],
        label: json["label"],
        idDepartamento: json["id_departamento"],
      );

  Map<String, dynamic> toMap() => {
        "value": value,
        "label": label,
        "id_departamento": idDepartamento,
      };
}
