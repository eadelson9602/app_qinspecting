import 'package:flutter/material.dart';
import 'package:app_qinspecting/widgets/notification_permission_dialog.dart';
import 'package:provider/provider.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/models/inspeccion.dart';
import 'package:app_qinspecting/ui/app_theme.dart';

class NotificationPermissionBanner extends StatefulWidget {
  const NotificationPermissionBanner({Key? key}) : super(key: key);

  @override
  State<NotificationPermissionBanner> createState() =>
      _NotificationPermissionBannerState();
}

class _NotificationPermissionBannerState
    extends State<NotificationPermissionBanner> {
  bool _hasPermissions = true;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // Verificar si el permiso está denegado o bloqueado
    final isDeniedOrBlocked =
        await NotificationService.isNotificationPermissionDeniedOrBlocked();
    if (mounted) {
      setState(() {
        _hasPermissions = !isDeniedOrBlocked;
        _isChecking = false;
      });
    }
  }

  Future<void> _requestPermissions() async {
    final loginService = Provider.of<LoginService>(context, listen: false);

    // Mostrar diálogo de permisos
    showDialog(
      context: context,
      builder: (dialogContext) => NotificationPermissionDialog(
        onPermissionGranted: () {
          if (dialogContext.mounted) {
            Navigator.of(dialogContext).pop();
          }
          _checkPermissions();
        },
        onPermissionDenied: () {
          if (dialogContext.mounted) {
            Navigator.of(dialogContext).pop();
          }
        },
        inspeccion: ResumenPreoperacional(),
        empresa: loginService.selectedEmpresa,
        indexSelected: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const SizedBox.shrink();
    }

    if (_hasPermissions) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightGreen,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryGreen.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: AppTheme.primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mejora tu experiencia',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Activa las notificaciones para enviar inspecciones en segundo plano',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black87
                        : Colors.green[800],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: _requestPermissions,
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Activar',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
