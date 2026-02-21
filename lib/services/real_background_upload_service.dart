import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_qinspecting/models/models.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/services/notification_service.dart';
import 'package:app_qinspecting/services/upload_foreground_service.dart';
import 'package:app_qinspecting/providers/providers.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Servicio real de subida en segundo plano (versión simplificada)
class RealBackgroundUploadService with WidgetsBindingObserver {
  static bool _isServiceRunning = false;
  static AppLifecycleState? _currentAppState;

  /// Inicializa el servicio
  static Future<void> initialize() async {
    print(
        '📱 DEBUG: Servicio de fondo real inicializado (versión simplificada)');

    // Registrar observer para detectar cambios de estado de la app
    WidgetsBinding.instance.addObserver(RealBackgroundUploadService());
    _currentAppState = WidgetsBinding.instance.lifecycleState;
    print('📱 DEBUG: Estado inicial de la app: $_currentAppState');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _currentAppState = state;
    print('📱 DEBUG: Estado de la app cambió a: $state');

    switch (state) {
      case AppLifecycleState.resumed:
        print('🟢 DEBUG: APP EN PRIMER PLANO - Conexiones normales');
        break;
      case AppLifecycleState.paused:
        print('🟡 DEBUG: APP EN SEGUNDO PLANO - Conexiones limitadas');
        break;
      case AppLifecycleState.inactive:
        print('🟠 DEBUG: APP INACTIVA - Transición de estado');
        break;
      case AppLifecycleState.detached:
        print('🔴 DEBUG: APP DESCONECTADA - Proceso terminado');
        break;
      case AppLifecycleState.hidden:
        print('⚫ DEBUG: APP OCULTA - Estado oculto');
        break;
    }
  }

  /// Inicia el servicio de fondo
  static Future<void> startUploadService({
    required ResumenPreoperacional inspeccion,
    required Empresa empresa,
    required String token,
    required InspeccionService inspeccionService,
  }) async {
    print('🔄 DEBUG: RealBackgroundUploadService.startUploadService iniciado');
    print('📋 DEBUG: Inspección ID: ${inspeccion.id}');
    print('🏢 DEBUG: Empresa: ${empresa.nombreQi}');
    print('🔑 DEBUG: Token: ${token.substring(0, 10)}...');

    if (_isServiceRunning) {
      print('⚠️ WARNING: Servicio ya está ejecutándose');
      return;
    }

    _isServiceRunning = true;

    // Guardar datos en SharedPreferences para el servicio
    print('💾 DEBUG: Guardando datos en SharedPreferences...');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('upload_inspeccion', jsonEncode(inspeccion.toJson()));
    await prefs.setString('upload_empresa', jsonEncode(empresa.toJson()));
    await prefs.setString('upload_token', token);
    print('✅ DEBUG: Datos guardados en SharedPreferences');

    // Ejecutar la subida usando la función existente
    print('🚀 DEBUG: Iniciando subida usando sendInspeccion...');
    _performUploadUsingExistingFunction(
        inspeccion, empresa, token, inspeccionService);

    print('📱 DEBUG: Servicio de fondo iniciado (versión simplificada)');
  }

  /// Ejecuta la subida usando la función existente sendInspeccion
  static Future<void> _performUploadUsingExistingFunction(
    ResumenPreoperacional inspeccion,
    Empresa empresa,
    String token,
    InspeccionService inspeccionService,
  ) async {
    try {
      print('🔄 DEBUG: _performUploadUsingExistingFunction iniciado');

      // Usar la instancia existente del servicio de inspección
      // Esto asegura que use la configuración correcta del LoginService
      print('🔑 DEBUG: Usando instancia existente de InspeccionService');
      print('🔑 DEBUG: Token completo: Bearer $token');

      // Mantener la app activa durante la subida
      print('🔋 DEBUG: Iniciando servicio de primer plano...');
      await UploadForegroundService.startForegroundService();
      print('✅ DEBUG: Servicio de primer plano iniciado');

      print('🔋 DEBUG: Activando Wakelock para mantener la app activa...');
      await WakelockPlus.enable();
      print('✅ DEBUG: Wakelock activado - La app permanecerá activa');

      print('🔋 DEBUG: Configurando UI del sistema...');
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: []);

      // Mostrar notificación de progreso inicial
      await NotificationService.showUploadProgressNotification(
        title: 'Subiendo Inspección',
        body: 'Iniciando subida en segundo plano...',
        progress: 0,
        total: 100,
      );

      // Usar la función existente sendInspeccion con notificaciones de progreso
      print(
          '📤 DEBUG: Llamando a sendInspeccion con notificaciones de progreso...');
      print(
          '📱 DEBUG: Estado actual de la app antes de subida: $_currentAppState');

      final result = await inspeccionService.sendInspeccion(inspeccion, empresa,
          showProgressNotifications: true);

      if (result['ok']) {
        // Mostrar notificación de éxito
        await NotificationService.showSuccessNotification(
          title: 'Subida Completada',
          body: 'La inspección se subió exitosamente',
        );

        // Eliminar datos de la inspección del SQLite después del envío exitoso
        print('🗑️ DEBUG: Eliminando datos de la inspección del SQLite...');
        try {
          final inspeccionProvider = InspeccionProvider();
          await inspeccionProvider
              .eliminarResumenPreoperacional(inspeccion.id!);
          await inspeccionProvider
              .eliminarRespuestaPreoperacional(inspeccion.id!);
          print(
              '✅ DEBUG: Datos de la inspección eliminados del SQLite exitosamente');
        } catch (e) {
          print('⚠️ WARNING: Error eliminando datos del SQLite: $e');
          // No lanzar excepción aquí para no afectar el proceso de subida
        }

        print('🎉 DEBUG: Subida completada exitosamente usando sendInspeccion');
      } else {
        await AppLogService.logError(
          'ENVIO_SEGUNDO_PLANO',
          'Error en sendInspeccion (segundo plano): ${result['message']}',
          error: result['message'],
        );
        throw Exception('Error en sendInspeccion: ${result['message']}');
      }
    } catch (e, st) {
      print('❌ ERROR: Error en _performUploadUsingExistingFunction: $e');

      await AppLogService.logError(
        'ENVIO_SEGUNDO_PLANO',
        'Error en subida en segundo plano.',
        error: e,
        stackTrace: st,
      );

      // Mostrar notificación de error
      await NotificationService.showErrorNotification(
        title: 'Error en Subida',
        body: 'Error: $e',
      );
    } finally {
      // Detener servicio de primer plano y desactivar Wakelock
      print('🔋 DEBUG: Deteniendo servicio de primer plano...');
      await UploadForegroundService.stopForegroundService();
      print('✅ DEBUG: Servicio de primer plano detenido');

      print('🔋 DEBUG: Desactivando Wakelock...');
      await WakelockPlus.disable();
      print('✅ DEBUG: Wakelock desactivado');

      print('🔋 DEBUG: Restaurando UI del sistema...');
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: SystemUiOverlay.values);
      print('✅ DEBUG: UI del sistema restaurada');

      _isServiceRunning = false;
      print('📱 DEBUG: Servicio de fondo finalizado');
    }
  }

  /// Detiene el servicio de fondo
  static Future<void> stopUploadService() async {
    print('📱 DEBUG: Servicio de fondo detenido (versión simplificada)');
    _isServiceRunning = false;
  }

  /// Verifica si el servicio está ejecutándose
  static Future<bool> isServiceRunning() async {
    return _isServiceRunning;
  }
}
