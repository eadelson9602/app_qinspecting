import 'package:app_qinspecting/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

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
                  onChanged: (value) {
                    inspeccionProvider.resumePreoperacional?.resuPreGuia =
                        value;
                  },
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
                Text('Foto guía de transporte'),
                Stack(
                  children: [
                    BoardImage(
                      url: inspeccionProvider.pathFileGuia,
                    ),
                    Positioned(
                        right: 15,
                        bottom: 10,
                        child: IconButton(
                          onPressed: () async {
                            final _picker = ImagePicker();
                            final XFile? photo = await _picker.pickImage(
                                source: ImageSource.camera);

                            if (photo == null) {
                              return;
                            }
                            inspeccionProvider.updateImageGuia(photo.path);
                          },
                          icon: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 45,
                          ),
                        ))
                  ],
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
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            DropdownButtonFormField<String>(
                decoration: InputDecorations.authInputDecorations(
                    prefixIcon: Icons.local_shipping,
                    hintText: '',
                    labelText: 'Placa del vehículo'),
                validator: (value) {
                  if (value == null) return 'Seleccione una placa';
                  return null;
                },
                items: inspeccionProvider.vehiculos.map((e) {
                  return DropdownMenuItem(
                    child: Text(e.placa),
                    value: e.placa,
                  );
                }).toList(),
                onChanged: (value) async {
                  final resultVehiculo =
                      await DBProvider.db.getVehiculoByPlate(value!);

                  inspeccionProvider.resumePreoperacional?.vehId =
                      resultVehiculo!.idVehiculo;

                  inspeccionProvider.updateVehiculoSelected(resultVehiculo!);

                  await inspeccionProvider.listarCategoriaItems();
                }),
            _infoVehiculo(),
            DropdownButtonFormField<int>(
                decoration: InputDecorations.authInputDecorations(
                    prefixIcon: Icons.place,
                    hintText: '',
                    labelText: 'Departamento de inspección'),
                validator: (value) {
                  if (value == null) return 'Seleccione un departamento';
                  return null;
                },
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
                validator: (value) {
                  if (value == null) return 'Seleccione una ciudad';
                  return null;
                },
                items: inspeccionProvider.ciudades.map((e) {
                  return DropdownMenuItem(
                    child: Text(e.label),
                    value: e.value,
                  );
                }).toList(),
                onChanged: (value) {
                  inspeccionProvider.resumePreoperacional?.vehId =
                      int.parse(value.toString());
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
            Text('Foto kilometraje'),
            Stack(
              children: [
                BoardImage(
                  url: inspeccionProvider.pathFileKilometraje,
                ),
                Positioned(
                    right: 15,
                    bottom: 10,
                    child: IconButton(
                      onPressed: () async {
                        final _picker = ImagePicker();
                        final XFile? photo =
                            await _picker.pickImage(source: ImageSource.camera);

                        if (photo == null) {
                          return;
                        }
                        inspeccionProvider.updateSelectedImage(photo.path);
                      },
                      icon: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 45,
                      ),
                    ))
              ],
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
                  if (value == null) return 'Cantidad de galones';
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
            if (inspeccionProvider.tieneGuia) _guiaTransporte(),
            const SizedBox(
              height: 10,
            ),
            // MaterialStateProperty.all<Color>(Colors.green)
            ElevatedButton(
              style: ButtonStyle(
                  elevation: MaterialStateProperty.all<double>(10),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.symmetric(horizontal: 20)),
                  minimumSize: MaterialStateProperty.all<Size>(Size.square(50)),
                  textStyle: MaterialStateProperty.all<TextStyle>(
                      TextStyle(fontSize: 16))),
              onPressed: () async {
                if (!inspeccionProvider.isValidForm()) return;

                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) {
                      return Scaffold(
                        appBar: AppBar(),
                        body: ItemsInspeccionar(),
                      );
                    },
                  ),
                );
              },
              child: const Text('Realizar inspección'),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
