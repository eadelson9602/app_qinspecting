import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/ui/input_decorations.dart';
import 'package:app_qinspecting/providers/providers.dart';

class InspectionScreen extends StatelessWidget {
  const InspectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inspeccionForm = Provider.of<InspeccionProvider>(context);

    Widget guiaTransporte() {
      return inspeccionForm.tieneGuia
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
                if (inspeccionForm.tieneGuia)
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

    Widget infoRemolque() {
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

    return SingleChildScrollView(
      child: Form(
        key: inspeccionForm.formKey,
        child: Column(
          children: [
            DropdownButtonFormField(
                decoration: InputDecorations.authInputDecorations(
                    prefixIcon: Icons.local_shipping,
                    hintText: '',
                    labelText: 'Placa del vehículo'),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Placa 1'))
                ],
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
                  hintText: '', labelText: 'Marca de cabezote'),
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
                  hintText: '', labelText: 'Modelo de cabezote'),
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
                  hintText: '', labelText: 'Licencia tránsito'),
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
                  hintText: '', labelText: 'Color de cabezote'),
            ),
            DropdownButtonFormField(
                decoration: InputDecorations.authInputDecorations(
                    prefixIcon: Icons.place,
                    hintText: '',
                    labelText: 'Departamento de inspección'),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Departamento 1'))
                ],
                onChanged: (value) {
                  print(value);
                }),
            const SizedBox(
              height: 10,
            ),
            DropdownButtonFormField(
                decoration: InputDecorations.authInputDecorations(
                    prefixIcon: Icons.location_city,
                    hintText: '',
                    labelText: 'Ciudad de inspección'),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Ciudad 1'))
                ],
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
                value: inspeccionForm.realizoTanqueo,
                title: const Text('¿Realizó tanqueo?'),
                activeColor: Colors.green,
                onChanged: (value) =>
                    inspeccionForm.updateRealizoTanqueo(value)),
            SwitchListTile.adaptive(
                value: inspeccionForm.tieneRemolque,
                title: const Text('¿Tiene remolque?'),
                activeColor: Colors.green,
                onChanged: (value) =>
                    inspeccionForm.updateTieneRemolque(value)),
            SwitchListTile.adaptive(
                value: inspeccionForm.tieneGuia,
                title: const Text('Tiene guía transporte?'),
                activeColor: Colors.green,
                onChanged: (value) => inspeccionForm.updateTieneGuia(value)),
            const SizedBox(
              height: 10,
            ),
            if (inspeccionForm.realizoTanqueo)
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
            if (inspeccionForm.tieneRemolque) infoRemolque(),
            const SizedBox(
              height: 10,
            ),
            if (inspeccionForm.tieneGuia) guiaTransporte()
          ],
        ),
      ),
    );
  }
}
