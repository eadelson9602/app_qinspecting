import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/ui/input_decorations.dart';
import 'package:app_qinspecting/ui/app_theme.dart';

class ModernFormProfile extends StatefulWidget {
  const ModernFormProfile({Key? key}) : super(key: key);

  @override
  State<ModernFormProfile> createState() => _ModernFormProfileState();
}

class _ModernFormProfileState extends State<ModernFormProfile> {
  String? _fechaNacimiento;
  late final TextEditingController _fechaCtrl;
  int? _selectedDepartamentoId;
  int? _selectedCiudadId;
  Timer? _loadDataTimer;

  @override
  void initState() {
    super.initState();
    final perfilForm = Provider.of<PerfilFormProvider>(context, listen: false);
    _fechaNacimiento = perfilForm.userDataLogged?.fechaNacimiento;
    final normalized = (_fechaNacimiento == null ||
            _fechaNacimiento!.isEmpty ||
            _fechaNacimiento == '0000-00-00' ||
            _fechaNacimiento == '000-00-00')
        ? ''
        : _fechaNacimiento!;
    _fechaCtrl = TextEditingController(text: normalized);

    // Cargar datos iniciales con un delay para asegurar que el widget esté montado
    _loadDataTimer = Timer(const Duration(milliseconds: 100), () {
      if (mounted) {
        _loadInitialData();
      }
    });
  }

