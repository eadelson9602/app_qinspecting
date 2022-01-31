import 'package:flutter/material.dart';

import 'package:app_qinspecting/ui/input_decorations.dart';

enum SiNo { si, no }

class InspectionScreen extends StatelessWidget {
  const InspectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SiNo? _optSelected = SiNo.si;
    return Container(
      child: SingleChildScrollView(
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
            ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              title: const Text('¿Realizó tanqueo?'),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: RadioListTile<SiNo>(
                        title: const Text('Yes'),
                        value: SiNo.si,
                        groupValue: _optSelected,
                        onChanged: (SiNo? value) {
                          _optSelected = value;
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<SiNo>(
                        title: const Text('No'),
                        value: SiNo.no,
                        groupValue: _optSelected,
                        onChanged: (SiNo? value) {
                          _optSelected = value;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              title: const Text('¿Tiene remolque?'),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: RadioListTile<SiNo>(
                        title: const Text('Yes'),
                        value: SiNo.si,
                        groupValue: _optSelected,
                        onChanged: (SiNo? value) {
                          _optSelected = value;
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<SiNo>(
                        title: const Text('No'),
                        value: SiNo.no,
                        groupValue: _optSelected,
                        onChanged: (SiNo? value) {
                          _optSelected = value;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              title: const Text('¿Tiene guía transporte?'),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: RadioListTile<SiNo>(
                        title: const Text('Yes'),
                        value: SiNo.si,
                        groupValue: _optSelected,
                        onChanged: (SiNo? value) {
                          _optSelected = value;
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<SiNo>(
                        title: const Text('No'),
                        value: SiNo.no,
                        groupValue: _optSelected,
                        onChanged: (SiNo? value) {
                          _optSelected = value;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
