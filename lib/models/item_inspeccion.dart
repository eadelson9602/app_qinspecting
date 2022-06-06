import 'dart:convert';

class ItemInspeccion {
  ItemInspeccion({
    required this.id,
    required this.placa,
    required this.tipoVehiculo,
    required this.idCategoria,
    required this.categoria,
    required this.idItem,
    required this.item,
  });

  String id;
  String placa;
  String tipoVehiculo;
  int idCategoria;
  String categoria;
  int idItem;
  String item;

  factory ItemInspeccion.fromJson(String str) =>
      ItemInspeccion.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ItemInspeccion.fromMap(Map<String, dynamic> json) => ItemInspeccion(
        id: json["id"],
        placa: json["placa"],
        tipoVehiculo: json["tipoVehiculo"],
        idCategoria: json["idCategoria"],
        categoria: json["categoria"],
        idItem: json["idItem"],
        item: json["item"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "placa": placa,
        "tipoVehiculo": tipoVehiculo,
        "idCategoria": idCategoria,
        "categoria": categoria,
        "idItem": idItem,
        "item": item,
      };
}

// Items de inspeccionados, se usa para mostrar las respuestas de la inspección en el pdf
class ItemsVehiculo {
  ItemsVehiculo({
    required this.idCategoria,
    required this.categoria,
    required this.items,
  });

  int idCategoria;
  String categoria;
  List<Item> items;

  factory ItemsVehiculo.fromJson(String str) =>
      ItemsVehiculo.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ItemsVehiculo.fromMap(Map<String, dynamic> json) => ItemsVehiculo(
    idCategoria: json["idCategoria"],
    categoria: json["categoria"],
    items: List<Item>.from(json["items"].map((x) => Item.fromMap(x))
  ));

  Map<String, dynamic> toMap() => {
    "idCategoria": idCategoria,
    "categoria": categoria,
    "items": List<dynamic>.from(items.map((x) => x.toMap())
  )};
}

class Item {
  Item({
    this.idCategoria,
    required this.idItem,
    required this.item,
    this.respuesta,
    this.adjunto,
    this.observaciones,
    this.fkPreoperacional,
    this.base
  });

  int? idCategoria;
  String idItem;
  String item;
  String? respuesta;
  String? adjunto;
  String? observaciones;
  int? fkPreoperacional;
  String? base;

  factory Item.fromJson(String str) => Item.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Item.fromMap(Map<String, dynamic> json) => Item(
    idCategoria: json['idCategoria'],
    idItem: json["idItem"].toString(),
    item: json["item"],
    respuesta: json["respuesta"],
    adjunto: json["adjunto"],
    observaciones: json["observaciones"],
    fkPreoperacional: json["Id"],
    base: json["base"],
  );

  Map<String, dynamic> toMap() => {
    "idCategoria": idCategoria,
    "idItem": idItem,
    "item": item,
    "respuesta": respuesta,
    "adjunto": adjunto,
    "observaciones": observaciones,
    "fkPreoperacional": fkPreoperacional,
    "base": base,
  };
}
