import 'dart:convert';

class ItemInspeccion {
  ItemInspeccion({
    required this.idCategoria,
    required this.categoria,
    required this.idItem,
    required this.item,
  });

  int idCategoria;
  String categoria;
  int idItem;
  String item;

  factory ItemInspeccion.fromJson(String str) =>
      ItemInspeccion.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ItemInspeccion.fromMap(Map<String, dynamic> json) => ItemInspeccion(
        idCategoria: json["id_categoria"],
        categoria: json["categoria"],
        idItem: json["id_item"],
        item: json["item"],
      );

  Map<String, dynamic> toMap() => {
        "id_categoria": idCategoria,
        "categoria": categoria,
        "id_item": idItem,
        "item": item,
      };
}
