import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/ui/input_decorations.dart';
import 'package:app_qinspecting/ui/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loginService = Provider.of<LoginService>(context, listen: false);
    final perfilForm = Provider.of<PerfilFormProvider>(context, listen: true);
    perfilForm.userDataLogged = loginService.userDataLogged;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Header con gradiente y avatar
            _ModernHeader(
              userName:
                  '${perfilForm.userDataLogged?.nombres} ${perfilForm.userDataLogged?.apellidos}',
              userPhoto: perfilForm.userDataLogged?.urlFoto,
              onPhotoTap: () => _showPhotoOptions(context),
            ),

            // Información del usuario
            _UserInfoCard(
              userData: perfilForm.userDataLogged,
            ),

            // Formulario de datos personales
            const _ModernFormProfile(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Seleccionar foto de perfil',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryGreen,
                  ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _PhotoOptionButton(
                    icon: Icons.camera_alt,
                    label: 'Cámara',
                    onTap: () async {
                      Navigator.pop(context);
                      await _pickImage(context, ImageSource.camera);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _PhotoOptionButton(
                    icon: Icons.photo_library,
                    label: 'Galería',
                    onTap: () async {
                      Navigator.pop(context);
                      await _pickImage(context, ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Text(
                  'Cancelar',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      // Verificar permisos para cámara
      if (source == ImageSource.camera) {
        // Mostrar alerta explicativa antes de solicitar permiso
        final shouldProceed = await _showCameraPermissionAlert(context);
        if (!shouldProceed) {
          print('Usuario canceló el permiso de cámara');
          return;
        }

        print('Solicitando permiso de cámara...');
        final cameraStatus = await Permission.camera.request();
        print('Estado del permiso de cámara: $cameraStatus');

        if (cameraStatus != PermissionStatus.granted) {
          if (cameraStatus == PermissionStatus.permanentlyDenied) {
            await _showPermissionDeniedDialog(context, 'cámara');
          } else {
            _showErrorMessage(
                context, 'Se necesita permiso para acceder a la cámara');
          }
          return;
        }

        print('Permiso de cámara concedido, procediendo a abrir la cámara...');
      }

      // Verificar permisos para galería
      if (source == ImageSource.gallery) {
        print('Solicitando permiso de galería...');
        final photosStatus = await Permission.photos.request();
        print('Estado del permiso de galería: $photosStatus');

        if (photosStatus != PermissionStatus.granted) {
          if (photosStatus == PermissionStatus.permanentlyDenied) {
            await _showPermissionDeniedDialog(context, 'galería');
          } else {
            _showErrorMessage(
                context, 'Se necesita permiso para acceder a la galería');
          }
          return;
        }

        print(
            'Permiso de galería concedido, procediendo a abrir la galería...');
      }

      print(
          'Creando ImagePicker y abriendo ${source == ImageSource.camera ? 'cámara' : 'galería'}...');
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      print('ImagePicker completado. Imagen seleccionada: ${image?.path}');
      if (image != null) {
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

        try {
          // Simular procesamiento de la imagen
          await Future.delayed(const Duration(seconds: 2));

          // Cerrar el diálogo de carga
          if (context.mounted) {
            Navigator.pop(context);
          }

          // Actualizar preview localmente: guardar ruta en provider
          if (context.mounted) {
            final perfilForm =
                Provider.of<PerfilFormProvider>(context, listen: false);
            // Guardamos la ruta local en urlFoto para que el header la muestre
            perfilForm.userDataLogged?.urlFoto = image.path;
            // Forzar reconstrucción del header escuchando al provider en build()
            _showSuccessMessage(context, 'Foto actualizada correctamente');
          }
        } catch (e) {
          // Cerrar el diálogo de carga si hay error
          if (context.mounted) {
            Navigator.pop(context);
            _showErrorMessage(context, 'Error al procesar la imagen: $e');
          }
        }
      }
    } on PlatformException catch (e) {
      print('PlatformException capturada: ${e.code} - ${e.message}');
      String errorMessage = 'Error al seleccionar la imagen';

      if (e.code == 'camera_access_denied') {
        errorMessage = 'Acceso a la cámara denegado';
      } else if (e.code == 'photo_access_denied') {
        errorMessage = 'Acceso a la galería denegado';
      } else if (e.code == 'camera_access_denied_without_prompt') {
        errorMessage =
            'Acceso a la cámara denegado permanentemente. Ve a configuración para habilitarlo';
      } else if (e.code == 'photo_access_denied_without_prompt') {
        errorMessage =
            'Acceso a la galería denegado permanentemente. Ve a configuración para habilitarlo';
      }

      print('Mostrando error: $errorMessage');
      _showErrorMessage(context, errorMessage);
    } catch (e) {
      print('Error inesperado: $e');
      _showErrorMessage(context, 'Error inesperado: $e');
    }
  }

  void _showSuccessMessage(BuildContext context, String message) {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      // Si hay error al mostrar el SnackBar, usar print como fallback
      print('Error al mostrar mensaje de éxito: $message');
    }
  }

  void _showErrorMessage(BuildContext context, String message) {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      // Si hay error al mostrar el SnackBar, usar print como fallback
      print('Error al mostrar mensaje: $message');
    }
  }

  /// Muestra una alerta explicativa antes de solicitar permiso de cámara
  Future<bool> _showCameraPermissionAlert(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.camera_alt,
                  color: AppTheme.primaryGreen,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Permiso de Cámara',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Para cambiar tu foto de perfil, necesitamos acceso a tu cámara.',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 12),
                Text(
                  '¿Permitir que la aplicación acceda a tu cámara?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                ),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Permitir'),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Muestra un diálogo cuando el permiso ha sido denegado permanentemente
  Future<void> _showPermissionDeniedDialog(
      BuildContext context, String permission) async {
    return await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_rounded,
              color: AppTheme.warningColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text(
              'Permiso Denegado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'El acceso a la $permission ha sido denegado permanentemente.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              'Para usar esta función, ve a Configuración > Permisos y habilita el acceso a la $permission.',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
            ),
            child: const Text('Entendido'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Ir a Configuración'),
          ),
        ],
      ),
    );
  }
}

