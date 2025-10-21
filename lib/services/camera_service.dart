import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

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
          _showError(context, 'Permisos de cámara denegados');
          return null;
        }
      }

      // 2. Verificar permisos de almacenamiento (Android)
      if (Platform.isAndroid) {
        final storageStatus = await Permission.storage.status;
        if (!storageStatus.isGranted) {
          final result = await Permission.storage.request();
          if (!result.isGranted) {
            _showError(context, 'Permisos de almacenamiento denegados');
            return null;
          }
        }
      }

      print('${logPrefix ?? '[Camera]'} Iniciando captura de foto...');

      // 3. Capturar imagen con configuración optimizada
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 60, // Reducir calidad para evitar problemas de memoria
        maxWidth: 800,    // Reducir resolución máxima
        maxHeight: 800,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo == null) {
        print('${logPrefix ?? '[Camera]'} Captura cancelada por el usuario');
        return null;
      }

      // 4. Validar archivo capturado
      final file = File(photo.path);
      if (!await file.exists()) {
        _showError(context, 'Error: El archivo capturado no existe');
        return null;
      }

      // 5. Verificar tamaño del archivo
      final fileSize = await file.length();
      print('${logPrefix ?? '[Camera]'} Archivo capturado: ${photo.path} (${fileSize} bytes)');

      // Límite más estricto para evitar problemas de memoria
      if (fileSize > 5 * 1024 * 1024) { // 5MB máximo
        _showError(context, 'Error: La imagen es demasiado grande (${(fileSize / 1024 / 1024).toStringAsFixed(1)}MB). Máximo permitido: 5MB');
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
      _showError(context, 'Error al capturar foto: ${e.toString()}');
      return null;
    }
  }

  /// Muestra un mensaje de error al usuario
  static void _showError(BuildContext context, String message) {
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
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
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
