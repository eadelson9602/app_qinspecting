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
  Set<int> _processingIds = {};

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
      print(
          '[CONNECTIVITY LISTENER] ⏳ Ya hay una verificación en proceso, esperando...');
      return;
    }

    // Verificar cooldown para evitar subidas demasiado frecuentes
    if (_lastUploadAttempt != null) {
      final timeSinceLastAttempt =
          DateTime.now().difference(_lastUploadAttempt!);
      if (timeSinceLastAttempt.inSeconds < 30) {
        print(
            '[CONNECTIVITY LISTENER] ⏳ Cooldown activo, esperando... (${30 - timeSinceLastAttempt.inSeconds}s restantes)');
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

      // Mostrar notificación de inicio
      if (allInspecciones.length > 0) {
        await NotificationService.showUploadProgressNotification(
          title: 'Subida Automática',
          body:
              'Iniciando subida de ${allInspecciones.length} inspección(es) pendiente(s)...',
          progress: 0,
          total: allInspecciones.length,
        );
      }

      // Configurar token
      await loginService.setTokenFromStorage();

      // Verificar que el token existe
      final nombreBase = loginService.selectedEmpresa.nombreBase;
      final tokenKey = nombreBase != null ? 'token_$nombreBase' : 'token';
      final token = await loginService.storage.read(key: tokenKey);

      if (token == null || token.isEmpty) {
        print(
            '[CONNECTIVITY LISTENER] ⚠️ No hay token disponible, no se pueden subir inspecciones automáticamente');
        _isCheckingUpload = false;
        return;
      }

      print('[CONNECTIVITY LISTENER] ✅ Token validado correctamente');

      // Subir cada inspección pendiente
      for (final inspeccion in allInspecciones) {
        try {
          if (inspeccion.id == null) continue;

          // Verificar si esta inspección ya está siendo procesada
          if (_processingIds.contains(inspeccion.id)) {
            print(
                '[CONNECTIVITY LISTENER] ⏭️ Inspección ${inspeccion.id} ya está siendo procesada, omitiendo...');
            continue;
          }

          // Marcar como en proceso
          _processingIds.add(inspeccion.id!);

          // Verificar nuevamente que la inspección sigue siendo pendiente
          final recheckPending = await DBProvider.db.getPendingInspections(
            loginService.selectedEmpresa.numeroDocumento ?? '',
            loginService.selectedEmpresa.nombreBase ?? '',
          );

          final isStillPending =
              recheckPending?.any((i) => i.id == inspeccion.id) ?? false;

          if (!isStillPending) {
            print(
                '[CONNECTIVITY LISTENER] ⏭️ Inspección ${inspeccion.id} ya fue enviada por otro proceso, omitiendo...');
            _processingIds.remove(inspeccion.id!);
            continue;
          }

          print(
              '[CONNECTIVITY LISTENER] ⬆️ Subiendo inspección ID: ${inspeccion.id}');

          // Usar el método sendInspeccion con notificaciones habilitadas
          final resultado = await inspeccionService.sendInspeccion(
            inspeccion,
            loginService.selectedEmpresa,
            showProgressNotifications:
                true, // Mostrar notificaciones de progreso
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

          // Remover del set de procesamiento
          _processingIds.remove(inspeccion.id!);
        } catch (e) {
          print(
              '[CONNECTIVITY LISTENER] ❌ Error al subir inspección ${inspeccion.id}: $e');
          // Remover del set de procesamiento en caso de error
          if (inspeccion.id != null) {
            _processingIds.remove(inspeccion.id!);
          }
        }
      }

      print('[CONNECTIVITY LISTENER] ✅ Proceso de subida completado');

      // Mostrar notificación de finalización
      await NotificationService.showSuccessNotification(
        title: 'Subida Automática',
        body: 'Subida automática de inspecciones completada',
      );

      // Descartar notificación de progreso después de 3 segundos
      Future.delayed(Duration(seconds: 3), () {
        NotificationService.cancelProgressNotification();
      });
    } catch (e) {
      print('[CONNECTIVITY LISTENER] ❌ Error en el proceso: $e');

      // Mostrar notificación de error
      await NotificationService.showErrorNotification(
        title: 'Error en Subida',
        body: 'Hubo un error al subir las inspecciones automáticamente',
      );
    } finally {
      _isCheckingUpload = false;
      _processingIds.clear(); // Limpiar el set de IDs procesados
    }
  }

  /// Cancela el listener de conectividad
  void dispose() {
    _debounceTimer?.cancel();
    _connectivitySubscription?.cancel();
    print('[CONNECTIVITY LISTENER] 🛑 Listener detenido');
  }
}
