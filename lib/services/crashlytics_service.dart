import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class CrashlyticsService {
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  /// Inicializa Firebase Crashlytics
  static Future<void> initialize() async {
    try {
      // Configurar Crashlytics para capturar errores de Flutter
      FlutterError.onError = (errorDetails) {
        _crashlytics.recordFlutterFatalError(errorDetails);
      };

      // Configurar Crashlytics para errores de plataforma
      PlatformDispatcher.instance.onError = (error, stack) {
        _crashlytics.recordError(error, stack, fatal: true);
        return true;
      };

      // Habilitar recolección de datos en modo debug (opcional)
      if (kDebugMode) {
        await _crashlytics.setCrashlyticsCollectionEnabled(true);
      }

      print('[Crashlytics] ✅ Inicializado correctamente');
    } catch (e) {
      print('[Crashlytics] ❌ Error al inicializar: $e');
    }
  }

  /// Registra un error no fatal
  static Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    try {
      await _crashlytics.recordError(
        exception,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );
      print('[Crashlytics] Error registrado: $exception');
    } catch (e) {
      print('[Crashlytics] Error al registrar: $e');
    }
  }

  /// Registra un error personalizado con contexto
  static Future<void> recordCustomError({
    required String message,
    required String category,
    Map<String, dynamic>? customData,
    StackTrace? stackTrace,
  }) async {
    try {
      // Agregar datos personalizados
      if (customData != null) {
        customData.forEach((key, value) {
          _crashlytics.setCustomKey(key, value.toString());
        });
      }

      // Crear un error personalizado
      final customException = Exception('$category: $message');

      await _crashlytics.recordError(
        customException,
        stackTrace ?? StackTrace.current,
        reason: message,
        fatal: false,
      );

      print(
          '[Crashlytics] Error personalizado registrado: $category - $message');
    } catch (e) {
      print('[Crashlytics] Error al registrar error personalizado: $e');
    }
  }

  /// Registra información del usuario
  static Future<void> setUserInfo({
    required String userId,
    String? email,
    String? name,
  }) async {
    try {
      await _crashlytics.setUserIdentifier(userId);

      if (email != null) {
        await _crashlytics.setCustomKey('user_email', email);
      }

      if (name != null) {
        await _crashlytics.setCustomKey('user_name', name);
      }

      print('[Crashlytics] Información de usuario establecida: $userId');
    } catch (e) {
      print('[Crashlytics] Error al establecer información de usuario: $e');
    }
  }

  /// Registra información de la sesión actual
  static Future<void> setSessionInfo({
    required String sessionId,
    String? base,
    String? vehiclePlate,
    String? inspectionType,
  }) async {
    try {
      await _crashlytics.setCustomKey('session_id', sessionId);

      if (base != null) {
        await _crashlytics.setCustomKey('base', base);
      }

      if (vehiclePlate != null) {
        await _crashlytics.setCustomKey('vehicle_plate', vehiclePlate);
      }

      if (inspectionType != null) {
        await _crashlytics.setCustomKey('inspection_type', inspectionType);
      }

      print('[Crashlytics] Información de sesión establecida: $sessionId');
    } catch (e) {
      print('[Crashlytics] Error al establecer información de sesión: $e');
    }
  }

  /// Registra un log personalizado
  static Future<void> log(String message) async {
    try {
      await _crashlytics.log(message);
      print('[Crashlytics] Log: $message');
    } catch (e) {
      print('[Crashlytics] Error al registrar log: $e');
    }
  }

  /// Registra errores específicos de cámara
  static Future<void> recordCameraError({
    required String errorType,
    required String errorMessage,
    String? photoPath,
    int? fileSize,
    Map<String, dynamic>? additionalData,
  }) async {
    final customData = {
      'error_type': errorType,
      'photo_path': photoPath ?? 'unknown',
      'file_size': fileSize?.toString() ?? 'unknown',
      'timestamp': DateTime.now().toIso8601String(),
      ...?additionalData,
    };

    await recordCustomError(
      message: errorMessage,
      category: 'CAMERA_ERROR',
      customData: customData,
    );
  }

  /// Registra errores específicos de red
  static Future<void> recordNetworkError({
    required String endpoint,
    required String errorMessage,
    int? statusCode,
    Map<String, dynamic>? requestData,
  }) async {
    final customData = {
      'endpoint': endpoint,
      'status_code': statusCode?.toString() ?? 'unknown',
      'timestamp': DateTime.now().toIso8601String(),
      ...?requestData,
    };

    await recordCustomError(
      message: errorMessage,
      category: 'NETWORK_ERROR',
      customData: customData,
    );
  }

  /// Registra errores específicos de base de datos
  static Future<void> recordDatabaseError({
    required String operation,
    required String errorMessage,
    String? tableName,
    Map<String, dynamic>? queryData,
  }) async {
    final customData = {
      'operation': operation,
      'table_name': tableName ?? 'unknown',
      'timestamp': DateTime.now().toIso8601String(),
      ...?queryData,
    };

    await recordCustomError(
      message: errorMessage,
      category: 'DATABASE_ERROR',
      customData: customData,
    );
  }

  /// Limpia datos personalizados
  static Future<void> clearCustomKeys() async {
    try {
      // Crashlytics no tiene un método directo para limpiar todas las claves
      // pero podemos establecer las claves principales como vacías
      await _crashlytics.setCustomKey('session_id', '');
      await _crashlytics.setCustomKey('base', '');
      await _crashlytics.setCustomKey('vehicle_plate', '');
      await _crashlytics.setCustomKey('inspection_type', '');

      print('[Crashlytics] Claves personalizadas limpiadas');
    } catch (e) {
      print('[Crashlytics] Error al limpiar claves personalizadas: $e');
    }
  }
}
