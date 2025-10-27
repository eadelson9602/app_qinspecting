import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/providers/loading_progress_provider.dart';
import 'package:app_qinspecting/widgets/custom_loading_truck.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/ui/app_theme.dart';
import 'package:app_qinspecting/widgets/profile/profile_widgets.dart';
import 'package:app_qinspecting/models/models.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    // Solo cargar después del primer frame para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loginService = Provider.of<LoginService>(context, listen: true);
    final perfilForm = Provider.of<PerfilFormProvider>(context, listen: true);
    final loadingProgress =
        Provider.of<LoadingProgressProvider>(context, listen: true);

    // Verificar si hay una imagen pendiente de actualizar
    _checkPendingPhotoUpdate(context, perfilForm, loginService);

    // Sincronizar automáticamente la imagen del perfil con el servidor
    _syncProfilePhotoWithServer(context, loginService);

    // Actualizar datos del perfil cuando cambien los datos del login service
    // Usar addPostFrameCallback para evitar setState durante build
    if (perfilForm.userDataLogged != loginService.userDataLogged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        perfilForm.updateProfile(loginService.userDataLogged);
      });
    }

    // Verificar si necesitamos cargar datos iniciales
    if (!perfilForm.hasCompleteData &&
        !perfilForm.isLoadingInitialData &&
        !_hasInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadInitialUserData();
      });
    }

    // Si los datos están completos pero el loader sigue activo, ocultarlo
    if (perfilForm.hasCompleteData && perfilForm.isLoadingInitialData) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        perfilForm.finishLoadingInitialData();
      });
    }

    return // Body del perfil
        Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom,
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height *
                      1.54, // Altura suficiente para scroll
                  child: Stack(
                    children: [
                      // Header con gradiente y avatar
                      Consumer<PerfilFormProvider>(
                        builder: (context, perfilForm, child) {
                          final nombreQi =
                              loginService.selectedEmpresa.nombreQi ?? '';
                          return ModernHeader(
                            userPhoto: perfilForm.getDisplayImage(),
                            onPhotoTap: () =>
                                _showPhotoOptions(context, nombreQi),
                          );
                        },
                      ),

                      // Nombre del usuario
                      Positioned(
                        top: MediaQuery.of(context).size.height * 0.34,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Consumer<PerfilFormProvider>(
                            builder: (context, perfilForm, child) {
                              // Fallback al LoginService si PerfilFormProvider no tiene datos
                              final nombres =
                                  perfilForm.userDataLogged?.nombres ??
                                      Provider.of<LoginService>(context,
                                              listen: false)
                                          .userDataLogged
                                          .nombres ??
                                      'Cargando...';
                              return Text(
                                nombres,
                                style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors
                                          .black, // Mantener blanco para contraste con el gradiente verde
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              );
                            },
                          ),
                        ),
                      ),

                      // Apellido del usuario
                      Positioned(
                        top: MediaQuery.of(context).size.height * 0.37,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Consumer<PerfilFormProvider>(
                            builder: (context, perfilForm, child) {
                              // Fallback al LoginService si PerfilFormProvider no tiene datos
                              final apellidos =
                                  perfilForm.userDataLogged?.apellidos ??
                                      Provider.of<LoginService>(context,
                                              listen: false)
                                          .userDataLogged
                                          .apellidos ??
                                      'Cargando...';
                              return Text(
                                apellidos,
                                style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors
                                          .black, // Mantener blanco para contraste con el gradiente verde
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              );
                            },
                          ),
                        ),
                      ),

                      // Avatar flotante con z-index alto
                      Positioned(
                        top: MediaQuery.of(context).size.height * 0.17,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Consumer<PerfilFormProvider>(
                            builder: (context, perfilForm, child) {
                              final nombreQi =
                                  loginService.selectedEmpresa.nombreQi ?? '';
                              return GestureDetector(
                                onTap: () =>
                                    _showPhotoOptions(context, nombreQi),
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[800]
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(60),
                                    border: Border.all(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.grey[600]!
                                          : Colors.white,
                                      width: 4,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(56),
                                    child: Consumer<LoginFormProvider>(
                                      builder: (context, imageProvider, child) {
                                        return imageProvider.getImage(
                                            perfilForm.getDisplayImage());
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Botón de cámara flotante
                      Positioned(
                        top: MediaQuery.of(context).size.height * 0.18,
                        right: MediaQuery.of(context).size.width * 0.05,
                        child: Consumer<PerfilFormProvider>(
                          builder: (context, perfilForm, child) {
                            final nombreQi =
                                loginService.selectedEmpresa.nombreQi ?? '';
                            return GestureDetector(
                              onTap: () => _showPhotoOptions(context, nombreQi),
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[700]
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.black54,
                                  size: 16,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Formulario de perfil
                      Positioned(
                        top: MediaQuery.of(context).size.height * 0.42,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: const ModernFormProfile(),
                      ),
                    ],
                  ),
                ),
              ),
              // Loader overlay para subida de foto
              if (loadingProgress.isLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.9),
                  child: Center(
                    child: CustomLoadingTruck(
                      progress: loadingProgress.progress,
                      message: loadingProgress.message,
                      primaryColor: AppTheme.primaryGreen,
                      backgroundColor: Theme.of(context).cardColor,
                    ),
                  ),
                ),

              // Loader overlay para carga inicial de datos
              if (perfilForm.isLoadingInitialData)
                Container(
                  color: Colors.black.withValues(alpha: 0.9),
                  child: Center(
                    child: CustomLoadingTruck(
                      progress: 0.5, // Progreso fijo para carga inicial
                      message: 'Cargando datos del usuario...',
                      primaryColor: AppTheme.primaryGreen,
                      backgroundColor: Theme.of(context).cardColor,
                    ),
                  ),
                ),
            ],
          )),
    );
  }

  void _showPhotoOptions(BuildContext context, String base) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalContext) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
              'Seleccionar foto de perfil',
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
                    onTap: () async {
                      Navigator.pop(modalContext);
                      await _pickImage(context, ImageSource.camera);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: PhotoOptionButton(
                    icon: Icons.photo_library,
                    label: 'Galería',
                    onTap: () async {
                      Navigator.pop(modalContext);
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
                onPressed: () => Navigator.pop(modalContext),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                child: Text(
                  'Cancelar',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
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
        // Verificar el estado actual del permiso
        final currentCameraStatus = await Permission.camera.status;

        // Solo mostrar diálogo explicativo si el permiso no está otorgado
        if (currentCameraStatus != PermissionStatus.granted) {
          final shouldProceed = await _showCameraPermissionAlert(context);
          if (!shouldProceed) {
            return;
          }
        }

        final cameraStatus = await Permission.camera.request();

        if (cameraStatus != PermissionStatus.granted) {
          if (cameraStatus == PermissionStatus.permanentlyDenied) {
            await _showPermissionDeniedDialog(context, 'cámara');
          } else {
            _showErrorMessage(
                context, 'Se necesita permiso para acceder a la cámara');
          }
          return;
        }
      }

      // Verificar permisos para galería
      if (source == ImageSource.gallery) {
        // Verificar el estado actual del permiso
        final photosStatus = await Permission.photos.request();

        if (photosStatus != PermissionStatus.granted) {
          if (photosStatus == PermissionStatus.permanentlyDenied) {
            await _showPermissionDeniedDialog(context, 'galería');
          } else {
            _showErrorMessage(
                context, 'Se necesita permiso para acceder a la galería');
          }
          return;
        }
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        // Subir imagen directamente sin depender del contexto
        _uploadImageDirectly(context, image.path);
      }
    } on PlatformException catch (e) {
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

      _showErrorMessage(context, errorMessage);
    } catch (e) {
      _showErrorMessage(context, 'Error inesperado: $e');
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
        print('Contexto no montado, no se puede mostrar mensaje: $message');
      }
    } catch (e) {
      // Si hay error al mostrar el SnackBar, usar print como fallback
      print('Error al mostrar mensaje: $message - Error: $e');
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
            content: Column(
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
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(
                  foregroundColor:
                      Theme.of(context).textTheme.bodyMedium?.color,
                ),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Theme.of(context).brightness ==
                          Brightness.dark
                      ? Colors.white
                      : Colors
                          .white, // Mantener blanco para contraste con verde
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
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).textTheme.bodyMedium?.color,
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
              foregroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.white, // Mantener blanco para contraste con verde
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

  /// Función para subir imagen directamente sin depender del contexto
  Future<void> _uploadImageDirectly(
      BuildContext context, String imagePath) async {
    final loadingProgress =
        Provider.of<LoadingProgressProvider>(context, listen: false);
    final perfilForm = Provider.of<PerfilFormProvider>(context, listen: false);

    // Iniciar loading con progreso
    loadingProgress.startLoading(message: 'Preparando imagen...');

    try {
      // Simular progreso inicial
      await Future.delayed(const Duration(milliseconds: 500));
      loadingProgress.updateProgress(0.2,
          message: 'Conectando con servidor...');

      final loginService = Provider.of<LoginService>(context, listen: false);

      // Usar el loginService directamente para crear InspeccionService
      final inspeccionService = InspeccionService();

      // El loginService ya tiene el token configurado, solo necesitamos copiarlo
      inspeccionService.loginService.options.headers =
          loginService.options.headers;

      loadingProgress.updateProgress(0.4, message: 'Subiendo imagen...');

      final uploadResult = await inspeccionService.uploadImage(
        path: imagePath,
        company: loginService.selectedEmpresa.nombreQi?.toLowerCase() ?? '',
        folder: 'perfiles',
      );

      loadingProgress.updateProgress(0.7, message: 'Procesando imagen...');

      print('[PHOTO DIRECT] Resultado de uploadImage: $uploadResult');

      if (uploadResult != null && uploadResult['path'] != null) {
        final newImageUrl = uploadResult['path'] as String;

        loadingProgress.updateProgress(0.9, message: 'Actualizando perfil...');

        // También intentar actualizar inmediatamente si es posible
        await _updateUserDataWithNewUrl(context, newImageUrl);

        loadingProgress.updateProgress(1.0, message: '¡Completado!');
        await Future.delayed(const Duration(milliseconds: 500));
      } else {
        print(
            '[PHOTO DIRECT] ❌ Error: No se pudo obtener la URL de la imagen subida');
        loadingProgress.stopLoading();
        perfilForm.updateProfilePhoto(false);
      }
    } catch (e) {
      print('[PHOTO DIRECT] ❌ Error al subir imagen: $e');
      loadingProgress.stopLoading();
      perfilForm.updateProfilePhoto(false);
    } finally {
      loadingProgress.finishLoading();
      perfilForm.updateProfilePhoto(false);
    }
  }

  /// Actualiza los datos del usuario con la nueva URL de imagen
  Future<void> _updateUserDataWithNewUrl(
      BuildContext context, String newImageUrl) async {
    try {
      // Obtener providers desde el contexto
      final loginService = Provider.of<LoginService>(context, listen: false);
      final perfilForm =
          Provider.of<PerfilFormProvider>(context, listen: false);

      // Actualizar la URL de la imagen en memoria
      loginService.userDataLogged.urlFoto = newImageUrl;
      print(
          '[UPDATE USER DATA] URL actualizada en memoria: ${loginService.userDataLogged.urlFoto}');

      // Actualizar en el provider local
      perfilForm.updateProfile(loginService.userDataLogged);

      // Preparar datos para enviar al backend
      final updateData = {
        'numeroDocumento': loginService.userDataLogged.numeroDocumento,
        'nombres': loginService.userDataLogged.nombres,
        'apellidos': loginService.userDataLogged.apellidos,
        'email': loginService.userDataLogged.email,
        'numeroCelular': loginService.userDataLogged.numeroCelular,
        'urlFoto': newImageUrl, // Usar la nueva URL
        'fechaNacimiento': loginService.userDataLogged.fechaNacimiento,
        'lugarExpDocumento': loginService.userDataLogged.lugarExpDocumento,
        'genero': loginService.userDataLogged.genero,
        'base': loginService.selectedEmpresa.nombreBase,
      };

      // Llamar al backend para persistir el cambio
      final result = await loginService.updateProfile(updateData);
      print('[UPDATE USER DATA] Resultado del backend: $result');

      if (result['message']?.contains('exitosamente') == true) {
        print(
            '[UPDATE USER DATA] ✅ Perfil actualizado exitosamente en el servidor');
      } else {
        print(
            '[UPDATE USER DATA] ❌ Error al actualizar en el servidor: $result');
      }
    } catch (e) {
      print('[UPDATE USER DATA] ❌ Error al actualizar datos del usuario: $e');
    }
  }

  /// Sincroniza automáticamente la imagen del perfil con el servidor
  Future<void> _syncProfilePhotoWithServer(
      BuildContext context, LoginService loginService) async {
    try {
      final baseEmpresa = loginService.selectedEmpresa.nombreBase;
      final usuario = loginService.selectedEmpresa.numeroDocumento;

      // Obtener datos actualizados del servidor
      final response = await loginService.dio.get(
          '${loginService.baseUrl}/get_user_data/$baseEmpresa/$usuario',
          options: loginService.options);

      if (response.statusCode == 200) {
        final serverUserData = UserData.fromJson(response.toString());
        serverUserData.empresa = loginService.selectedEmpresa.nombreQi;

        // Comparar URLs de imagen
        if (loginService.userDataLogged.urlFoto != serverUserData.urlFoto) {
          // Actualizar la imagen local con la del servidor
          loginService.userDataLogged.urlFoto = serverUserData.urlFoto;

          // Actualizar en SQLite
          await DBProvider.db.updateUser(loginService.userDataLogged);

          // Notificar cambios usando el método público del LoginService
          loginService.userDataLogged = loginService.userDataLogged;
        } else {
          print('[SYNC PHOTO] ✅ Imagen ya está sincronizada');
        }
      } else {
        print(
            '[SYNC PHOTO] ❌ Error al obtener datos del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('[SYNC PHOTO] ❌ Error en sincronización automática: $e');
    }
  }

  /// Verifica si hay una imagen pendiente de actualizar desde una subida en background
  Future<void> _checkPendingPhotoUpdate(BuildContext context,
      PerfilFormProvider perfilForm, LoginService loginService) async {
    try {
      final storage = FlutterSecureStorage();
      final pendingUrl = await storage.read(key: 'pendingPhotoUrl');
      final userDataUpdated = await storage.read(key: 'userDataUpdated');

      if (pendingUrl != null && pendingUrl.isNotEmpty) {
        // Actualizar la URL en el provider
        perfilForm.userDataLogged?.urlFoto = pendingUrl;

        // Actualizar en SQLite
        if (perfilForm.userDataLogged != null) {
          await DBProvider.db.updateUser(perfilForm.userDataLogged!);
        }

        // Actualizar en LoginService
        loginService.userDataLogged.urlFoto = pendingUrl;

        // Limpiar la URL pendiente del storage
        await storage.delete(key: 'pendingPhotoUrl');

        // Notificar cambios usando updateProfile
        if (context.mounted) {
          perfilForm.updateProfile(perfilForm.userDataLogged!);
        }
      }

      // Si hay datos actualizados, refrescar desde SQLite
      if (userDataUpdated == 'true') {
        // Obtener datos necesarios del storage
        final numeroDocumento =
            await storage.read(key: 'numeroDocumento') ?? '';
        final password = await storage.read(key: 'password') ?? '';
        final base = await storage.read(key: 'base') ?? '';

        if (numeroDocumento.isNotEmpty &&
            password.isNotEmpty &&
            base.isNotEmpty) {
          final userData =
              await DBProvider.db.getUser(numeroDocumento, password, base);
          if (userData != null && context.mounted) {
            perfilForm.updateProfile(userData);
            loginService.userDataLogged = userData;
          }
        }
        await storage.delete(key: 'userDataUpdated');
      }
    } catch (e) {
      print('[PHOTO PENDING] Error al procesar imagen pendiente: $e');
    }
  }

  /// Carga los datos iniciales del usuario desde SQLite
  Future<void> _loadInitialUserData() async {
    final perfilForm = Provider.of<PerfilFormProvider>(context, listen: false);
    final loginService = Provider.of<LoginService>(context, listen: false);

    // Si ya está cargando, no hacer nada
    if (perfilForm.isLoadingInitialData) {
      print('[LOAD INITIAL DATA] Ya está cargando, omitiendo...');
      return;
    }

    print('[LOAD INITIAL DATA] Iniciando carga de datos iniciales...');
    print('[LOAD INITIAL DATA] hasCompleteData: ${perfilForm.hasCompleteData}');
    print(
        '[LOAD INITIAL DATA] LoginService nombres: ${loginService.userDataLogged.nombres}');

    // Solo cargar si no hay datos completos
    if (!perfilForm.hasCompleteData) {
      perfilForm.startLoadingInitialData();

      try {
        // Verificar primero si ya hay datos válidos en LoginService
        if (loginService.userDataLogged.nombres != null &&
            loginService.userDataLogged.nombres!.isNotEmpty &&
            loginService.userDataLogged.apellidos != null &&
            loginService.userDataLogged.apellidos!.isNotEmpty) {
          print(
              '[LOAD INITIAL DATA] Datos válidos encontrados en LoginService');
          // Usar addPostFrameCallback para evitar setState durante build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            perfilForm.updateProfile(loginService.userDataLogged);
            // Finalizar loading inmediatamente después de actualizar
            perfilForm.finishLoadingInitialData();
            // Forzar reconstrucción del widget
            if (mounted) {
              setState(() {});
            }
          });
        } else {
          print(
              '[LOAD INITIAL DATA] Datos incompletos en LoginService, cargando desde SQLite...');
          // Intentar cargar desde SQLite usando datos almacenados
          final storage = FlutterSecureStorage();
          final numeroDocumento =
              await storage.read(key: 'numeroDocumento') ?? '';
          final password = await storage.read(key: 'password') ?? '';
          final base = await storage.read(key: 'base') ?? '';

          print(
              '[LOAD INITIAL DATA] Datos de storage - Doc: $numeroDocumento, Base: $base');

          if (numeroDocumento.isNotEmpty &&
              password.isNotEmpty &&
              base.isNotEmpty) {
            print('[LOAD INITIAL DATA] Cargando desde SQLite...');
            final userData =
                await DBProvider.db.getUser(numeroDocumento, password, base);

            if (userData != null) {
              print(
                  '[LOAD INITIAL DATA] Datos cargados desde SQLite: ${userData.nombres} ${userData.apellidos}');
              // Usar addPostFrameCallback para evitar setState durante build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                perfilForm.updateProfile(userData);
                loginService.userDataLogged = userData;
                // Finalizar loading inmediatamente después de actualizar
                perfilForm.finishLoadingInitialData();
                // Forzar reconstrucción del widget
                if (mounted) {
                  setState(() {});
                }
              });
            } else {
              print('[LOAD INITIAL DATA] ❌ No se encontraron datos en SQLite');
            }
          } else {
            print(
                '[LOAD INITIAL DATA] ❌ Datos de autenticación incompletos en storage');
          }
        }

        // Simular tiempo mínimo para mostrar el loader
        await Future.delayed(const Duration(milliseconds: 300));
      } catch (e) {
        print('[LOAD INITIAL DATA] ❌ Error al cargar datos iniciales: $e');
      } finally {
        // Solo finalizar loading si aún está activo
        if (perfilForm.isLoadingInitialData) {
          perfilForm.finishLoadingInitialData();
        }
        print('[LOAD INITIAL DATA] ✅ Carga de datos iniciales completada');
      }
    } else {
      print('[LOAD INITIAL DATA] Datos ya están completos, omitiendo carga');
      // Si los datos ya están completos pero el loader está activo, ocultarlo
      if (perfilForm.isLoadingInitialData) {
        perfilForm.finishLoadingInitialData();
      }
    }
  }
}
