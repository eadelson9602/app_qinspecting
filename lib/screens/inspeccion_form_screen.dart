import 'package:app_qinspecting/models/departamentos_ciudad.dart';
import 'package:app_qinspecting/services/login_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/services/inspeccion_service.dart';
import 'package:app_qinspecting/ui/input_decorations.dart';
import 'package:app_qinspecting/widgets/widgets.dart';

class InspeccionForm extends StatefulWidget {
  InspeccionForm({Key? key}) : super(key: key);

  @override
  State<InspeccionForm> createState() => _InspeccionFormState();
}

class _InspeccionFormState extends State<InspeccionForm> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isValidForm() {
    return formKey.currentState?.validate() ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final inspeccionProvider = Provider.of<InspeccionProvider>(context);
    final inspeccionService =
        Provider.of<InspeccionService>(context, listen: false);
    final loginService = Provider.of<LoginService>(context, listen: false);

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
                    inspeccionService.resumePreoperacional.numeroGuia = value;
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
                  height: 16,
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

                            inspeccionService.resumePreoperacional.urlFotoGuia =
                                photo.path;
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
        const SizedBox(
          height: 16,
        ),
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
              inspeccionService.resumePreoperacional.placaRemolque = value;
              inspeccionProvider.updateRemolqueSelected(resultRemolque!);

