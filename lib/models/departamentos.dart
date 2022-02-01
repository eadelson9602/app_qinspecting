import 'dart:convert';

class Departamentos {
  Departamentos({
    required this.value,
    required this.label,
    required this.ciudades,
  });

  int value;
  String label;
  List<Ciudade> ciudades;

  factory Departamentos.fromJson(String str) =>
      Departamentos.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Departamentos.fromMap(Map<String, dynamic> json) => Departamentos(
        value: json["value"],
        label: json["label"],
        ciudades:
            List<Ciudade>.from(json["ciudades"].map((x) => Ciudade.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "value": value,
        "label": label,
        "ciudades": List<dynamic>.from(ciudades.map((x) => x.toMap())),
      };
}

class Ciudade {
  Ciudade({
    required this.value,
    required this.label,
    required this.dptValue,
  });

  int value;
  String label;
  int dptValue;

  factory Ciudade.fromJson(String str) => Ciudade.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Ciudade.fromMap(Map<String, dynamic> json) => Ciudade(
        value: json["value"],
        label: json["label"],
        dptValue: json["dpt_value"],
      );

  Map<String, dynamic> toMap() => {
        "value": value,
        "label": label,
        "dpt_value": dptValue,
      };
}
