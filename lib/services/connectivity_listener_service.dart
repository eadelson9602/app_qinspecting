import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/services/services.dart';

class ConnectivityListenerService {
  static final ConnectivityListenerService _instance =
      ConnectivityListenerService._internal();
  factory ConnectivityListenerService() => _instance;
  ConnectivityListenerService._internal();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isCheckingUpload = false;
  Timer? _debounceTimer;
  DateTime? _lastUploadAttempt;

  /// Inicializa el listener de conectividad
  void initialize() {
    print(
        '[CONNECTIVITY LISTENER] 🔄 Inicializando listener de conectividad...');
    print(
        '[CONNECTIVITY LISTENER] 📍 Este listener monitoreará la conexión y subirá automáticamente las inspecciones pendientes');
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final result =
            results.isNotEmpty ? results.first : ConnectivityResult.none;
        print(
            '[CONNECTIVITY LISTENER] 📡 Cambio de conectividad detectado: $result');
        _handleConnectivityChange(result);
      },
      onError: (error) {
        print('[CONNECTIVITY LISTENER] ❌ Error en listener: $error');
      },
    );
    print('[CONNECTIVITY LISTENER] ✅ Listener inicializado');
  }

  /// Maneja los cambios de conectividad
  Future<void> _handleConnectivityChange(ConnectivityResult result) async {
    // Si no hay conexión, no hacer nada
    if (result == ConnectivityResult.none) {
      print('[CONNECTIVITY LISTENER] ⚠️ Sin conexión detectada');
      return;
    }

    // Cancelar cualquier verificación previa pendiente
    _debounceTimer?.cancel();

    // Debounce: esperar 3 segundos después del último cambio antes de verificar
    _debounceTimer = Timer(const Duration(seconds: 3), () async {
      await _checkAndUploadPending();
    });
  }

  /// Verifica la conexión estable y sube las inspecciones pendientes
  Future<void> _checkAndUploadPending() async {
    // Evitar verificar si ya está en proceso
    if (_isCheckingUpload) {
      print('[CONNECTIVITY LISTENER] ⏳ Ya hay una verificación en proceso, esperando...');
      return;
    }
    
    // Verificar cooldown para evitar subidas demasiado frecuentes
    if (_lastUploadAttempt != null) {
      final timeSinceLastAttempt = DateTime.now().difference(_lastUploadAttempt!);
      if (timeSinceLastAttempt.inSeconds < 10) {
        print('[CONNECTIVITY LISTENER] ⏳ Cooldown activo, esperando... (${10 - timeSinceLastAttempt.inSeconds}s restantes)');
        return;
      }
    }
    
    _lastUploadAttempt = DateTime.now();

    _isCheckingUpload = true;
    print('[CONNECTIVITY LISTENER] 🔍 Verificando inspecciones pendientes...');

    try {
      // Obtener instancia del servicio
      final inspeccionService = InspeccionService();

      // Verificar si la conexión es estable
      final isStable = await inspeccionService.isConnectionStable();

      if (!isStable) {
        print(
            '[CONNECTIVITY LISTENER] ⚠️ La conexión no es estable, esperando...');
        _isCheckingUpload = false;
        return;
      }

      print('[CONNECTIVITY LISTENER] ✅ Conexión estable detectada');

      // Obtener instancia del servicio de login
      final loginService = LoginService();

      // Configurar token primero
      await loginService.setTokenFromStorage();

      // Verificar que hay una empresa seleccionada
      if (loginService.selectedEmpresa.nombreBase == null ||
          loginService.selectedEmpresa.nombreBase!.isEmpty) {
        print(
            '[CONNECTIVITY LISTENER] ⚠️ No hay empresa seleccionada, verificando datos en storage...');

        // Intentar cargar datos desde storage
        final readUsuario = await loginService.storage.read(key: 'usuario');
        final readNombreBase =
            await loginService.storage.read(key: 'nombreBase');

        if (readUsuario == null ||
            readNombreBase == null ||
            readUsuario.isEmpty ||
            readNombreBase.isEmpty) {
          print('[CONNECTIVITY LISTENER] ⚠️ No hay datos de sesión guardados');
          _isCheckingUpload = false;
          return;
        }

        print(
            '[CONNECTIVITY LISTENER] 📋 Datos de sesión encontrados, cargando empresa...');

        // Cargar empresa desde SQLite
        final tempEmpresa = await DBProvider.db.getEmpresaById(readNombreBase);
        if (tempEmpresa == null || tempEmpresa.nombreBase == null) {
          print('[CONNECTIVITY LISTENER] ⚠️ No se encontró empresa en SQLite');
          _isCheckingUpload = false;
          return;
        }

        loginService.selectedEmpresa = tempEmpresa;
        print(
            '[CONNECTIVITY LISTENER] ✅ Empresa cargada: ${tempEmpresa.nombreBase}');
      }

      // Obtener inspecciones pendientes desde SQLite
      final allInspecciones = await DBProvider.db.getPendingInspections(
        loginService.selectedEmpresa.numeroDocumento ?? '',
        loginService.selectedEmpresa.nombreBase ?? '',
      );

      if (allInspecciones == null || allInspecciones.isEmpty) {
        print(
            '[CONNECTIVITY LISTENER] 📭 No hay inspecciones pendientes para subir');
        _isCheckingUpload = false;
        return;
      }

      print(
          '[CONNECTIVITY LISTENER] 📋 Inspecciones pendientes encontradas: ${allInspecciones.length}');

      // Configurar token
      await loginService.setTokenFromStorage();

      // Subir cada inspección pendiente
      for (final inspeccion in allInspecciones) {
        try {
          print('[CONNECTIVITY LISTENER] ⬆️ Subiendo inspección ID: ${inspeccion.id}');

          // Usar el método sendInspeccion
          final resultado = await inspeccionService.sendInspeccion(
            inspeccion,
            loginService.selectedEmpresa,
            showProgressNotifications:
                false, // No mostrar notificaciones automáticas
          );

          if (resultado['ok'] == true) {
            print(
                '[CONNECTIVITY LISTENER] ✅ Inspección ${inspeccion.id} subida exitosamente');

            // Marcar como enviada en SQLite
            await DBProvider.db.marcarInspeccionComoEnviada(inspeccion.id!);

            print(
                '[CONNECTIVITY LISTENER] ✅ Inspección ${inspeccion.id} marcada como enviada en SQLite');
          } else {
            print(
                '[CONNECTIVITY LISTENER] ⚠️ Error al subir inspección ${inspeccion.id}: ${resultado['message']}');
          }
        } catch (e) {
          print(
              '[CONNECTIVITY LISTENER] ❌ Error al subir inspección ${inspeccion.id}: $e');
          // Continuar con la siguiente inspección
        }
      }

      print('[CONNECTIVITY LISTENER] ✅ Proceso de subida completado');
    } catch (e) {
      print('[CONNECTIVITY LISTENER] ❌ Error en el proceso: $e');
    } finally {
      _isCheckingUpload = false;
    }
  }

  /// Cancela el listener de conectividad
  void dispose() {
    _debounceTimer?.cancel();
    _connectivitySubscription?.cancel();
    print('[CONNECTIVITY LISTENER] 🛑 Listener detenido');
  }
}

