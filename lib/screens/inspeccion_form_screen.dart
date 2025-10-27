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
  int? _gpsDepartmentId;
  bool _isLoadingLocation = false;
  String _locationError = '';
  bool _cityFoundByGPS = false; // Indica si la ciudad fue encontrada por GPS

  bool isValidForm() {
    return formKey.currentState?.validate() ?? false;
  }

  /// Muestra bottom sheet para seleccionar fuente de imagen
  void _showImageSourceBottomSheet(
    BuildContext context, {
    required String tipo,
    required Function(String path) onImageSelected,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Theme.of(context).cardColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Seleccionar $tipo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Icon(
                    Icons.camera_alt,
                    size: 28,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: const Text('Tomar foto'),
                  subtitle: const Text('Usar la cámara del dispositivo'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _selectImageFromSource(
                      ImageSource.camera,
                      tipo,
                      onImageSelected,
                    );
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.photo_library,
                    size: 28,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: const Text('Galería'),
                  subtitle: const Text('Seleccionar de la galería'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _selectImageFromSource(
                      ImageSource.gallery,
                      tipo,
                      onImageSelected,
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      );
    });
  }

  /// Selecciona una imagen desde la fuente especificada
  Future<void> _selectImageFromSource(
    ImageSource source,
    String tipo,
    Function(String path) onImageSelected,
  ) async {
    try {
      final _picker = ImagePicker();
      print('[pick] solicitando $tipo desde ${source == ImageSource.camera ? "cámara" : "galería"}...');
      
      final XFile? photo = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1080,
        maxHeight: 1080,
      );

      if (photo == null) {
        print('[pick] cancelado $tipo');
        return;
      }

      try {
        print(
            '[pick] $tipo path=${photo.path} size=${await File(photo.path).length()} bytes');
      } catch (_) {}

      onImageSelected(photo.path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Imagen seleccionada correctamente'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error al seleccionar $tipo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Obtiene la ubicación GPS actual y busca la ciudad correspondiente
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = '';
    });

    try {
      // Verificar si el servicio de ubicación está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError = 'El servicio de ubicación está deshabilitado';
          _isLoadingLocation = false;
        });
        _showLocationServiceDisabledDialog(context);
        return;
      }

      // Verificar permisos de ubicación
      LocationPermission permission = await Geolocator.checkPermission();

      // Si el permiso está denegado permanentemente, primero mostrar opciones para abrir configuración
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = 'Permisos de ubicación denegados permanentemente';
          _isLoadingLocation = false;
        });
        _showPermissionDeniedForeverDialog(context);
        return;
      }

      // Si el permiso está denegado, solicitarlo
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          setState(() {
            _locationError = 'Permisos de ubicación denegados';
            _isLoadingLocation = false;
          });
          _showPermissionDeniedDialog(context);
          return;
        }

        // Si después de solicitar el permiso, este fue denegado permanentemente
        if (permission == LocationPermission.deniedForever) {
          setState(() {
            _locationError = 'Permisos de ubicación denegados permanentemente';
            _isLoadingLocation = false;
          });
          _showPermissionDeniedForeverDialog(context);
          return;
        }
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

      // Mostrar diálogo de error
      if (mounted) {
        _showErrorDialog(
            context, 'Error al obtener ubicación: ${e.toString()}');
      }
    }
  }

  /// Muestra un diálogo de error genérico
  Future<void> _showErrorDialog(BuildContext context, String message) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Muestra un diálogo cuando el permiso de ubicación está denegado
  Future<void> _showPermissionDeniedDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permisos de ubicación requeridos'),
          content: const Text(
            'La aplicación necesita acceso a tu ubicación para determinar automáticamente la ciudad de inspección. '
            'Por favor, permite el acceso a la ubicación en la configuración de la aplicación.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Intentar solicitar permiso nuevamente
                _getCurrentLocation();
              },
              child: const Text('Reintentar'),
            ),
          ],
        );
      },
    );
  }

  /// Muestra un diálogo cuando el permiso está denegado permanentemente
  Future<void> _showPermissionDeniedForeverDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permisos de ubicación denegados permanentemente'),
          content: const Text(
            'El acceso a la ubicación ha sido denegado permanentemente. '
            'Para habilitar la funcionalidad de ubicación automática, '
            'por favor abre la configuración de la aplicación y permite el acceso a la ubicación.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Abrir configuración de la aplicación
                await Geolocator.openAppSettings();
              },
              child: const Text('Abrir configuración'),
            ),
          ],
        );
      },
    );
  }

  /// Muestra un diálogo cuando el servicio de ubicación está deshabilitado
  Future<void> _showLocationServiceDisabledDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Servicio de ubicación deshabilitado'),
          content: const Text(
            'El servicio de ubicación del dispositivo está deshabilitado. '
            'Por favor, habilita el GPS en la configuración del dispositivo para usar esta funcionalidad.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Abrir configuración del dispositivo
                await Geolocator.openLocationSettings();
              },
              child: const Text('Abrir configuración'),
            ),
          ],
        );
      },
    );
  }

  /// Busca la ciudad en la base de datos SQLite local directamente
  Future<void> _findCityInDatabase(String cityName) async {
    try {
      // Buscar ciudad directamente en SQLite sin filtro de departamento
      List<Ciudades> ciudades = await DBProvider.db.getAllCiudades();

      // Buscar ciudad por nombre (case insensitive)
      Ciudades? foundCity;
      try {
        foundCity = ciudades.firstWhere(
          (city) =>
              city.label.toLowerCase().contains(cityName.toLowerCase()) ||
              cityName.toLowerCase().contains(city.label.toLowerCase()),
        );
      } catch (e) {
        // No se encontró la ciudad
        foundCity = null;
      }

      if (foundCity != null && foundCity.value != 0) {
        setState(() {
          _gpsCity = foundCity!.label;
          _gpsCityId = foundCity.value;
          _gpsDepartmentId = foundCity.idDepartamento;
          _cityFoundByGPS = true;
          _isLoadingLocation = false;
        });

        // Actualizar el servicio de inspección
        final inspeccionService =
            Provider.of<InspeccionService>(context, listen: false);
        inspeccionService.resumePreoperacional.idCiudad = foundCity.value;
        inspeccionService.resumePreoperacional.ciudad = foundCity.label;

        // Cargar las ciudades del departamento encontrado y preseleccionar el departamento
        if (_gpsDepartmentId != null) {
          // Cargar las ciudades del departamento encontrado
          final inspeccionProvider =
              Provider.of<InspeccionProvider>(context, listen: false);
          inspeccionProvider.listarCiudades(_gpsDepartmentId!);
        }

        // Guardar coordenadas GPS
        if (_currentPosition != null) {
          inspeccionService.resumePreoperacional.positionGps = jsonEncode({
            'latitude': _currentPosition!.latitude,
            'longitude': _currentPosition!.longitude,
          });
        }

        print(
            '[GPS] Ciudad encontrada: ${foundCity.label} (ID: ${foundCity.value}, Departamento: ${foundCity.idDepartamento})');
      } else {
        setState(() {
          _locationError =
              'Ciudad "$cityName" no encontrada en la base de datos. Por favor, selecciona manualmente.';
          _cityFoundByGPS = false;
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
                  value: _cityFoundByGPS && _gpsDepartmentId != null
                      ? _gpsDepartmentId
                      : null,
                  validator: (value) {
                    // Si la ciudad fue encontrada por GPS, no validar el departamento
                    if (_cityFoundByGPS) return null;
                    if (value == null) return 'Seleccione un departamento';
                    return null;
                  },
                  items: inspeccionProvider.departamentos.map((e) {
                    return DropdownMenuItem(
                      child: Text(e.label),
                      value: e.value,
                    );
                  }).toList(),
                  onChanged: _cityFoundByGPS
                      ? null // Deshabilitar si la ciudad fue encontrada por GPS
                      : (value) {
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
                    // Mensaje informativo cuando la ciudad fue encontrada por GPS
                    if (_cityFoundByGPS && _gpsCity != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Ubicación determinada automáticamente por GPS',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.3),
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
                                  .withValues(alpha: 0.7),
                              size: 14,
                            ),
                          ],
                        ),
                      )
                    else if (_locationError.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.3),
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
                          color: Theme.of(context)
                              .dividerColor
                              .withValues(alpha: 0.1),
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
                            Expanded(
                              child: Text(
                                'Presiona el botón de ubicación para obtener la ciudad automáticamente',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
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
                            _showImageSourceBottomSheet(
                              context,
                              tipo: 'foto kilometraje',
                              onImageSelected: (path) {
                                inspeccionService.resumePreoperacional.urlFotoKm =
                                    path;
                                inspeccionProvider.updateSelectedImage(path);
                              },
                            );
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
                            _showImageSourceBottomSheet(
                              context,
                              tipo: 'foto cabezote',
                              onImageSelected: (path) {
                                inspeccionService.resumePreoperacional
                                    .urlFotoCabezote = path;
                                inspeccionProvider.updateCabezoteImage(path);
                              },
                            );
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
