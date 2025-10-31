import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:app_qinspecting/services/theme_service.dart';
import 'package:app_qinspecting/widgets/custom_loading_truck.dart';
import 'package:app_qinspecting/providers/loading_progress_provider.dart';
import 'package:app_qinspecting/widgets/settings/cache_management_section.dart';
import 'package:app_qinspecting/widgets/settings/appearance_section.dart';
import 'package:app_qinspecting/widgets/settings/notification_permission_section.dart';
import 'package:app_qinspecting/widgets/settings/location_permission_section.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loadingProgress =
        Provider.of<LoadingProgressProvider>(context, listen: true);
    if (loadingProgress.isLoading)
      return Scaffold(
          body: Center(
              child: CustomLoadingTruck(
        progress: loadingProgress.progress,
        message: loadingProgress.message,
        opacity: 1.0,
      )));
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(CupertinoIcons.back),
            ),
            title: const Text(
              'Configuración',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  themeService.toggleTheme();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        themeService.isDarkMode
                            ? 'Tema oscuro activado'
                            : 'Tema claro activado',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      backgroundColor: themeService.isDarkMode
                          ? Colors.grey[900]
                          : Colors.blue[600],
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                },
                icon: Icon(
                  themeService.isDarkMode
                      ? CupertinoIcons.sun_max
                      : CupertinoIcons.moon_fill,
                ),
              ),
            ],
            centerTitle: true,
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              // Grupo: Cache
              const CacheManagementSection(),
              const SizedBox(height: 16),
              // Grupo: Apariencia
              const AppearanceSection(),
              const SizedBox(height: 16),
              // Grupo: Notificaciones
              const NotificationPermissionSection(),
              const SizedBox(height: 16),
              // Grupo: Ubicación
              const LocationPermissionSection(),
            ],
          ),
        );
      },
    );
  }
}