              await inspeccionProvider.listarCategoriaItemsRemolque(value);
            }),
        const SizedBox(
          height: 16,
        ),
        Text('Foto Remolque'),
        Stack(
          children: [
            BoardImage(url: inspeccionProvider.pathFileRemolque),
            Positioned(
                right: 15,
                bottom: 10,
                child: IconButton(
                  onPressed: () async {
                    final reponsePermission =
                        await inspeccionProvider.requestCameraPermission();
                    if (reponsePermission) {
                      final _picker = ImagePicker();
                      final XFile? photo =
                          await _picker.pickImage(source: ImageSource.camera);
                      if (photo == null) {
                        return;
                      }
                      inspeccionService.resumePreoperacional.urlFotoRemolque =
                          photo.path;
                      inspeccionProvider.updateRemolqueImage(photo.path);
                    }
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
          height: 16,
        ),
        if (inspeccionProvider.remolqueSelected != null)
          Column(
            children: [
              ListTile(
                  dense: true,
                  shape: Border(bottom: BorderSide(color: Colors.green)),
                  title: Text('Color', style: TextStyle(fontSize: 15)),
                  subtitle: Text(
                      inspeccionProvider.remolqueSelected!.color.toString(),
                      style: TextStyle(fontSize: 15))),
              ListTile(
                  dense: true,
                  shape: Border(bottom: BorderSide(color: Colors.green)),
                  title: Text('Marca del remolque',
                      style: TextStyle(fontSize: 15)),
                  subtitle: Text(
                      inspeccionProvider.remolqueSelected!.nombreMarca
                          .toString(),
                      style: TextStyle(fontSize: 15))),
              ListTile(
                  dense: true,
                  shape: Border(bottom: BorderSide(color: Colors.green)),
                  title: Text('Modelo del remolque',
                      style: TextStyle(fontSize: 15)),
                  subtitle: Text(
                      inspeccionProvider.remolqueSelected!.modelo.toString(),
                      style: TextStyle(fontSize: 15))),
              ListTile(
                  dense: true,
                  shape: Border(bottom: BorderSide(color: Colors.green)),
                  title: Text('Matrícula del remolque',
                      style: TextStyle(fontSize: 15)),
                  subtitle: Text(
                      inspeccionProvider.remolqueSelected!.numeroMatricula
                          .toString(),
                      style: TextStyle(fontSize: 15))),
              ListTile(
                  dense: true,
                  shape: Border(bottom: BorderSide(color: Colors.green)),
                  title: Text('Número de ejes del remolque',
                      style: TextStyle(fontSize: 15)),
                  subtitle: Text(
                      inspeccionProvider.remolqueSelected!.numeroEjes
                          .toString(),
                      style: TextStyle(fontSize: 15)))
            ],
          ),
        const SizedBox(
          height: 10,
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
                      inspeccionProvider.vehiculoSelected!.nombreMarca,
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
                  title: Text('Color de cabezote'),
                  subtitle: Text(
                      inspeccionProvider.vehiculoSelected!.color.toString(),
                      style: TextStyle(fontSize: 15)),
                ),
              ],
            );
    }

    return Container(
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              const SizedBox(
                height: 16,
              ),
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
                    inspeccionService.resumePreoperacional.placa = value;
                    inspeccionService.resumePreoperacional.placaVehiculo =
                        value;
                    inspeccionProvider.updateVehiculoSelected(resultVehiculo!);

                    await inspeccionProvider
                        .listarCategoriaItemsVehiculo(resultVehiculo.placa);
                  }),
              _infoVehiculo(),
              const SizedBox(
                height: 16,
              ),
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
                height: 16,
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
                    Ciudades ciudad = inspeccionProvider.ciudades
                        .firstWhere((element) => element.value == value);
                    inspeccionService.resumePreoperacional.idCiudad =
                        int.parse(value.toString());
                    inspeccionService.resumePreoperacional.ciudad =
                        ciudad.label;
                  }),
              const SizedBox(
                height: 16,
              ),
              TextFormField(
                autocorrect: false,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Ingrese kilometraje';
                  return null;
                },
                onChanged: (value) {
                  inspeccionService.resumePreoperacional.kilometraje =
                      value.isEmpty ? 0 : int.parse(value);
                },
                decoration: InputDecorations.authInputDecorations(
                    hintText: '',
                    labelText: 'Kilometraje',
                    prefixIcon: Icons.speed),
              ),
              const SizedBox(
                height: 16,
              ),
              Text('Foto kilometraje'),
              Stack(
                children: [
                  BoardImage(url: inspeccionProvider.pathFileKilometraje),
                  Positioned(
                      right: 15,
                      bottom: 10,
                      child: IconButton(
                        onPressed: () async {
                          final reponsePermission = await inspeccionProvider
                              .requestCameraPermission();
                          if (reponsePermission) {
                            final _picker = ImagePicker();
                            final XFile? photo = await _picker.pickImage(
                                source: ImageSource.camera);
                            if (photo == null) {
                              return;
                            }
                            inspeccionService.resumePreoperacional.urlFotoKm =
                                photo.path;
                            inspeccionProvider.updateSelectedImage(photo.path);
                          }
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
                height: 16,
              ),
              Text('Foto Cabezote'),
              Stack(
                children: [
                  BoardImage(url: inspeccionProvider.pathFileCabezote),
                  Positioned(
                      right: 15,
                      bottom: 10,
                      child: IconButton(
                        onPressed: () async {
                          final reponsePermission = await inspeccionProvider
                              .requestCameraPermission();
                          if (reponsePermission) {
                            final _picker = ImagePicker();
                            final XFile? photo = await _picker.pickImage(
                                source: ImageSource.camera);
                            if (photo == null) {
                              return;
                            }
                            inspeccionService.resumePreoperacional
                                .urlFotoCabezote = photo.path;
                            inspeccionProvider.updateCabezoteImage(photo.path);
                          }
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
                    inspeccionProvider.listarRemolques(
                        loginService.selectedEmpresa.nombreBase!);
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
                    inspeccionService.resumePreoperacional.cantTanqueoGalones =
                        value.isEmpty ? 0 : int.parse(value);
                  },
                  decoration: InputDecorations.authInputDecorations(
                      hintText: '',
                      labelText: 'Cantidad de galones tanqueados',
                      prefixIcon: Icons.speed),
                ),
              if (inspeccionProvider.tieneRemolque) _infoRemolque(),
              if (inspeccionProvider.tieneGuia) _guiaTransporte(),
              const SizedBox(
                height: 10,
              ),
              // MaterialStateProperty.all<Color>(Colors.green)
              ElevatedButton(
                style: ButtonStyle(
                  elevation: WidgetStateProperty.all<double>(10),
                  padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.symmetric(horizontal: 20),
                  ),
                  minimumSize: WidgetStateProperty.all<Size>(Size.square(50)),
                  textStyle: WidgetStateProperty.all<TextStyle>(
                    TextStyle(fontSize: 16),
                  ),
                ),
                child: const Text('Realizar inspección'),
                onPressed: () async {
                  if (!isValidForm()) return;

                  if (inspeccionProvider.pathFileKilometraje == null ||
                      (inspeccionProvider.tieneGuia &&
                          inspeccionProvider.pathFileGuia == null)) {
                    String message =
                        inspeccionProvider.pathFileKilometraje == null
                            ? 'Ingrese foto del kilometraje!'
                            : 'Ingrese foto de la guía';
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black),
                      ),
                      duration: const Duration(seconds: 2),
                      width: 280.0,
                      padding: const EdgeInsets.all(10),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                    ));
                    return;
                  }

                  var now = DateTime.now();
                  var formatter = DateFormat('yyyy-MM-dd hh:mm');
                  String formattedDate = formatter.format(now);

                  inspeccionService.resumePreoperacional.fechaPreoperacional =
                      formattedDate;
                  inspeccionService.resumePreoperacional.usuarioPreoperacional =
                      loginService.userDataLogged.numeroDocumento!;

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
