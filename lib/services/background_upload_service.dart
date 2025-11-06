import 'package:app_qinspecting/models/models.dart';
import 'package:app_qinspecting/services/notification_service.dart';
import 'package:app_qinspecting/services/real_background_upload_service.dart';
import 'package:app_qinspecting/services/inspeccion_service.dart';

/// Servicio para manejar subidas con notificaciones
class BackgroundUploadService {
  static bool _isUploading = false;

  /// Inicializa el servicio
  static Future<void> initialize() async {
    await RealBackgroundUploadService.initialize();
    print('📱 DEBUG: BackgroundUploadService inicializado');
  }

  /// Programa una tarea de subida
  static Future<void> scheduleUploadTask({
    required ResumenPreoperacional inspeccion,
    required Empresa empresa,
    required String token,
    required InspeccionService inspeccionService,
  }) async {
    print('📅 DEBUG: BackgroundUploadService.scheduleUploadTask iniciado');
    print('📋 DEBUG: Inspección ID: ${inspeccion.id}');
    print('🏢 DEBUG: Empresa: ${empresa.nombreQi}');
    print('🔑 DEBUG: Token: ${token.substring(0, 10)}...');

    // Validación: no iniciar si no hay inspección lista
    final bool inspeccionValida = (inspeccion.id != null && inspeccion.id != 0) ||
        (inspeccion.respuestas != null && inspeccion.respuestas!.isNotEmpty);
    if (!inspeccionValida) {
      print('⚠️ WARNING: No hay inspección válida para subir. Se cancela programación.');
      _isUploading = false;
      return;
    }

    if (_isUploading) {
      print(
          '⚠️ WARNING: Ya hay una subida en progreso, cancelando la anterior...');
      await cancelUploadTask();
    }

    _isUploading = true;
    print('📱 DEBUG: Iniciando subida con servicio real');

    try {
      // Iniciar servicio de fondo real
      print(
          '🔄 DEBUG: Llamando a RealBackgroundUploadService.startUploadService...');
      await RealBackgroundUploadService.startUploadService(
        inspeccion: inspeccion,
        empresa: empresa,
        token: token,
        inspeccionService: inspeccionService,
      );
      print(
          '✅ DEBUG: RealBackgroundUploadService.startUploadService completado');

      // Mostrar notificación inicial
      print('📱 DEBUG: Mostrando notificación inicial...');
      await NotificationService.showUploadProgressNotification(
        title: 'Subiendo Inspección',
        body: 'Subida iniciada en segundo plano...',
        progress: 0,
        total: 100,
      );
      print('✅ DEBUG: Notificación inicial mostrada');
    } catch (e) {
      print('❌ ERROR: Error iniciando servicio de fondo: $e');
      _isUploading = false;
      rethrow;
    }
  }

  /// Cancela la tarea de subida
  static Future<void> cancelUploadTask() async {
    await RealBackgroundUploadService.stopUploadService();
    await NotificationService.cancelProgressNotification();
    _isUploading = false;
    print('📱 DEBUG: Tarea de subida cancelada');
  }

  /// Verifica si hay una tarea en progreso
  static Future<bool> isUploadInProgress() async {
    return await RealBackgroundUploadService.isServiceRunning();
  }
}