class _ModernHeader extends StatelessWidget {
  const _ModernHeader({
    Key? key,
    required this.userName,
    this.userPhoto,
    this.onPhotoTap,
  }) : super(key: key);

  final String userName;
  final String? userPhoto;
  final VoidCallback? onPhotoTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        children: [
          // Botón de volver
          Positioned(
            left: 20,
            top: 50,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),

          // Avatar circular
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: onPhotoTap,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: FutureBuilder(
                      future:
                          Provider.of<InspeccionService>(context, listen: false)
                              .checkConnection(),
                      builder: (context, snapshot) {
                        if (snapshot.data == true) {
                          return Provider.of<LoginFormProvider>(context,
                                  listen: false)
                              .getImage(userPhoto ?? '');
                        }
                        return Container(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                          child: const Image(
                            image: AssetImage('assets/images/loading-2.gif'),
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Botón de cámara
          Positioned(
            bottom: 80,
            right: MediaQuery.of(context).size.width / 2 - 15,
            child: GestureDetector(
              onTap: onPhotoTap,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),

          // Nombre del usuario
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserInfoCard extends StatelessWidget {
  const _UserInfoCard({
    Key? key,
    required this.userData,
  }) : super(key: key);

  final dynamic userData;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInfoRow(
              Icons.location_on,
              'Ubicación',
              '${userData?.departamento ?? 'N/A'}, ${userData?.nombreCiudad ?? 'N/A'}',
            ),
            _buildDivider(),
            _buildInfoRow(
              Icons.business,
              'Empresa',
              userData?.empresa ?? 'N/A',
            ),
            _buildDivider(),
            _buildDocumentInfo(),
            _buildDivider(),
            _buildInfoRow(
              Icons.cake,
              'Fecha de nacimiento',
              userData?.fechaNacimiento ?? 'N/A',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.badge,
              color: AppTheme.primaryGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Documento',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userData?.nombreTipoDocumento ?? 'N/A',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userData?.numeroDocumento ?? 'N/A',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 1,
      color: Colors.grey.shade200,
    );
  }
}

class _ModernFormProfile extends StatefulWidget {
  const _ModernFormProfile({Key? key}) : super(key: key);

  @override
  State<_ModernFormProfile> createState() => _ModernFormProfileState();
}

class _ModernFormProfileState extends State<_ModernFormProfile> {
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
            (d) => d.label == perfilForm.userDataLogged!.departamento,
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
                (c) => c.label == perfilForm.userDataLogged!.nombreCiudad,
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
    final perfilForm = Provider.of<PerfilFormProvider>(context, listen: false);
    final inspeccionProvider =
        Provider.of<InspeccionProvider>(context, listen: true);
    final userData = perfilForm.userDataLogged;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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

              // Departamento
              DropdownButtonFormField<int>(
                value: _selectedDepartamentoId,
                decoration: InputDecorations.authInputDecorations(
                  hintText: 'Seleccionar departamento',
                  labelText: 'Departamento',
                  prefixIcon: Icons.location_city,
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
                  labelText: 'Ciudad',
                  prefixIcon: Icons.location_on,
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
                decoration: InputDecorations.authInputDecorations(
                  hintText: 'Número de documento',
                  labelText: 'Número de documento',
                  prefixIcon: Icons.numbers,
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
                      Text('Masculino'),
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
                      Text('Femenino'),
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

      // Simular guardado (aquí puedes agregar la lógica real de guardado)
      await Future.delayed(const Duration(seconds: 2));

      // Cerrar indicador de carga
      Navigator.pop(context);

      // Mostrar mensaje de éxito
      _showSuccessMessage(
          context, 'Datos del perfil actualizados correctamente');
    } catch (e) {
      // Cerrar indicador de carga si está abierto
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      _showErrorMessage(context, 'Error al guardar los datos: $e');
    }
  }

  void _showSuccessMessage(BuildContext context, String message) {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      // Si hay error al mostrar el SnackBar, usar print como fallback
      print('Error al mostrar mensaje de éxito: $message');
    }
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _PhotoOptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PhotoOptionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border:
                Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: AppTheme.primaryGreen,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
