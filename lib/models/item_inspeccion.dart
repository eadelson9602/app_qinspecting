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
        tipoVehiculo: json["tipo_vehiculo"],
        idCategoria: json["id_categoria"],
        categoria: json["categoria"],
        idItem: json["id_item"],
        item: json["item"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "placa": placa,
        "tipo_vehiculo": tipoVehiculo,
        "id_categoria": idCategoria,
        "categoria": categoria,
        "id_item": idItem,
        "item": item,
      };
}

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
    idCategoria: json["id_categoria"],
    categoria: json["categoria"],
    items: List<Item>.from(json["items"].map((x) => Item.fromMap(x))
  ));

  Map<String, dynamic> toMap() => {
    "id_categoria": idCategoria,
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
    idItem: json["id_item"].toString(),
    item: json["item"],
    respuesta: json["respuesta"],
    adjunto: json["adjunto"],
    observaciones: json["observaciones"],
    fkPreoperacional: json["Id"],
    base: json["base"],
  );

  Map<String, dynamic> toMap() => {
    "idCategoria": idCategoria,
    "id_item": idItem,
    "item": item,
    "respuesta": respuesta,
    "adjunto": adjunto,
    "observaciones": observaciones,
    "fk_preoperacional": fkPreoperacional,
    "base": base,
  };
}
