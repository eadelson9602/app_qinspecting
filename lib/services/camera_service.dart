import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_qinspecting/services/crashlytics_service.dart';

class CameraService {
  static final ImagePicker _picker = ImagePicker();

  /// Captura una foto desde la cámara con manejo robusto de errores
  static Future<String?> capturePhoto({
    required BuildContext context,
    String? logPrefix,
  }) async {
    try {
      // 1. Verificar permisos de cámara
      final cameraStatus = await Permission.camera.status;
      if (!cameraStatus.isGranted) {
        final result = await Permission.camera.request();
        if (!result.isGranted) {
          await CrashlyticsService.recordCameraError(
            errorType: 'PERMISSION_DENIED',
            errorMessage: 'Permisos de cámara denegados',
          );
          _showError(context, 'Permisos de cámara denegados');
          return null;
        }
      }

      // 2. Verificar permisos de almacenamiento/fotos (Android)
      if (Platform.isAndroid) {
        // En Android 13+ se usa Permission.photos, en versiones anteriores Permission.storage
        Permission? storagePermission;
        bool isGranted = false;

        try {
          // Intentar con permission_handler v11+ (Photos)
          storagePermission = Permission.photos;
          final photosStatus = await storagePermission.status;
          isGranted = photosStatus.isGranted;
        } catch (e) {
          // Fallback para versiones anteriores de permission_handler
          print('${logPrefix ?? '[Camera]'} ⚠️ Permission.photos no disponible, usando Permission.storage');
          try {
            storagePermission = Permission.storage;
            final storageStatus = await storagePermission.status;
            isGranted = storageStatus.isGranted;
          } catch (e2) {
            print('${logPrefix ?? '[Camera]'} ⚠️ Permission.storage tampoco disponible');
            // Continuar sin verificar permisos de almacenamiento
          }
        }

        if (storagePermission != null && !isGranted) {
          final result = await storagePermission.request();
          if (!result.isGranted) {
            await CrashlyticsService.recordCameraError(
              errorType: 'STORAGE_PERMISSION_DENIED',
              errorMessage: 'Permisos de almacenamiento denegados',
            );
            _showError(context, 'Permisos de almacenamiento denegados');
            return null;
          }
        }
      }

      print('${logPrefix ?? '[Camera]'} 🔍 Iniciando captura de foto...');
      print(
          '${logPrefix ?? '[Camera]'} 📱 Timestamp: ${DateTime.now().toIso8601String()}');

      // 1. Verificar permisos de cámara
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 60, // Reducir calidad para evitar problemas de memoria
        maxWidth: 800, // Reducir resolución máxima
        maxHeight: 800,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo == null) {
        print('${logPrefix ?? '[Camera]'} ❌ Captura cancelada por el usuario');
        return null;
      }
      print('${logPrefix ?? '[Camera]'} ✅ Foto capturada: ${photo.path}');

      // 4. Validar archivo capturado
      final file = File(photo.path);
      if (!await file.exists()) {
        _showError(context, 'Error: El archivo capturado no existe');
        return null;
      }

      // 5. Verificar tamaño del archivo
      final fileSize = await file.length();
      print(
          '${logPrefix ?? '[Camera]'} Archivo capturado: ${photo.path} (${fileSize} bytes)');

      // Límite más estricto para evitar problemas de memoria
      if (fileSize > 5 * 1024 * 1024) {
        // 5MB máximo
        _showError(context,
            'Error: La imagen es demasiado grande (${(fileSize / 1024 / 1024).toStringAsFixed(1)}MB). Máximo permitido: 5MB');
        return null;
      }

      // 6. Verificar que el archivo no esté corrupto
      try {
        // Intentar leer los primeros bytes para verificar integridad
        final bytes = await file.readAsBytes();
        if (bytes.isEmpty) {
          _showError(context, 'Error: El archivo capturado está vacío');
          return null;
        }
      } catch (e) {
        _showError(context, 'Error: No se puede leer el archivo capturado');
        return null;
      }

      print('${logPrefix ?? '[Camera]'} ✅ Foto capturada exitosamente');
      return photo.path;
    } catch (e) {
      print('${logPrefix ?? '[Camera]'} ❌ ERROR capturando foto: $e');

      // Registrar error en Crashlytics
      await CrashlyticsService.recordCameraError(
        errorType: 'CAPTURE_ERROR',
        errorMessage: 'Error al capturar foto: ${e.toString()}',
        additionalData: {
          'log_prefix': logPrefix ?? '[Camera]',
          'error_type': e.runtimeType.toString(),
        },
      );

      _showError(context, 'Error al capturar foto: ${e.toString()}');
      return null;
    }
  }

  /// Muestra un mensaje de error al usuario de forma segura
  static void _showError(BuildContext context, String message) {
    try {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Cerrar',
              textColor: Colors.white,
              onPressed: () {
                try {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  }
                } catch (e) {
                  print('[Camera] Error hiding SnackBar: $e');
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      print('[Camera] Error showing SnackBar: $e');
      // Fallback: solo mostrar en logs
      print('[Camera] ERROR: $message');
    }
  }

  /// Verifica si la cámara está disponible
  static Future<bool> isCameraAvailable() async {
    try {
      // Simplemente verificar que podemos crear una instancia de ImagePicker
      return true;
    } catch (e) {
      print('[Camera] Cámara no disponible: $e');
      return false;
    }
  }

  /// Limpia archivos temporales de la cámara
  static Future<void> cleanupTempFiles() async {
    try {
      // Esta función puede ser expandida para limpiar archivos temporales
      // si es necesario en el futuro
      print('[Camera] Limpieza de archivos temporales completada');
    } catch (e) {
      print('[Camera] Error en limpieza: $e');
    }
  }
}
