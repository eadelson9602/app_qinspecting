import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/ui/input_decorations.dart';
import 'package:app_qinspecting/ui/app_theme.dart';
import 'package:app_qinspecting/widgets/widgets.dart';

class InspeccionForm extends StatefulWidget {
  InspeccionForm({Key? key}) : super(key: key);

  @override
  State<InspeccionForm> createState() => _InspeccionFormState();
}

class _InspeccionFormState extends State<InspeccionForm> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Variables para GPS
  String? _gpsCity;
  int? _gpsCityId;
  int? _gpsDepartmentId;
  bool _isLoadingLocation = false;
  String _locationError = '';
  bool _cityFoundByGPS = false; // Indica si la ciudad fue encontrada por GPS
  bool _hasGpsError = false; // Indica si hubo error al obtener la ubicación GPS

  // Variable para controlar la placa seleccionada
  String? _selectedPlacaVehiculo;

  // Instancia del servicio de ubicación
  final LocationService _locationService = LocationService();

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
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (modalContext) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Seleccionar $tipo',
                style: Theme.of(modalContext).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryGreen,
                    ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: PhotoOptionButton(
                      icon: Icons.camera_alt,
                      label: 'Cámara',
                      onTap: () {
                        Navigator.pop(modalContext);
                        _selectImageFromSource(
                          ImageSource.camera,
                          tipo,
                          onImageSelected,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: PhotoOptionButton(
                      icon: Icons.photo_library,
                      label: 'Galería',
                      onTap: () {
                        Navigator.pop(modalContext);
                        _selectImageFromSource(
                          ImageSource.gallery,
                          tipo,
                          onImageSelected,
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(modalContext),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                          color: Theme.of(modalContext).dividerColor),
                    ),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  /// Flujo: solicitar permisos primero y luego abrir el bottom sheet
  Future<void> _onCapturePhoto(
    String tipo,
    Function(String path) onImageSelected,
  ) async {
    // Mostrar directamente el bottom sheet; los permisos se solicitan según la fuente elegida
    _showImageSourceBottomSheet(
      context,
      tipo: tipo,
      onImageSelected: onImageSelected,
    );
  }

  /// Selecciona una imagen desde la fuente especificada
  Future<void> _selectImageFromSource(
    ImageSource source,
    String tipo,
    Function(String path) onImageSelected,
  ) async {
    try {
      // Request ONLY the permission required for the selected source to avoid fallbacks
      if (source == ImageSource.camera) {
        var cameraStatus = await Permission.camera.status;
        if (cameraStatus != PermissionStatus.granted) {
          cameraStatus = await Permission.camera.request();
          if (cameraStatus != PermissionStatus.granted) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Permiso de cámara denegado'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 2),
              ));
            }
            return;
          }
        }
      } else {
        // Gallery/photos
        try {
          var photosStatus = await Permission.photos.status;
          if (photosStatus != PermissionStatus.granted) {
            photosStatus = await Permission.photos.request();
            if (photosStatus != PermissionStatus.granted) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Permiso de fotos/galería denegado'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 2),
                ));
              }
              return;
            }
          }
        } catch (_) {
          // Fallback para Android < 13
          var storageStatus = await Permission.storage.status;
          if (storageStatus != PermissionStatus.granted) {
            storageStatus = await Permission.storage.request();
            if (storageStatus != PermissionStatus.granted) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Permiso de almacenamiento denegado'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 2),
                ));
              }
              return;
            }
          }
        }
      }

      // Verificar que el widget sigue montado antes de abrir la cámara
      if (!mounted) {
        print('[pick] Widget no montado, cancelando selección de $tipo');
        return;
      }

      final _picker = ImagePicker();
      print(
          '[pick] solicitando $tipo desde ${source == ImageSource.camera ? "cámara" : "galería"}...');

      // Capturar la foto - puede tomar tiempo y la app puede ir a segundo plano
      final XFile? photo = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1080,
        maxHeight: 1080,
      );

      // Verificar nuevamente que el widget sigue montado después de la cámara
      if (!mounted) {
        print('[pick] Widget no montado después de seleccionar $tipo');
        return;
      }

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
          const SnackBar(
            content: Text('Imagen seleccionada correctamente'),
            duration: Duration(seconds: 2),
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
      _hasGpsError = false;
    });

    try {
      final result = await _locationService.getCurrentLocation();

      if (result.success) {
        print('[INSPECCION FORM] _gpsCityId: $_gpsCityId');
        // Ciudad encontrada
        setState(() {
          _gpsCity = result.cityName!;
          _gpsCityId = result.cityId!;
          _gpsDepartmentId = result.departmentId!;
          _cityFoundByGPS = true;
          _isLoadingLocation = false;
        });

        // Actualizar el servicio de inspección
        final inspeccionService =
            Provider.of<InspeccionService>(context, listen: false);
        inspeccionService.resumePreoperacional.idCiudad = result.cityId!;
        inspeccionService.resumePreoperacional.ciudad = result.cityName!;

        // Guardar coordenadas GPS
        if (result.positionGpsJson != null) {
          inspeccionService.resumePreoperacional.positionGps =
              result.positionGpsJson;
        }

        // Cargar las ciudades del departamento encontrado
        if (result.departmentId != null) {
          final inspeccionProvider =
              Provider.of<InspeccionProvider>(context, listen: false);
          inspeccionProvider.listarCiudades(result.departmentId!);
        }
      } else {
        // Error al obtener ubicación
        setState(() {
          _locationError = result.error ?? 'Error desconocido';
          _cityFoundByGPS = false;
          _isLoadingLocation = false;
          _hasGpsError = true;
        });
      }
    } catch (e) {
      setState(() {
        _locationError = 'Error al obtener ubicación: $e';
        _isLoadingLocation = false;
        _hasGpsError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final inspeccionProvider = Provider.of<InspeccionProvider>(context);
    final inspeccionService =
        Provider.of<InspeccionService>(context, listen: false);
    final loginService = Provider.of<LoginService>(context, listen: false);

    if (loginService.selectedEmpresa.nombreBase == null ||
        loginService.selectedEmpresa.nombreBase!.isEmpty) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.orange,
            ),
            SizedBox(height: 16),
            Text(
              'No se pudo cargar la información de la empresa',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
          ],
        ),
      );
    }

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
                  value: _selectedPlacaVehiculo,
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
                    setState(() {
                      _selectedPlacaVehiculo = value;
                    });

                    if (value == null) {
                      // Si se deselecciona, limpiar toda la información del vehículo
                      inspeccionService.resumePreoperacional.placa = null;
                      inspeccionService.resumePreoperacional.placaVehiculo =
                          null;
                      inspeccionProvider.updateVehiculoSelected(null);
                    } else {
                      final resultVehiculo =
                          await DBProvider.db.getVehiculoByPlate(value);
                      inspeccionService.resumePreoperacional.placa = value;
                      inspeccionService.resumePreoperacional.placaVehiculo =
                          value;
                      inspeccionProvider
                          .updateVehiculoSelected(resultVehiculo!);

                      await inspeccionProvider
                          .listarCategoriaItemsVehiculo(resultVehiculo.placa);
                    }
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
                  onChanged: !_hasGpsError
                      ? null // Deshabilitar si NO hay error de GPS (GPS funcionó correctamente)
                      : (value) {
                          inspeccionProvider.listarCiudades(value!);
                        }),
              const SizedBox(height: 16),
              GpsLocationField(
                isLoadingLocation: _isLoadingLocation,
                gpsCity: _gpsCity,
                locationError: _locationError,
                cityFoundByGPS: _cityFoundByGPS,
                onGetLocation: _getCurrentLocation,
              ),
              // Select de ciudad manual (solo se muestra si hay error de GPS)
              if (_hasGpsError && !_cityFoundByGPS) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: InputDecorations.authInputDecorations(
                    prefixIcon: Icons.location_city,
                    hintText: '',
                    labelText: 'Ciudad de inspección',
                    context: context,
                  ),
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
                    if (value != null) {
                      final ciudad = inspeccionProvider.ciudades
                          .firstWhere((c) => c.value == value);
                      inspeccionService.resumePreoperacional.idCiudad = value;
                      inspeccionService.resumePreoperacional.ciudad =
                          ciudad.label;
                    }
                  },
                ),
              ],
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
              PhotoSection(
                title: 'Foto kilometraje',
                imageUrl: inspeccionProvider.pathFileKilometraje,
                onCapturePhoto: () {
                  _onCapturePhoto('foto kilometraje', (path) {
                    inspeccionService.resumePreoperacional.urlFotoKm = path;
                    inspeccionProvider.updateSelectedImage(path);
                  });
                },
              ),
              const SizedBox(height: 16),
              PhotoSection(
                title: 'Foto Cabezote',
                imageUrl: inspeccionProvider.pathFileCabezote,
                onCapturePhoto: () {
                  _onCapturePhoto('foto cabezote', (path) {
                    inspeccionService.resumePreoperacional.urlFotoCabezote =
                        path;
                    inspeccionProvider.updateCabezoteImage(path);
                  });
                },
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
                height: 20,
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
            ],
          ),
        ),
      ),
    );
  }
}
