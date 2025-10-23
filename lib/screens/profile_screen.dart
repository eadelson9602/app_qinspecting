import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/ui/app_theme.dart';
import 'package:app_qinspecting/widgets/profile/profile_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loginService = Provider.of<LoginService>(context, listen: true);
    final perfilForm = Provider.of<PerfilFormProvider>(context, listen: true);
    final base = loginService.userDataLogged.base ?? '';

    // Verificar si hay una imagen pendiente de actualizar
    _checkPendingPhotoUpdate(perfilForm, loginService);

    // Actualizar datos del perfil cuando cambien los datos del login service
    // Usar addPostFrameCallback para evitar setState durante build
    if (perfilForm.userDataLogged != loginService.userDataLogged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        perfilForm.updateProfile(loginService.userDataLogged);
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Header con gradiente y avatar
              Consumer<PerfilFormProvider>(
                builder: (context, perfilForm, child) {
                  return ModernHeader(
                    userName:
                        '${perfilForm.userDataLogged?.nombres} ${perfilForm.userDataLogged?.apellidos}',
                    userPhoto: perfilForm.getDisplayImage(),
                    onPhotoTap: () => _showPhotoOptions(context, base),
                  );
                },
              ),

              // Información del usuario
              UserInfoCard(
                userData: perfilForm.userDataLogged,
              ),

              // Formulario de datos personales
              const ModernFormProfile(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showPhotoOptions(BuildContext context, String base) {
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
                  child: PhotoOptionButton(
                    icon: Icons.camera_alt,
                    label: 'Cámara',
                    onTap: () async {
                      Navigator.pop(context);
                      await _pickImage(context, ImageSource.camera, base);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: PhotoOptionButton(
                    icon: Icons.photo_library,
                    label: 'Galería',
                    onTap: () async {
                      Navigator.pop(context);
                      await _pickImage(context, ImageSource.gallery, base);
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

  Future<void> _pickImage(
      BuildContext context, ImageSource source, String base) async {
    try {
      print('[PHOTO PICK] Iniciando pick de imagen: $source');
      print('[PHOTO PICK] Context: ${context.toString()}');

      // Verificar permisos para cámara
      if (source == ImageSource.camera) {
        // Verificar el estado actual del permiso
        final currentCameraStatus = await Permission.camera.status;
        print('Estado actual del permiso de cámara: $currentCameraStatus');

        // Solo mostrar diálogo explicativo si el permiso no está otorgado
        if (currentCameraStatus != PermissionStatus.granted) {
          final shouldProceed = await _showCameraPermissionAlert(context);
          if (!shouldProceed) {
            print('Usuario canceló el permiso de cámara');
            return;
          }
        }

        print('Solicitando permiso de cámara...');
        final cameraStatus = await Permission.camera.request();
        print(
            'Estado del permiso de cámara después de solicitar: $cameraStatus');

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
        // Verificar el estado actual del permiso
        final currentPhotosStatus = await Permission.photos.status;
        print('Estado actual del permiso de galería: $currentPhotosStatus');

        print('Solicitando permiso de galería...');
        final photosStatus = await Permission.photos.request();
        print(
            'Estado del permiso de galería después de solicitar: $photosStatus');

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

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        // Subir imagen directamente sin depender del contexto
        _uploadImageDirectly(context, image.path, base);
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

  /// Función para subir imagen directamente sin depender del contexto
  Future<void> _uploadImageDirectly(
      BuildContext context, String imagePath, String base) async {
    try {
      print('[PHOTO DIRECT] Iniciando subida directa: $imagePath');

      // Obtener datos del storage
      final storage = FlutterSecureStorage();
      final token = await storage.read(key: 'token') ?? '';

      if (token.isEmpty) {
        print('[PHOTO DIRECT] No se encontró token, cancelando subida');
        return;
      }

      // Crear instancia de InspeccionService
      final inspeccionService = InspeccionService();

      // Configurar el token en el loginService del InspeccionService
      inspeccionService.loginService.options.headers = {
        "x-access-token": token
      };
      print('[PHOTO DIRECT] Token configurado: ${token.substring(0, 10)}...');

      // Subir imagen al servidor
      print('[PHOTO DIRECT] Llamando a uploadImage...');
      final uploadResult = await inspeccionService.uploadImage(
        path: imagePath,
        company: base,
        folder: 'perfiles',
      );
      print('[PHOTO DIRECT] Resultado de uploadImage: $uploadResult');

      if (uploadResult != null && uploadResult['path'] != null) {
        final newImageUrl = uploadResult['path'] as String;
        print('[PHOTO DIRECT] Imagen subida exitosamente: $newImageUrl');

        // También intentar actualizar inmediatamente si es posible
        await _updateUserDataWithNewUrl(context, newImageUrl, base);
      } else {
        print(
            '[PHOTO DIRECT] Error: No se pudo obtener la URL de la imagen subida');
      }
    } catch (e) {
      print('[PHOTO DIRECT] Error al subir imagen: $e');
    }
  }

  /// Actualiza los datos del usuario con la nueva URL de imagen
  Future<void> _updateUserDataWithNewUrl(
      BuildContext context, String newImageUrl, String base) async {
    try {
      // Obtener datos necesarios del storage
      final storage = FlutterSecureStorage();
      final numeroDocumento = await storage.read(key: 'numeroDocumento') ?? '';

      final password = await storage.read(key: 'password') ?? '';
      print('[PHOTO DIRECT] Base: $base');
      print('[PHOTO DIRECT] Numero de documento: $numeroDocumento');
      print('[PHOTO DIRECT] Password: $password');

      if (numeroDocumento.isEmpty || password.isEmpty || base.isEmpty) {
        print('[PHOTO DIRECT] Datos de usuario incompletos en storage');
        return;
      }

      // Obtener datos del usuario desde SQLite
      final userData =
          await DBProvider.db.getUser(numeroDocumento, password, base);

      if (userData != null) {
        // Actualizar la URL de la imagen
        userData.urlFoto = newImageUrl;

        // Actualizar en SQLite
        await DBProvider.db.updateUser(userData);
        print('[PHOTO DIRECT] Datos actualizados en SQLite');

        // Guardar en storage para sincronización
        await storage.write(key: 'userDataUpdated', value: 'true');
        print('[PHOTO DIRECT] Marcado para sincronización');
      }
    } catch (e) {
      print('[PHOTO DIRECT] Error al actualizar datos del usuario: $e');
    }
  }

  /// Verifica si hay una imagen pendiente de actualizar desde una subida en background
  Future<void> _checkPendingPhotoUpdate(
      PerfilFormProvider perfilForm, LoginService loginService) async {
    try {
      final storage = FlutterSecureStorage();
      final pendingUrl = await storage.read(key: 'pendingPhotoUrl');
      final userDataUpdated = await storage.read(key: 'userDataUpdated');

      if (pendingUrl != null && pendingUrl.isNotEmpty) {
        print('[PHOTO PENDING] Encontrada imagen pendiente: $pendingUrl');

        // Actualizar la URL en el provider
        perfilForm.userDataLogged?.urlFoto = pendingUrl;

        // Actualizar en SQLite
        if (perfilForm.userDataLogged != null) {
          await DBProvider.db.updateUser(perfilForm.userDataLogged!);
          print('[PHOTO PENDING] URL actualizada en SQLite');
        }

        // Actualizar en LoginService
        loginService.userDataLogged.urlFoto = pendingUrl;

        // Limpiar la URL pendiente del storage
        await storage.delete(key: 'pendingPhotoUrl');
        print('[PHOTO PENDING] Imagen pendiente procesada y limpiada');

        // Notificar cambios usando updateProfile
        perfilForm.updateProfile(perfilForm.userDataLogged!);
      }

      // Si hay datos actualizados, refrescar desde SQLite
      if (userDataUpdated == 'true') {
        print('[PHOTO PENDING] Refrescando datos desde SQLite');

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
          if (userData != null) {
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
}