  @override
  void dispose() {
    _loadDataTimer?.cancel();
    _fechaCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;

    try {
      // Verificar que el contexto aún sea válido
      final context = this.context;
      if (!mounted) return;

      final inspeccionProvider =
          Provider.of<InspeccionProvider>(context, listen: false);
      final perfilForm =
          Provider.of<PerfilFormProvider>(context, listen: false);

      // Cargar departamentos
      await inspeccionProvider.listarDepartamentos();

      if (!mounted) return;

      // Buscar el departamento del usuario
      if (perfilForm.userDataLogged?.departamento != null &&
          inspeccionProvider.departamentos.isNotEmpty) {
        try {
          final departamento = inspeccionProvider.departamentos.firstWhere(
            (d) => d.value == perfilForm.userDataLogged!.fkIdDepartamento,
          );
          _selectedDepartamentoId = departamento.value;

          // Cargar ciudades del departamento seleccionado
          await inspeccionProvider.listarCiudades(_selectedDepartamentoId!);

          if (!mounted) return;

          // Buscar la ciudad del usuario
          if (perfilForm.userDataLogged?.nombreCiudad != null &&
              inspeccionProvider.ciudades.isNotEmpty) {
            try {
              final ciudad = inspeccionProvider.ciudades.firstWhere(
                (c) => c.value == perfilForm.userDataLogged!.lugarExpDocumento,
              );
              _selectedCiudadId = ciudad.value;
            } catch (e) {
              // Si no encuentra la ciudad, usar la primera disponible
              _selectedCiudadId = inspeccionProvider.ciudades.first.value;
            }
          }
        } catch (e) {
          // Si no encuentra el departamento, usar el primero disponible
          _selectedDepartamentoId =
              inspeccionProvider.departamentos.first.value;
        }
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      // Manejar errores silenciosamente
      print('Error loading initial data: $e');
    }
  }

  String? _getTipoDocumentoCode(String? tipoDocumento) {
    if (tipoDocumento == null) return null;

    switch (tipoDocumento) {
      case 'Cédula de Ciudadanía':
        return 'CC';
      case 'Cédula de Extranjería':
        return 'CE';
      case 'Tarjeta de Identidad':
        return 'TI';
      default:
        return null;
    }
  }

  String? _getTipoDocumentoLabel(String? codigo) {
    if (codigo == null) return null;

    switch (codigo) {
      case 'CC':
        return 'Cédula de Ciudadanía';
      case 'CE':
        return 'Cédula de Extranjería';
      case 'TI':
        return 'Tarjeta de Identidad';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final perfilForm = Provider.of<PerfilFormProvider>(context, listen: true);
    final inspeccionProvider =
        Provider.of<InspeccionProvider>(context, listen: true);
    final userData = perfilForm.userDataLogged;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: perfilForm.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Datos Personales',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryGreen,
                    ),
              ),
              const SizedBox(height: 20),

              // Nombres
              TextFormField(
                initialValue: userData?.nombres ?? '',
                decoration: InputDecorations.authInputDecorations(
                  hintText: 'Nombres',
                  labelText: 'Nombres',
                  prefixIcon: Icons.person_outline,
                  context: context,
                ),
                onChanged: (value) {
                  userData?.nombres = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Los nombres son requeridos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Apellidos
              TextFormField(
                initialValue: userData?.apellidos ?? '',
                decoration: InputDecorations.authInputDecorations(
                  hintText: 'Apellidos',
                  labelText: 'Apellidos',
                  prefixIcon: Icons.person_outline,
                  context: context,
                ),
                onChanged: (value) {
                  userData?.apellidos = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Los apellidos son requeridos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                initialValue: userData?.email ?? '',
                decoration: InputDecorations.authInputDecorations(
                  hintText: 'Correo electrónico',
                  labelText: 'Email',
                  prefixIcon: Icons.email_outlined,
                  context: context,
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  userData?.email = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El email es requerido';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Ingresa un email válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Número de celular
              TextFormField(
                initialValue: userData?.numeroCelular ?? '',
                decoration: InputDecorations.authInputDecorations(
                  hintText: 'Número de celular',
                  labelText: 'Celular',
                  prefixIcon: Icons.phone_outlined,
                  context: context,
                ),
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  userData?.numeroCelular = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El número de celular es requerido';
                  }
                  if (value.length < 10) {
                    return 'El número de celular debe tener al menos 10 dígitos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Departamento
              DropdownButtonFormField<int>(
                value: _selectedDepartamentoId,
                decoration: InputDecorations.authInputDecorations(
                  hintText: 'Seleccionar departamento',
                  labelText: 'Departamento expedición',
                  prefixIcon: Icons.location_city,
                  context: context,
                ),
                items: inspeccionProvider.departamentos.map((departamento) {
                  return DropdownMenuItem<int>(
                    value: departamento.value,
                    child: Text(departamento.label),
                  );
                }).toList(),
                onChanged: (value) async {
                  setState(() {
                    _selectedDepartamentoId = value;
                    _selectedCiudadId =
                        null; // Reset ciudad when departamento changes
                  });

                  // Actualizar el dato del usuario
                  final departamento =
                      inspeccionProvider.departamentos.firstWhere(
                    (d) => d.value == value,
                  );
                  userData?.departamento = departamento.label;

                  // Cargar ciudades del departamento seleccionado
                  await inspeccionProvider.listarCiudades(value!);
                },
                validator: (value) {
                  if (value == null) {
                    return 'El departamento es requerido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Ciudad
              DropdownButtonFormField<int>(
                value: _selectedCiudadId,
                decoration: InputDecorations.authInputDecorations(
                  hintText: 'Seleccionar ciudad',
                  labelText: 'Ciudad expedición',
                  prefixIcon: Icons.location_on,
                  context: context,
                ),
                items: inspeccionProvider.ciudades.map((ciudad) {
                  return DropdownMenuItem<int>(
                    value: ciudad.value,
                    child: Text(ciudad.label),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCiudadId = value;
                  });

                  // Actualizar el dato del usuario
                  final ciudad = inspeccionProvider.ciudades.firstWhere(
                    (c) => c.value == value,
                  );
                  userData?.nombreCiudad = ciudad.label;
                },
                validator: (value) {
                  if (value == null) {
                    return 'La ciudad es requerida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Tipo de documento
              DropdownButtonFormField<String>(
                value: _getTipoDocumentoCode(userData?.nombreTipoDocumento),
                decoration: InputDecorations.authInputDecorations(
                  hintText: 'Seleccionar tipo de documento',
                  labelText: 'Tipo de documento',
                  prefixIcon: Icons.badge,
                  context: context,
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'CC', child: Text('Cédula de Ciudadanía')),
                  DropdownMenuItem(
                      value: 'CE', child: Text('Cédula de Extranjería')),
                  DropdownMenuItem(
                      value: 'TI', child: Text('Tarjeta de Identidad')),
                ],
                onChanged: (value) {
                  userData?.nombreTipoDocumento = _getTipoDocumentoLabel(value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El tipo de documento es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Número de documento
              TextFormField(
                initialValue: userData?.numeroDocumento ?? '',
                enabled: false,
                decoration: InputDecorations.authInputDecorations(
                  hintText: 'Número de documento',
                  labelText: 'Número de documento',
                  prefixIcon: Icons.numbers,
                  context: context,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  userData?.numeroDocumento = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El número de documento es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Fecha de nacimiento
              TextFormField(
                controller: _fechaCtrl,
                decoration: InputDecorations.authInputDecorations(
                  hintText: 'Seleccionar fecha de nacimiento',
                  labelText: 'Fecha de nacimiento',
                  prefixIcon: Icons.calendar_today,
                  context: context,
                ),
                readOnly: true,
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate:
                        DateTime.now().subtract(const Duration(days: 365 * 25)),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: AppTheme.primaryGreen,
                            onPrimary: Colors.white,
                            surface: Colors.white,
                            onSurface: Colors.black,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() {
                      final formatted =
                          '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                      _fechaNacimiento = formatted;
                      _fechaCtrl.text = formatted;
                      userData?.fechaNacimiento = formatted;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La fecha de nacimiento es requerida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Género
              Text(
                'Género',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryGreen,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Row(
                    children: [
                      Radio(
                        activeColor: AppTheme.primaryGreen,
                        groupValue: userData?.genero,
                        value: 'MASCULINO',
                        onChanged: (value) =>
                            perfilForm.updateGenero(value.toString()),
                      ),
                      Text(
                        'Masculino',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Row(
                    children: [
                      Radio(
                        activeColor: AppTheme.errorColor,
                        groupValue: userData?.genero,
                        value: 'FEMENINO',
                        onChanged: (value) =>
                            perfilForm.updateGenero(value.toString()),
                      ),
                      Text(
                        'Femenino',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Botón de guardar cambios
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _saveProfileData(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Guardar Cambios',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfileData(BuildContext context) async {
    try {
      final perfilForm =
          Provider.of<PerfilFormProvider>(context, listen: false);
      final loginService = Provider.of<LoginService>(context, listen: false);

      // Validar el formulario
      if (!perfilForm.isValidForm()) {
        _showErrorMessage(
            context, 'Por favor, completa todos los campos requeridos');
        return;
      }

      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
          ),
        ),
      );

      // Preparar datos para actualización según el formato requerido
      final userData = perfilForm.userDataLogged;
      if (userData == null) {
        Navigator.pop(context);
        _showErrorMessage(context, 'No se encontraron datos del usuario');
        return;
      }

      // Crear mapa con solo los campos requeridos para el backend
      final updateData = {
        "numeroDocumento": userData.numeroDocumento,
        "base": loginService.selectedEmpresa.nombreBase,
        "nombres": userData.nombres,
        "apellidos": userData.apellidos,
        "email": userData.email,
        "numeroCelular": userData.numeroCelular,
        "urlFoto": userData.urlFoto,
        "fechaNacimiento": userData.fechaNacimiento,
        "lugarExpDocumento": _selectedCiudadId,
        "genero": userData.genero,
      };

      // Llamar al servicio de actualización
      final response = await loginService.updateProfile(updateData);

      // Cerrar indicador de carga
      Navigator.pop(context);

      // Verificar respuesta
      if (response.containsKey('message')) {
        final message = response['message'].toString();
        if (message.contains('actualizado') ||
            message.contains('exitosamente')) {
          // Los datos se refrescan automáticamente en el servicio
          _showSuccessMessage(context, message);
        } else {
          // Mostrar error específico del servidor
          _showErrorMessage(context, message);
        }
      } else if (response.containsKey('error')) {
        _showErrorMessage(context, response['error'].toString());
      } else {
        // Respuesta exitosa sin mensaje específico - los datos se refrescan automáticamente
        _showSuccessMessage(
            context, 'Datos del perfil actualizados correctamente');
      }
    } catch (e) {
      // Cerrar indicador de carga si está abierto
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      print('[PROFILE UPDATE] Error: $e');
      _showErrorMessage(context, 'Error al guardar los datos: $e');
    }
  }

  void _showSuccessMessage(BuildContext context, String message) {
    try {
      // Verificar si el contexto está montado antes de mostrar el mensaje
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        // Si el contexto no está montado, usar print como fallback
        print(
            'Contexto no montado, no se puede mostrar mensaje de éxito: $message');
      }
    } catch (e) {
      // Si hay error al mostrar el SnackBar, usar print como fallback
      print('Error al mostrar mensaje de éxito: $message - Error: $e');
    }
  }

  void _showErrorMessage(BuildContext context, String message) {
    try {
      // Verificar si el contexto está montado antes de mostrar el mensaje
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        // Si el contexto no está montado, usar print como fallback
        print(
            'Contexto no montado, no se puede mostrar mensaje de error: $message');
      }
    } catch (e) {
      // Si hay error al mostrar el SnackBar, usar print como fallback
      print('Error al mostrar mensaje de error: $message - Error: $e');
    }
  }
}
