import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:app_qinspecting/services/notification_service.dart';
import 'package:app_qinspecting/widgets/settings/settings_ios_group.dart';
import 'package:app_qinspecting/widgets/settings/settings_ios_tile.dart';
import 'package:app_qinspecting/widgets/settings/settings_themed_divider.dart';

class NotificationPermissionSection extends StatelessWidget {
  const NotificationPermissionSection({Key? key}) : super(key: key);

  Future<void> _requestNotificationPermission(BuildContext context) async {
    try {
      final areEnabled = await NotificationService.areNotificationsEnabled();

      if (areEnabled) {
        _showSnackBar(
          context,
          'Los permisos de notificación ya están otorgados',
          Colors.green,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      _showSnackBar(
        context,
        'Solicitando permiso de notificaciones...',
        Colors.orange,
        duration: const Duration(seconds: 2),
      );

      final granted = await NotificationService.requestPermissions();

      if (granted) {
        _showSnackBar(
          context,
          'Permisos de notificación otorgados correctamente',
          Colors.green,
        );
      } else {
        _showSnackBar(
          context,
          'Permisos de notificación denegados. Por favor, otorga los permisos en la configuración de la aplicación para recibir actualizaciones de las subidas.',
          Colors.orange,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      _showSnackBar(
        context,
        'Error al solicitar permisos: $e',
        Colors.red,
      );
    }
  }

  void _showSnackBar(
    BuildContext context,
    String message,
    Color backgroundColor, {
    Duration duration = const Duration(seconds: 4),
  }) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: duration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SettingsIosGroup(
      children: [
        SettingsIosTile(
          leading: CupertinoIcons.bell_solid,
          title: 'Notificaciones',
          subtitle:
              'Es necesario activar las notificaciones para recibir actualizaciones de las subidas.',
        ),
        SettingsThemedDivider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              color: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 12),
              onPressed: () => _requestNotificationPermission(context),
              borderRadius: BorderRadius.circular(10),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.bell, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Solicitar Permisos de Notificación',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

