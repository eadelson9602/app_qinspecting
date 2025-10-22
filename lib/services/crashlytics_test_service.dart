import 'package:app_qinspecting/services/crashlytics_service.dart';

class CrashlyticsTestService {
  /// Prueba la integración de Crashlytics
  static Future<void> testCrashlyticsIntegration() async {
    try {
      // 1. Registrar información de usuario de prueba
      await CrashlyticsService.setUserInfo(
        userId: 'test_user_123',
        email: 'test@qinspecting.com',
        name: 'Usuario de Prueba',
      );

      // 2. Registrar información de sesión de prueba
      await CrashlyticsService.setSessionInfo(
        sessionId: 'test_session_${DateTime.now().millisecondsSinceEpoch}',
        base: 'test_base',
        vehiclePlate: 'ABC-123',
        inspectionType: 'preoperacional',
      );

      // 3. Registrar un log de prueba
      await CrashlyticsService.log('Crashlytics integration test started');

      // 4. Registrar un error de prueba (no fatal)
      await CrashlyticsService.recordError(
        Exception('Test error for Crashlytics integration'),
        StackTrace.current,
        reason: 'Testing Crashlytics integration',
        fatal: false,
      );

      // 5. Registrar un error de cámara de prueba
      await CrashlyticsService.recordCameraError(
        errorType: 'TEST_CAMERA_ERROR',
        errorMessage: 'Test camera error for integration verification',
        photoPath: '/test/path/image.jpg',
        fileSize: 1024000,
        additionalData: {
          'test_mode': true,
          'integration_check': true,
        },
      );

      // 6. Registrar un error de red de prueba
      await CrashlyticsService.recordNetworkError(
        endpoint: '/test/endpoint',
        errorMessage: 'Test network error for integration verification',
        statusCode: 500,
        requestData: {
          'test_mode': true,
          'integration_check': true,
        },
      );

      print('[CrashlyticsTest] ✅ Todos los tests de integración completados');
      print(
          '[CrashlyticsTest] 📊 Revisa Firebase Console en ~5 minutos para ver los reportes');
    } catch (e) {
      print('[CrashlyticsTest] ❌ Error durante las pruebas: $e');
    }
  }

  /// Prueba específica para errores de cámara
  static Future<void> testCameraErrors() async {
    try {
      // Simular diferentes tipos de errores de cámara
      final testErrors = [
        {
          'type': 'PERMISSION_DENIED',
          'message': 'Usuario denegó permisos de cámara',
        },
        {
          'type': 'FILE_TOO_LARGE',
          'message': 'Imagen capturada excede el límite de tamaño',
        },
        {
          'type': 'FILE_CORRUPTED',
          'message': 'Archivo de imagen corrupto',
        },
        {
          'type': 'CAPTURE_ERROR',
          'message': 'Error durante la captura de imagen',
        },
      ];

      for (final error in testErrors) {
        await CrashlyticsService.recordCameraError(
          errorType: error['type']!,
          errorMessage: error['message']!,
          photoPath: '/test/path/${error['type']}.jpg',
          fileSize: 2048000,
          additionalData: {
            'test_scenario': error['type'],
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
      }

      print('[CrashlyticsTest] ✅ Tests de errores de cámara completados');
    } catch (e) {
      print('[CrashlyticsTest] ❌ Error en tests de cámara: $e');
    }
  }

  /// Limpia datos de prueba
  static Future<void> cleanupTestData() async {
    try {
      await CrashlyticsService.clearCustomKeys();
      print('[CrashlyticsTest] ✅ Datos de prueba limpiados');
    } catch (e) {
      print('[CrashlyticsTest] ❌ Error limpiando datos: $e');
    }
  }
}
