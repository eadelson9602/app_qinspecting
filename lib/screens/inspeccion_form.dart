import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import "package:collection/collection.dart";

import 'package:app_qinspecting/ui/input_decorations.dart';
import 'package:app_qinspecting/providers/providers.dart';

class InspeccionForm extends StatelessWidget {
  const InspeccionForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inspeccionProvider = Provider.of<InspeccionProvider>(context);
    Widget _guiaTransporte() {
      return inspeccionProvider.tieneGuia
          ? Column(
              children: [
                TextFormField(
                  autocorrect: false,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value!.isEmpty) return 'Ingrese guía transporte';
                    return null;
                  },
                  decoration: InputDecorations.authInputDecorations(
                      hintText: '',
                      labelText: 'Guía transporte',
                      prefixIcon: Icons.speed),
                ),
                const SizedBox(
                  height: 10,
                ),
                if (inspeccionProvider.tieneGuia)
                  TextFormField(
                    autocorrect: false,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Ingrese foto de la guía transporte';
                      }
                      return null;
                    },
                    decoration: InputDecorations.authInputDecorations(
                        hintText: '',
                        labelText: 'Foto de la guía transporte',
                        prefixIcon: Icons.speed),
                  ),
              ],
            )
          : Container();
    }

    Widget _infoRemolque() {
      return Column(children: [
        DropdownButtonFormField(
            decoration: InputDecorations.authInputDecorations(
                prefixIcon: Icons.local_shipping,
                hintText: '',
                labelText: 'Placa del remolque'),
            items: const [DropdownMenuItem(value: 1, child: Text('Placa 1'))],
            onChanged: (value) {
              print(value);
            }),
        const SizedBox(
          height: 10,
        ),
        TextFormField(
          textCapitalization: TextCapitalization.words,
          autocorrect: false,
          readOnly: true,
          keyboardType: TextInputType.text,
          decoration: InputDecorations.authInputDecorations(
              hintText: '', labelText: 'Marca del remolque'),
        ),
        const SizedBox(
          height: 10,
        ),
        TextFormField(
          textCapitalization: TextCapitalization.words,
          autocorrect: false,
          readOnly: true,
          keyboardType: TextInputType.text,
          decoration: InputDecorations.authInputDecorations(
              hintText: '', labelText: 'Modelo del remolque'),
        ),
        const SizedBox(
          height: 10,
        ),
        TextFormField(
          textCapitalization: TextCapitalization.words,
          autocorrect: false,
          readOnly: true,
          keyboardType: TextInputType.text,
          decoration: InputDecorations.authInputDecorations(
              hintText: '', labelText: 'Licencia de tránsito del remolque'),
        ),
        const SizedBox(
          height: 10,
        ),
        TextFormField(
          textCapitalization: TextCapitalization.words,
          autocorrect: false,
          readOnly: true,
          keyboardType: TextInputType.text,
          decoration: InputDecorations.authInputDecorations(
              hintText: '', labelText: 'Número de ejes del remolque'),
        ),
      ]);
    }

    Widget _infoVehiculo() {
      return inspeccionProvider.vehiculoSelected == null
          ? Container()
          : Column(
              children: [
                ListTile(
                  dense: true,
                  shape: Border(bottom: BorderSide(color: Colors.green)),
                  title: Text('Marca del cabezote',
                      style: TextStyle(fontSize: 15)),
                  subtitle: Text(
                      inspeccionProvider.vehiculoSelected!.marca.toString(),
                      style: TextStyle(fontSize: 15)),
                ),
                ListTile(
                  dense: true,
                  shape: Border(bottom: BorderSide(color: Colors.green)),
                  title: Text('Modelo del cabezote',
                      style: TextStyle(fontSize: 15)),
                  subtitle: Text(
                      inspeccionProvider.vehiculoSelected!.modelo.toString(),
                      style: TextStyle(fontSize: 15)),
                ),
                ListTile(
                  dense: true,
                  shape: Border(bottom: BorderSide(color: Colors.green)),
                  title:
                      Text('Licencia tránsito', style: TextStyle(fontSize: 15)),
                  subtitle: Text(
                      inspeccionProvider.vehiculoSelected!.licenciaTransito
                          .toString(),
                      style: TextStyle(fontSize: 15)),
                ),
                ListTile(
                  dense: true,
                  shape: Border(bottom: BorderSide(color: Colors.green)),
                  title:
                      Text('Color de cabezote', style: TextStyle(fontSize: 15)),
                  subtitle: Text(
                      inspeccionProvider.vehiculoSelected!.color.toString(),
                      style: TextStyle(fontSize: 15)),
                ),
              ],
            );
    }

    return SingleChildScrollView(
      child: Form(
        key: inspeccionProvider.formKey,
        child: Column(
          children: [
            DropdownButtonFormField<String>(
                decoration: InputDecorations.authInputDecorations(
                    prefixIcon: Icons.local_shipping,
                    hintText: '',
                    labelText: 'Placa del vehículo'),
                items: inspeccionProvider.vehiculos.map((e) {
                  return DropdownMenuItem(
                    child: Text(e.placa),
                    value: e.placa,
                  );
                }).toList(),
                onChanged: (value) async {
                  final resultVehiculo =
                      await DBProvider.db.getVehiculoByPlate(value!);
                  inspeccionProvider.updateVehiculoSelected(resultVehiculo!);

                  List<Map<String, dynamic>> tempItems = [];

                  for (var item in inspeccionProvider.itemsInspeccion) {
                    tempItems.add({
                      "idCategoria": item.idCategoria.toString(),
                      "categoria": item.categoria,
                      "idItem": item.idItem.toString(),
                      "item": item.item
                    });
                  }
                  var newMap =
                      groupBy(tempItems, (Map obj) => obj['categoria']);

                  print(newMap);
                }),
            _infoVehiculo(),
            DropdownButtonFormField<int>(
                decoration: InputDecorations.authInputDecorations(
                    prefixIcon: Icons.place,
                    hintText: '',
                    labelText: 'Departamento de inspección'),
                items: inspeccionProvider.departamentos.map((e) {
                  return DropdownMenuItem(
                    child: Text(e.label),
                    value: e.value,
                  );
                }).toList(),
                onChanged: (value) {
                  inspeccionProvider.listarCiudades(value!);
                }),
            const SizedBox(
              height: 10,
            ),
            DropdownButtonFormField(
                decoration: InputDecorations.authInputDecorations(
                    prefixIcon: Icons.location_city,
                    hintText: '',
                    labelText: 'Ciudad de inspección'),
                items: inspeccionProvider.ciudades.map((e) {
                  return DropdownMenuItem(
                    child: Text(e.label),
                    value: e.value,
                  );
                }).toList(),
                onChanged: (value) {
                  print(value);
                }),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value!.isEmpty) return 'Ingrese kilometraje';
                return null;
              },
              decoration: InputDecorations.authInputDecorations(
                  hintText: '',
                  labelText: 'Kilometraje',
                  prefixIcon: Icons.speed),
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value!.isEmpty) return 'Foto del tacometro';
                return null;
              },
              decoration: InputDecorations.authInputDecorations(
                  hintText: '',
                  labelText: 'Foto tacometro',
                  prefixIcon: Icons.speed),
            ),
            const SizedBox(
              height: 10,
            ),
            SwitchListTile.adaptive(
                value: inspeccionProvider.realizoTanqueo,
                title: const Text('¿Realizó tanqueo?'),
                activeColor: Colors.green,
                onChanged: (value) =>
                    inspeccionProvider.updateRealizoTanqueo(value)),
            SwitchListTile.adaptive(
                value: inspeccionProvider.tieneRemolque,
                title: const Text('¿Tiene remolque?'),
                activeColor: Colors.green,
                onChanged: (value) =>
                    inspeccionProvider.updateTieneRemolque(value)),
            SwitchListTile.adaptive(
                value: inspeccionProvider.tieneGuia,
                title: const Text('Tiene guía transporte?'),
                activeColor: Colors.green,
                onChanged: (value) =>
                    inspeccionProvider.updateTieneGuia(value)),
            const SizedBox(
              height: 10,
            ),
            if (inspeccionProvider.realizoTanqueo)
              TextFormField(
                autocorrect: false,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Cantidad de galones';
                  return null;
                },
                decoration: InputDecorations.authInputDecorations(
                    hintText: '',
                    labelText: 'Cantidad de galones tanqueados',
                    prefixIcon: Icons.speed),
              ),
            const SizedBox(
              height: 10,
            ),
            if (inspeccionProvider.tieneRemolque) _infoRemolque(),
            const SizedBox(
              height: 10,
            ),
            if (inspeccionProvider.tieneGuia) _guiaTransporte()
          ],
        ),
      ),
    );
  }
}
