import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/services/notification_service.dart';
import 'package:app_qinspecting/models/models.dart';

class NotificationPermissionDialog extends StatelessWidget {
  final VoidCallback onPermissionGranted;
  final VoidCallback? onPermissionDenied;
  final ResumenPreoperacional inspeccion;
  final Empresa empresa;
  final int indexSelected;

  const NotificationPermissionDialog({
    Key? key,
    required this.onPermissionGranted,
    this.onPermissionDenied,
    required this.inspeccion,
    required this.empresa,
    required this.indexSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.notifications_active, color: Colors.blue),
          SizedBox(width: 10),
          Text('Permisos de Notificación'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Para subir inspecciones en segundo plano necesitamos permisos de notificación.',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 15),
          Text(
            'Esto nos permite:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Expanded(child: Text('Mostrar el progreso de subida')),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Expanded(child: Text('Notificar cuando termine la subida')),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Expanded(
                  child: Text('Continuar subiendo aunque salgas de la app')),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onPermissionDenied?.call();
          },
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await _requestPermissions(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: Text('Permitir Notificaciones'),
        ),
      ],
    );
  }

  Future<void> _requestPermissions(BuildContext context) async {
    // Guardar referencias antes de operaciones asíncronas
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Solicitando permisos...'),
            ],
          ),
        ),
      );

      // Solicitar permisos
      final granted = await NotificationService.requestPermissions();

      // Cerrar diálogo de carga
      navigator.pop();

      if (granted) {
        // Mostrar confirmación de éxito
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
                '✅ Permisos otorgados. Iniciando subida en segundo plano...'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Iniciar proceso de subida automáticamente
        print(
            '🚀 DEBUG: NotificationPermissionDialog - Iniciando subida automática');
        await _startBackgroundUpload(context);
        print('✅ DEBUG: NotificationPermissionDialog - Subida iniciada');

        onPermissionGranted();
      } else {
        // Mostrar error y opciones alternativas
        _showPermissionDeniedDialog(context);
      }
    } catch (e) {
      // Cerrar diálogo de carga si está abierto
      navigator.pop();

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('❌ Error solicitando permisos: $e'),
          backgroundColor: Colors.red,
        ),
      );
      onPermissionDenied?.call();
    }
  }

  Future<void> _startBackgroundUpload(BuildContext context) async {
    print('🚀 DEBUG: _startBackgroundUpload iniciado');

    // Guardar referencias antes de operaciones asíncronas
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final inspeccionService =
        Provider.of<InspeccionService>(context, listen: false);

    try {
      // Configurar el índice seleccionado y estado de guardado
      print('⚙️ DEBUG: Configurando índice seleccionado: $indexSelected');
      inspeccionService.indexSelected = indexSelected;
      inspeccionService.updateSaving(true);
      print('✅ DEBUG: Estado de guardado actualizado');

      // Iniciar subida en segundo plano
      print('🔄 DEBUG: Llamando a sendInspeccionBackground...');
      final result =
          await inspeccionService.sendInspeccionBackground(inspeccion, empresa);
      print('✅ DEBUG: sendInspeccionBackground completado: ${result['ok']}');

      if (result['ok']) {
        // Verificar que el contexto sigue siendo válido antes de mostrar SnackBar
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
                'Subida iniciada en segundo plano. Puedes salir de la app.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );
        print('✅ DEBUG: SnackBar de éxito mostrado');
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error: ${result['message']}'),
            backgroundColor: Colors.red,
          ),
        );
        inspeccionService.updateSaving(false);
        print('❌ DEBUG: Error en subida: ${result['message']}');
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error inesperado: $e'),
          backgroundColor: Colors.red,
        ),
      );
      inspeccionService.updateSaving(false);
      print('❌ ERROR: Error inesperado en _startBackgroundUpload: $e');
    }
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 10),
            Text('Permisos Denegados'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Los permisos de notificación fueron denegados. Sin estos permisos:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 15),
            Row(
              children: [
                Icon(Icons.close, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Expanded(child: Text('No podrás ver el progreso de subida')),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.close, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Expanded(child: Text('No sabrás cuándo termine la subida')),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.close, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Expanded(
                    child:
                        Text('La subida podría detenerse al salir de la app')),
              ],
            ),
            SizedBox(height: 15),
            Text(
              'Puedes activar los permisos manualmente en Configuración > Apps > Tu App > Permisos > Notificaciones',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onPermissionDenied?.call();
            },
            child: Text('Entendido'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _requestPermissions(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Text('Intentar de Nuevo'),
          ),
        ],
      ),
    );
  }
}
