import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:app_qinspecting/widgets/settings/settings_ios_group.dart';
import 'package:app_qinspecting/widgets/settings/settings_ios_tile.dart';
import 'package:app_qinspecting/widgets/settings/settings_themed_divider.dart';

class LocationPermissionSection extends StatelessWidget {
  const LocationPermissionSection({Key? key}) : super(key: key);

  Future<void> _requestLocationPermission(BuildContext context) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        _showSnackBar(
          context,
          'El servicio de ubicación está deshabilitado. Por favor, actívalo en la configuración del dispositivo.',
          Colors.orange,
          duration: const Duration(seconds: 4),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar(
          context,
          'Permisos de ubicación denegados permanentemente. Por favor, otorga los permisos en la configuración de la aplicación.',
          Colors.red,
          duration: const Duration(seconds: 5),
        );
        return;
      }

      if (permission == LocationPermission.denied) {
        _showSnackBar(
          context,
          'Solicitando permiso de ubicación...',
          Colors.orange,
          duration: const Duration(seconds: 2),
        );

        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          _showSnackBar(
            context,
            'Permisos de ubicación denegados',
            Colors.red,
          );
          return;
        }
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        _showSnackBar(
          context,
          'Permisos de ubicación otorgados correctamente',
          Colors.green,
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
          leading: CupertinoIcons.location_solid,
          title: 'Ubicación',
          subtitle:
              'Es necesario activar el GPS para el correcto funcionamiento.',
        ),
        SettingsThemedDivider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              color: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 12),
              onPressed: () => _requestLocationPermission(context),
              borderRadius: BorderRadius.circular(10),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.location, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Solicitar Acceso GPS',
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

