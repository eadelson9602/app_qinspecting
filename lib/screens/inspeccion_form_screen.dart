import 'package:app_qinspecting/models/departamentos_ciudad.dart';
import 'dart:io';
import 'package:app_qinspecting/services/login_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:convert';

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

  // Variables para GPS
  Position? _currentPosition;
  String? _gpsCity;
  int? _gpsCityId;
  bool _isLoadingLocation = false;
  String _locationError = '';

  bool isValidForm() {
    return formKey.currentState?.validate() ?? false;
  }

  /// Obtiene la ubicación GPS actual y busca la ciudad correspondiente
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = '';
    });

    try {
      // Verificar permisos de ubicación
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationError = 'Permisos de ubicación denegados';
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = 'Permisos de ubicación denegados permanentemente';
          _isLoadingLocation = false;
        });
        return;
      }

      // Obtener ubicación actual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
      });

      // Obtener dirección desde coordenadas
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String cityName = place.locality ?? place.administrativeArea ?? '';

        if (cityName.isNotEmpty) {
          // Buscar la ciudad en la base de datos local
          await _findCityInDatabase(cityName);
        } else {
          setState(() {
            _locationError = 'No se pudo determinar la ciudad';
            _isLoadingLocation = false;
          });
        }
      } else {
        setState(() {
          _locationError = 'No se encontró información de ubicación';
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      setState(() {
        _locationError = 'Error al obtener ubicación: $e';
        _isLoadingLocation = false;
      });
    }
  }

  /// Busca la ciudad en la base de datos SQLite local
  Future<void> _findCityInDatabase(String cityName) async {
    try {
      final inspeccionProvider =
          Provider.of<InspeccionProvider>(context, listen: false);

      // Buscar ciudad por nombre (case insensitive)
      Ciudades? foundCity = inspeccionProvider.ciudades.firstWhere(
        (city) =>
            city.label.toLowerCase().contains(cityName.toLowerCase()) ||
            cityName.toLowerCase().contains(city.label.toLowerCase()),
        orElse: () => Ciudades(value: 0, label: '', idDepartamento: 0),
      );

      if (foundCity.value != 0) {
        setState(() {
          _gpsCity = foundCity.label;
          _gpsCityId = foundCity.value;
          _isLoadingLocation = false;
        });

        // Actualizar el servicio de inspección
        final inspeccionService =
            Provider.of<InspeccionService>(context, listen: false);
        inspeccionService.resumePreoperacional.idCiudad = foundCity.value;
        inspeccionService.resumePreoperacional.ciudad = foundCity.label;

        // Guardar coordenadas GPS
        if (_currentPosition != null) {
          inspeccionService.resumePreoperacional.positionGps = jsonEncode({
            'latitude': _currentPosition!.latitude,
            'longitude': _currentPosition!.longitude,
          });
        }

        print(
            '[GPS] Ciudad encontrada: ${foundCity.label} (ID: ${foundCity.value})');
      } else {
        setState(() {
          _locationError =
              'Ciudad "$cityName" no encontrada en la base de datos';
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      setState(() {
        _locationError = 'Error al buscar ciudad: $e';
        _isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final inspeccionProvider = Provider.of<InspeccionProvider>(context);
    final inspeccionService =
        Provider.of<InspeccionService>(context, listen: false);
    final loginService = Provider.of<LoginService>(context, listen: false);

    inspeccionService.resumePreoperacional.base =
        loginService.selectedEmpresa.nombreBase!;

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
                      labelText: 'Placa del vehículo',
                      context: context),
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
              InfoVehiculoWidget(),
              const SizedBox(
                height: 16,
              ),
              DropdownButtonFormField<int>(
                  decoration: InputDecorations.authInputDecorations(
                      prefixIcon: Icons.place,
                      hintText: '',
                      labelText: 'Departamento de inspección',
                      context: context),
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
              // Campo de ciudad automático por GPS
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_city,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Ciudad de inspección',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        if (_isLoadingLocation)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          IconButton(
                            onPressed: _getCurrentLocation,
                            icon: Icon(
                              Icons.my_location,
                              color: Theme.of(context).primaryColor,
                              size: 20,
                            ),
                            tooltip: 'Obtener ubicación actual',
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_gpsCity != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Theme.of(context).primaryColor,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _gpsCity!,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.lock,
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.7),
                              size: 14,
                            ),
                          ],
                        ),
                      )
                    else if (_locationError.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _locationError,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).dividerColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_off,
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Presiona el botón de ubicación para obtener la ciudad automáticamente',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
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
                    prefixIcon: Icons.speed,
                    context: context),
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                'Foto kilometraje',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
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
                            print('[pick] solicitando foto kilometraje...');
                            final XFile? photo = await _picker.pickImage(
                                source: ImageSource.camera,
                                imageQuality: 70,
                                maxWidth: 1080,
                                maxHeight: 1080);
                            if (photo == null) {
                              print('[pick] cancelado foto kilometraje');
                              return;
                            }
                            try {
                              print(
                                  '[pick] kilometraje path=${photo.path} size=${await File(photo.path).length()} bytes');
                            } catch (_) {}
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
              Text(
                'Foto Cabezote',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
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
                            print('[pick] solicitando foto cabezote...');
                            final XFile? photo = await _picker.pickImage(
                                source: ImageSource.camera,
                                imageQuality: 70,
                                maxWidth: 1080,
                                maxHeight: 1080);
                            if (photo == null) {
                              print('[pick] cancelado foto cabezote');
                              return;
                            }
                            try {
                              print(
                                  '[pick] cabezote path=${photo.path} size=${await File(photo.path).length()} bytes');
                            } catch (_) {}
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
              if (inspeccionProvider.tieneRemolque) InfoRemolqueWidget(),
              if (inspeccionProvider.tieneGuia) GuiaTransporteWidget(),
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
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyLarge?.color),
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
