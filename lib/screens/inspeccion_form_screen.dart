import 'package:app_qinspecting/services/login_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/screens/screens.dart';
import 'package:app_qinspecting/services/inspeccion_service.dart';
import 'package:app_qinspecting/ui/input_decorations.dart';
import 'package:app_qinspecting/widgets/widgets.dart';

class InspeccionForm extends StatelessWidget {
  const InspeccionForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inspeccionProvider = Provider.of<InspeccionProvider>(context);
    final inspeccionService = Provider.of<InspeccionService>(context);
    final loginService = Provider.of<LoginService>(context);
    final uiProvider = Provider.of<UiProvider>(context);
    // GlobalKey<FormState> _abcKey = GlobalKey<FormState>();

    inspeccionService.resumePreoperacional.base =
        loginService.selectedEmpresa.nombreBase!;

    Widget _guiaTransporte() {
      return inspeccionProvider.tieneGuia
          ? Column(
              children: [
                TextFormField(
                  autocorrect: false,
                  keyboardType: TextInputType.text,
                  onChanged: (value) {
                    inspeccionService.resumePreoperacional.resuPreGuia = value;
                  },
                  validator: (value) {
                    if (value!.isEmpty) return 'Ingrese la guía de transporte';
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

                            inspeccionService.resumePreoperacional
                                .resuPreFotoguia = photo.path;
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
        DropdownButtonFormField<String>(
            decoration: InputDecorations.authInputDecorations(
                prefixIcon: Icons.local_shipping,
                hintText: '',
                labelText: 'Placa del remolque'),
            validator: (value) {
              if (value == null) return 'Seleccione una placa';
              return null;
            },
            items: inspeccionProvider.remolques.map((e) {
              return DropdownMenuItem(
                child: Text(e.placa),
                value: e.placa,
              );
            }).toList(),
            onChanged: (value) async {
              final resultRemolque =
                  await DBProvider.db.getRemolqueByPlate(value!);
              inspeccionService.resumePreoperacional.remolId =
                  resultRemolque!.idRemolque;
              inspeccionProvider.updateRemolqueSelected(resultRemolque);

              await inspeccionProvider.listarCategoriaItemsRemolque();
            }),
        inspeccionProvider.remolqueSelected == null
            ? Container()
            : Column(
                children: [
                  ListTile(
                    dense: true,
                    shape: Border(bottom: BorderSide(color: Colors.green)),
                    title: Text('Color', style: TextStyle(fontSize: 15)),
                    subtitle: Text(
                        inspeccionProvider.remolqueSelected!.color.toString(),
                        style: TextStyle(fontSize: 15)),
                  ),
                  ListTile(
                    dense: true,
                    shape: Border(bottom: BorderSide(color: Colors.green)),
                    title: Text('Marca del remolque',
                        style: TextStyle(fontSize: 15)),
                    subtitle: Text(
                        inspeccionProvider.remolqueSelected!.marca.toString(),
                        style: TextStyle(fontSize: 15)),
                  ),
                  ListTile(
                    dense: true,
                    shape: Border(bottom: BorderSide(color: Colors.green)),
                    title: Text('Modelo del remolque',
                        style: TextStyle(fontSize: 15)),
                    subtitle: Text(
                        inspeccionProvider.remolqueSelected!.modelo.toString(),
                        style: TextStyle(fontSize: 15)),
                  ),
                  ListTile(
                    dense: true,
                    shape: Border(bottom: BorderSide(color: Colors.green)),
                    title: Text('Matrícula del remolque',
                        style: TextStyle(fontSize: 15)),
                    subtitle: Text(
                        inspeccionProvider.remolqueSelected!.matricula
                            .toString(),
                        style: TextStyle(fontSize: 15)),
                  ),
                  ListTile(
                    dense: true,
                    shape: Border(bottom: BorderSide(color: Colors.green)),
                    title: Text('Número de ejes del remolque',
                        style: TextStyle(fontSize: 15)),
                    subtitle: Text(
                        inspeccionProvider.remolqueSelected!.numeroEjes
                            .toString(),
                        style: TextStyle(fontSize: 15)),
                  )
                ],
              )
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

    if (inspeccionProvider.vehiculos.isEmpty) return const LoadingScreen();

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: uiProvider.selectedMenuOpt == 1 ? 0 : 15),
      child: SingleChildScrollView(
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

                    inspeccionService.resumePreoperacional.vehId =
                        resultVehiculo!.idVehiculo;
                    inspeccionProvider.updateVehiculoSelected(resultVehiculo);

                    await inspeccionProvider.listarCategoriaItemsVehiculo();
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
                    inspeccionService.resumePreoperacional.ciuId =
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
                onChanged: (value) {
                  inspeccionService.resumePreoperacional.resuPreKilometraje =
                      value.isEmpty ? 0 : int.parse(value);
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
                          final XFile? photo = await _picker.pickImage(
                              source: ImageSource.camera);

                          if (photo == null) {
                            return;
                          }
                          inspeccionService.resumePreoperacional.resuPreFotokm =
                              photo.path;
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
                  onChanged: (value) {
                    inspeccionProvider.updateTieneRemolque(value);
                    inspeccionProvider.listarRemolques();
                  }),
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
                    if (value!.isEmpty) return 'Ingrese galones tanqueados';
                    return null;
                  },
                  onChanged: (value) {
                    inspeccionService.resumePreoperacional.tanqueGalones =
                        value.isEmpty ? 0 : int.parse(value);
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
                    minimumSize:
                        MaterialStateProperty.all<Size>(Size.square(50)),
                    textStyle: MaterialStateProperty.all<TextStyle>(
                        TextStyle(fontSize: 16))),
                child: const Text('Realizar inspección'),
                onPressed: () async {
                  if (!inspeccionProvider.isValidForm()) return;
                  if (inspeccionProvider.pathFileKilometraje == null ||
                      inspeccionProvider.pathFileGuia == null) {
                    String message =
                        inspeccionProvider.pathFileKilometraje == null
                            ? 'Ingrese foto del kilometraje!'
                            : 'Ingrese foto de la guía';
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(message),
                      duration: const Duration(seconds: 2),
                      width: 280.0, // Width of the SnackBar.
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, // Inner padding for SnackBar content.
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ));
                    return;
                  }
                  var now = DateTime.now();
                  var formatter = DateFormat('yyyy-MM-dd hh:mm a');
                  String formattedDate = formatter.format(now);
                  inspeccionService.resumePreoperacional.resuPreFecha =
                      formattedDate;
                  inspeccionService.resumePreoperacional.persNumeroDoc =
                      loginService.userDataLogged.usuarioUser!;
                  Navigator.pushNamed(context, 'inspeccion_vehiculo');
                },
              ),
              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
