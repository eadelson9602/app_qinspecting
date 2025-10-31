// unused imports removidos
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// removed: image_picker (flujo embebido)
import 'package:intl/intl.dart';
// removed: permission_handler (flujo embebido)
// unused imports removidos
// removed: embedded_camera_screen (no se usa ya para capturar)

import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/ui/input_decorations.dart';
// removed unused import app_theme
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

  // Estado manual de selección de departamento/ciudad (para persistir al volver)
  int? _selectedDepartmentId;
  int? _selectedCityManualId;

  // Instancia del servicio de ubicación
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    // Limpiar el formulario cuando se inicializa el widget usando post-frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _resetFormState();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Verificar si se debe resetear el formulario (cuando no hay datos guardados)
    // Usar post-frame callback para evitar setState durante build
    final inspeccionService =
        Provider.of<InspeccionService>(context, listen: false);

    // Si el servicio está limpio pero el formulario tiene valores, resetear
    if (inspeccionService.resumePreoperacional.placaVehiculo == null ||
        inspeccionService.resumePreoperacional.placaVehiculo!.isEmpty) {
      if (_selectedPlacaVehiculo != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _resetFormState();
          }
        });
      }
    }
  }

  void _resetFormState() {
    setState(() {
      _gpsCity = null;
      _gpsCityId = null;
      _gpsDepartmentId = null;
      _locationError = '';
      _cityFoundByGPS = false;
      _hasGpsError = false;
      _selectedPlacaVehiculo = null;
      _selectedDepartmentId = null;
      _selectedCityManualId = null;
    });

    // Resetear el formulario si está inicializado
    formKey.currentState?.reset();
  }

  bool isValidForm() {
    return formKey.currentState?.validate() ?? false;
  }

  // Eliminado: bottom sheet anterior para seleccionar fuente

  // Eliminado: flujo anterior de captura que navegaba a otra pantalla

  // Eliminado: selector de imagen anterior

  // eliminado: persist helper ya no usado

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

    // Sincronizar valores iniciales desde el servicio SOLO si hay valores válidos
    // Esto evita restaurar valores de inspecciones anteriores cuando el servicio está limpio
    if (inspeccionService.resumePreoperacional.placaVehiculo != null &&
        inspeccionService.resumePreoperacional.placaVehiculo!.isNotEmpty) {
      _selectedPlacaVehiculo ??=
          inspeccionService.resumePreoperacional.placaVehiculo;
    }
    // Si tenemos una ciudad en el servicio y aún no hay selección manual, refléjala
    if (_selectedCityManualId == null &&
        inspeccionService.resumePreoperacional.idCiudad != null &&
        !_cityFoundByGPS) {
      _selectedCityManualId = inspeccionService.resumePreoperacional.idCiudad;
    }
    // Si hay departamento detectado por GPS y no hemos establecido uno manual, conservarlo
    if (_selectedDepartmentId == null && _gpsDepartmentId != null) {
      _selectedDepartmentId = _gpsDepartmentId;
    }

    // Normalizar/evitar duplicados en listas para Dropdowns
    final Set<int> seenDept = {};
    final departamentosUnique = inspeccionProvider.departamentos
        .where((d) => seenDept.add(d.value))
        .toList();

    final Set<int> seenCity = {};
    final ciudadesUnique = inspeccionProvider.ciudades
        .where((c) => seenCity.add(c.value))
        .toList();

    final Set<String> seenPlacas = {};
    final vehiculosUnique = inspeccionProvider.vehiculos
        .where((v) => seenPlacas.add(v.placa))
        .toList();

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
                  value: () {
                    final v = _selectedPlacaVehiculo;
                    if (v == null) return null;
                    final exists = vehiculosUnique.any((e) => e.placa == v);
                    return exists ? v : null;
                  }(),
                  decoration: InputDecorations.authInputDecorations(
                      prefixIcon: Icons.local_shipping,
                      hintText: '',
                      labelText: 'Placa del vehículo',
                      context: context),
                  validator: (value) {
                    if (value == null) return 'Seleccione una placa';
                    return null;
                  },
                  items: vehiculosUnique.map((e) {
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
                  value: () {
                    final v = _cityFoundByGPS && _gpsDepartmentId != null
                        ? _gpsDepartmentId
                        : _selectedDepartmentId;
                    // Asegurar que el valor exista en la lista unica
                    if (v == null) return null;
                    final exists = departamentosUnique.any((e) => e.value == v);
                    return exists ? v : null;
                  }(),
                  validator: (value) {
                    // Si la ciudad fue encontrada por GPS, no validar el departamento
                    if (_cityFoundByGPS) return null;
                    if (value == null) return 'Seleccione un departamento';
                    return null;
                  },
                  items: departamentosUnique.map((e) {
                    return DropdownMenuItem(
                      child: Text(e.label),
                      value: e.value,
                    );
                  }).toList(),
                  onChanged: !_hasGpsError
                      ? null // Deshabilitar si NO hay error de GPS (GPS funcionó correctamente)
                      : (value) async {
                          setState(() {
                            _selectedDepartmentId = value;
                            _selectedCityManualId =
                                null; // reset city until pick
                          });
                          if (value != null) {
                            await inspeccionProvider.listarCiudades(value);
                          }
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
                  value: () {
                    final v = _selectedCityManualId ??
                        inspeccionService.resumePreoperacional.idCiudad;
                    if (v == null) return null;
                    final exists = ciudadesUnique.any((e) => e.value == v);
                    return exists ? v : null;
                  }(),
                  items: ciudadesUnique.map((e) {
                    return DropdownMenuItem(
                      child: Text(e.label),
                      value: e.value,
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      final ciudad = inspeccionProvider.ciudades
                          .firstWhere((c) => c.value == value);
                      setState(() {
                        _selectedCityManualId = value;
                      });
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
                initialValue: (inspeccionService
                                .resumePreoperacional.kilometraje !=
                            null &&
                        inspeccionService.resumePreoperacional.kilometraje! > 0)
                    ? inspeccionService.resumePreoperacional.kilometraje!
                        .toString()
                    : '',
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
                onImageCaptured: (path) {
                  inspeccionService.resumePreoperacional.urlFotoKm = path;
                  inspeccionProvider.updateSelectedImage(path);
                },
              ),
              const SizedBox(height: 16),
              PhotoSection(
                title: 'Foto Cabezote',
                imageUrl: inspeccionProvider.pathFileCabezote,
                onImageCaptured: (path) {
                  inspeccionService.resumePreoperacional.urlFotoCabezote = path;
                  inspeccionProvider.updateCabezoteImage(path);
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
