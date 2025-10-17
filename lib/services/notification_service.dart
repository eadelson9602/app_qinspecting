import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
        AndroidInitializationSettings('@mipmap/ic_launcher');

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
      initializationSettings,
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
    final percentage = ((progress / total) * 100).round();

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
      _notificationId,
      title,
      '$body ($progress/$total - $percentage%)',
      notificationDetails,
      payload: payload,
    );

    // Actualizar progreso
    await _updateProgressNotification(progress, total);
  }

  /// Actualiza el progreso de la notificación
  static Future<void> _updateProgressNotification(
      int progress, int total) async {
    final percentage = ((progress / total) * 100).round();

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
      _notificationId,
      'Subiendo Inspección',
      'Progreso: $progress/$total ($percentage%)',
      notificationDetails,
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
      icon: '@mipmap/ic_launcher',
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
      _notificationId + 1,
      title,
      body,
      notificationDetails,
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
      icon: '@mipmap/ic_launcher',
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
      _notificationId + 2,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Cancela todas las notificaciones
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Cancela la notificación de progreso específica
  static Future<void> cancelProgressNotification() async {
    await _notifications.cancel(_notificationId);
  }

  /// Obtiene el estado de las notificaciones
  static Future<bool> areNotificationsEnabled() async {
    final result = await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();
    return result ?? true;
  }

  /// Solicita permisos de notificación
  static Future<bool> requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }

    return true; // iOS maneja los permisos automáticamente
  }
}
