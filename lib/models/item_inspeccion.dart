import 'dart:convert';

class ItemInspeccion {
  ItemInspeccion({
    required this.placa,
    required this.tipoVehiculo,
    required this.idCategoria,
    required this.categoria,
    required this.idItem,
    required this.item,
  });
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
        placa: json["placa"],
        tipoVehiculo: json["tipo_vehiculo"],
        idCategoria: json["id_categoria"],
        categoria: json["categoria"],
        idItem: json["id_item"],
        item: json["item"],
      );

  Map<String, dynamic> toMap() => {
        "placa": placa,
        "tipo_vehiculo": tipoVehiculo,
        "id_categoria": idCategoria,
        "categoria": categoria,
        "id_item": idItem,
        "item": item,
      };
}
