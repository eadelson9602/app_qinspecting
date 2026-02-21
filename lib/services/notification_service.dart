import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'upload_progress';
  static const String _channelName = 'Progreso de Subida';
  static const String _channelDescription =
      'Notificaciones del progreso de subida de inspecciones';

  static int _notificationId = 1000;

  /// Inicializa el servicio de notificaciones
  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Crear canal de notificación para Android
    await _createNotificationChannel();
  }

  /// Crea el canal de notificación para Android
  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
      showBadge: false,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Maneja el tap en la notificación
  static void _onNotificationTapped(NotificationResponse response) {
    // Aquí puedes manejar qué hacer cuando el usuario toca la notificación
    print('Notificación tocada: ${response.payload}');
  }

  /// Muestra una notificación de progreso persistente
  static Future<void> showUploadProgressNotification({
    required String title,
    required String body,
    required int progress,
    required int total,
    String? payload,
  }) async {
    // Validar parámetros para evitar valores inválidos
    final safeProgress = progress.clamp(0, total > 0 ? total : 1);
    final safeTotal = total > 0 ? total : 1;

    final percentage = ((safeProgress / safeTotal) * 100).round().clamp(0, 100);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showProgress: true,
      maxProgress: 100,
      progress: 0,
      onlyAlertOnce: true,
      silent: true,
      icon: '@mipmap/launcher_icon',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id: _notificationId,
      title: title,
      body: '$body ($safeProgress/$safeTotal - $percentage%)',
      notificationDetails: notificationDetails,
      payload: payload,
    );

    // Actualizar progreso
    await _updateProgressNotification(safeProgress, safeTotal);
  }

  /// Actualiza el progreso de la notificación
  static Future<void> _updateProgressNotification(
      int progress, int total) async {
    // Validar parámetros para evitar valores inválidos
    final safeProgress = progress.clamp(0, total > 0 ? total : 1);
    final safeTotal = total > 0 ? total : 1;

    final percentage = ((safeProgress / safeTotal) * 100).round().clamp(0, 100);

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showProgress: true,
      maxProgress: 100,
      progress: percentage,
      onlyAlertOnce: true,
      silent: true,
      icon: '@mipmap/launcher_icon',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id: _notificationId,
      title: 'Qinspecting',
      body: 'Progreso: $safeProgress/$safeTotal ($percentage%)',
      notificationDetails: notificationDetails,
    );
  }

  /// Muestra notificación de éxito
  static Future<void> showSuccessNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      ongoing: false,
      autoCancel: true,
      showProgress: false,
      icon: '@mipmap/launcher_icon',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id: _notificationId + 1,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }

  /// Muestra notificación de error
  static Future<void> showErrorNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      ongoing: false,
      autoCancel: true,
      showProgress: false,
      icon: '@mipmap/launcher_icon',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id: _notificationId + 2,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }

  /// Cancela todas las notificaciones
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Cancela la notificación de progreso específica
  static Future<void> cancelProgressNotification() async {
    await _notifications.cancel(id: _notificationId);
  }

  /// Obtiene el estado de las notificaciones
  static Future<bool> areNotificationsEnabled() async {
    final result = await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();
    return result ?? true;
  }

  /// Verifica si el permiso de notificaciones está denegado o bloqueado
  /// Retorna true si el permiso está denegado, bloqueado permanentemente o no está habilitado
  static Future<bool> isNotificationPermissionDeniedOrBlocked() async {
    try {
      // Verificar el estado del permiso usando permission_handler
      final permissionStatus = await Permission.notification.status;

      // Si el permiso está denegado o bloqueado permanentemente
      if (permissionStatus.isDenied || permissionStatus.isPermanentlyDenied) {
        return true;
      }

      // Si el permiso está concedido, verificar también si las notificaciones están habilitadas
      if (permissionStatus.isGranted) {
        final areEnabled = await areNotificationsEnabled();
        return !areEnabled;
      }

      // Para otros estados (limitado en iOS), verificar si están habilitadas
      final areEnabled = await areNotificationsEnabled();
      return !areEnabled;
    } catch (e) {
      print('❌ DEBUG: Error en isNotificationPermissionDeniedOrBlocked: $e');
      // En caso de error, verificar si están habilitadas como fallback
      final areEnabled = await areNotificationsEnabled();
      return !areEnabled;
    }
  }

  /// Solicita permisos de notificación
  static Future<bool> requestPermissions() async {
    try {
      print('🔐 DEBUG: NotificationService.requestPermissions iniciado');

      final androidPlugin =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        print('🔐 DEBUG: Plugin Android encontrado, solicitando permisos...');
        final granted = await androidPlugin.requestNotificationsPermission();
        print('🔐 DEBUG: Resultado del plugin Android: $granted');

        // Verificar también el estado actual
        final areEnabled = await areNotificationsEnabled();
        print('🔐 DEBUG: Estado actual de notificaciones: $areEnabled');

        // Si el plugin devuelve null o false, pero las notificaciones están habilitadas, devolver true
        if (granted == null || granted == false) {
          if (areEnabled) {
            print(
                '🔐 DEBUG: Notificaciones habilitadas manualmente, devolviendo true');
            return true;
          }
        }

        return granted ?? false;
      }

      print('🔐 DEBUG: No es Android, devolviendo true (iOS)');
      return true; // iOS maneja los permisos automáticamente
    } catch (e) {
      print('❌ DEBUG: Error en requestPermissions: $e');
      return false;
    }
  }
}
