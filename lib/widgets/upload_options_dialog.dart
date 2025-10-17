import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/services/notification_service.dart';
import 'package:app_qinspecting/models/models.dart';
import 'package:app_qinspecting/widgets/notification_permission_dialog.dart';

class UploadOptionsDialog extends StatelessWidget {
  final ResumenPreoperacional inspeccion;
  final Empresa empresa;
  final int indexSelected;

  const UploadOptionsDialog({
    Key? key,
    required this.inspeccion,
    required this.empresa,
    required this.indexSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.cloud_upload, color: Colors.blue),
          SizedBox(width: 10),
          Text('Opciones de Subida'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Cómo deseas subir la inspección?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 20),
          Column(
            children: [
              // Opción Normal
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 12),
                child: ElevatedButton.icon(
                  onPressed: () => _uploadNormal(context),
                  icon: Icon(Icons.cloud_upload),
                  label: Text('Subida Normal'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              // Descripción Normal
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Subida Normal',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      '• Mantén la app abierta durante la subida\n• Verás el progreso en tiempo real\n• Más rápido y confiable',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              // Opción Segundo Plano
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 12),
                child: ElevatedButton.icon(
                  onPressed: () => _uploadBackground(context),
                  icon: Icon(Icons.cloud_done),
                  label: Text('Segundo Plano'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              // Descripción Segundo Plano
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.green, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Segundo Plano',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      '• Puedes salir de la app\n• Notificaciones de progreso\n• Requiere permisos de notificación\n• ⚠️ Timeouts ocasionales en segundo plano',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar'),
        ),
      ],
    );
  }

  void _uploadNormal(BuildContext context) async {
    Navigator.of(context).pop();

    final inspeccionService =
        Provider.of<InspeccionService>(context, listen: false);

    try {
      final result =
          await inspeccionService.sendInspeccion(inspeccion, empresa);

      if (result['ok']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Inspección subida exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${result['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error inesperado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _uploadBackground(BuildContext context) async {
    // Capturar referencias antes de operaciones asíncronas
    final navigator = Navigator.of(context);

    try {
      // Verificar si ya tiene permisos de notificación
      final hasPermissions =
          await NotificationService.areNotificationsEnabled();

      if (hasPermissions) {
        // Ya tiene permisos, proceder directamente con la subida
        navigator.pop(); // Cerrar el diálogo de opciones
        await _startBackgroundUploadDirectly(context);
      } else {
        // No tiene permisos, mostrar diálogo de solicitud
        showDialog(
          context: context,
          builder: (dialogContext) => NotificationPermissionDialog(
            onPermissionGranted: () {
              // Cerrar el diálogo de opciones cuando se otorgan permisos
              navigator.pop();
            },
            onPermissionDenied: () => _showAlternativeOptions(context),
            inspeccion: inspeccion,
            empresa: empresa,
            indexSelected: indexSelected,
          ),
        );
      }
    } catch (e) {
      // En caso de error al verificar permisos, mostrar el diálogo por seguridad
      showDialog(
        context: context,
        builder: (dialogContext) => NotificationPermissionDialog(
          onPermissionGranted: () {
            navigator.pop();
          },
          onPermissionDenied: () => _showAlternativeOptions(context),
          inspeccion: inspeccion,
          empresa: empresa,
          indexSelected: indexSelected,
        ),
      );
    }
  }

  Future<void> _startBackgroundUploadDirectly(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final inspeccionService =
        Provider.of<InspeccionService>(context, listen: false);

    try {
      // Configurar el índice seleccionado y estado de guardado
      inspeccionService.indexSelected = indexSelected;
      inspeccionService.updateSaving(true);

      // Iniciar subida en segundo plano
      final result =
          await inspeccionService.sendInspeccionBackground(inspeccion, empresa);

      if (result['ok']) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
                'Subida iniciada en segundo plano. Puedes salir de la app.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error: ${result['message']}'),
            backgroundColor: Colors.red,
          ),
        );
        inspeccionService.updateSaving(false);
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error inesperado: $e'),
          backgroundColor: Colors.red,
        ),
      );
      inspeccionService.updateSaving(false);
    }
  }

  void _showAlternativeOptions(BuildContext context) {
    // Capturar referencias antes de operaciones asíncronas
    final navigator = Navigator.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info, color: Colors.blue),
            SizedBox(width: 10),
            Text('Opciones Disponibles'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sin permisos de notificación, puedes usar la subida normal que mantiene la app abierta.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Column(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _uploadNormal(context);
                    },
                    icon: Icon(Icons.cloud_upload),
                    label: Text('Subida Normal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      navigator.pop();
                      _uploadBackground(context);
                    },
                    icon: Icon(Icons.cloud_done),
                    label: Text('Intentar Segundo Plano'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => navigator.pop(),
            child: Text('Cancelar'),
          ),
        ],
      ),
    );
  }
}

/// Widget para mostrar el estado de subidas en segundo plano
class BackgroundUploadStatus extends StatefulWidget {
  @override
  _BackgroundUploadStatusState createState() => _BackgroundUploadStatusState();
}

class _BackgroundUploadStatusState extends State<BackgroundUploadStatus> {
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _checkUploadStatus();
  }

  void _checkUploadStatus() async {
    final inspeccionService =
        Provider.of<InspeccionService>(context, listen: false);
    final isUploading = await inspeccionService.isBackgroundUploadInProgress();
    setState(() {
      _isUploading = isUploading;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isUploading) return SizedBox.shrink();

    return Card(
      margin: EdgeInsets.all(8),
      child: ListTile(
        leading: CircularProgressIndicator(),
        title: Text('Subida en Progreso'),
        subtitle: Text('Una inspección se está subiendo en segundo plano'),
        trailing: IconButton(
          icon: Icon(Icons.cancel),
          onPressed: () async {
            final inspeccionService =
                Provider.of<InspeccionService>(context, listen: false);
            await inspeccionService.cancelBackgroundUpload();
            _checkUploadStatus();
          },
        ),
      ),
    );
  }
}
