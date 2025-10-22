import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
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
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final backgroundColor = theme.scaffoldBackgroundColor;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header con gradiente
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor,
                    primaryColor.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  // Icono animado
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_active_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Permisos de Notificación',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Necesarios para el envío en segundo plano',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Contenido principal
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Para enviar inspecciones automáticamente necesitamos tu permiso para enviar notificaciones.',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Lista de beneficios
                  Text(
                    'Esto nos permite:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: theme.textTheme.titleMedium?.color,
                    ),
                  ),
                  SizedBox(height: 10),

                  _buildBenefitItem(
                    context,
                    Icons.cloud_upload_rounded,
                    'Enviar inspecciones automáticamente',
                    'Sin intervención manual',
                  ),
                  SizedBox(height: 6),
                  _buildBenefitItem(
                    context,
                    Icons.trending_up_rounded,
                    'Notificar el progreso de subida',
                    'Seguimiento en tiempo real',
                  ),
                  SizedBox(height: 6),
                  _buildBenefitItem(
                    context,
                    Icons.sync_rounded,
                    'Mantener la app sincronizada',
                    'Datos siempre actualizados',
                  ),
                ],
              ),
            ),

            // Botones de acción
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                        onPermissionDenied?.call();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(
                            color: primaryColor.withValues(alpha: 0.5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Ahora no',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _requestPermissions(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_rounded, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Permitir',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(
      BuildContext context, IconData icon, String title, String subtitle) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: 18,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _requestPermissions(BuildContext context) async {
    try {
      // Mostrar indicador de carga
      // showDialog(
      //   context: context,
      //   barrierDismissible: false,
      //   builder: (context) => AlertDialog(
      //     content: Row(
      //       children: [
      //         CircularProgressIndicator(),
      //         SizedBox(width: 20),
      //         Text('Solicitando permisos...'),
      //       ],
      //     ),
      //   ),
      // );

      // Solicitar permisos usando permission_handler como alternativa
      print('🔐 DEBUG: Solicitando permisos de notificación...');

      // Intentar con permission_handler primero
      final permissionStatus = await Permission.notification.request();
      print('🔐 DEBUG: Resultado permission_handler: $permissionStatus');

      // También intentar con NotificationService
      final notificationServiceResult =
          await NotificationService.requestPermissions();
      print(
          '🔐 DEBUG: Resultado NotificationService: $notificationServiceResult');

      // Considerar exitoso si cualquiera de los dos métodos funciona
      final granted = permissionStatus.isGranted || notificationServiceResult;
      print('🔐 DEBUG: Resultado final de permisos: $granted');

      // No hay diálogo de carga que cerrar ya que está comentado

      if (granted) {
        print('✅ DEBUG: Permisos otorgados, iniciando flujo de éxito');
        // Mostrar confirmación de éxito
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '✅ Permisos otorgados. Iniciando subida en segundo plano...'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }

        // Iniciar proceso de subida automáticamente solo si el contexto sigue activo
        if (context.mounted) {
          print(
              '🚀 DEBUG: NotificationPermissionDialog - Iniciando subida automática');
          await _startBackgroundUpload(context);
          print('✅ DEBUG: NotificationPermissionDialog - Subida iniciada');
        } else {
          print(
              '⚠️ DEBUG: Contexto desactivado, no se puede iniciar subida automática');
        }

        onPermissionGranted();
      } else {
        print('❌ DEBUG: Permisos denegados, mostrando diálogo de error');
        // Mostrar error y opciones alternativas
        _showPermissionDeniedDialog(context);
      }
    } catch (e) {
      print('❌ DEBUG: Error en _requestPermissions: $e');
      // No hay diálogo de carga que cerrar ya que está comentado

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error solicitando permisos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      onPermissionDenied?.call();
    }
  }

  Future<void> _startBackgroundUpload(BuildContext context) async {
    print('🚀 DEBUG: _startBackgroundUpload iniciado');

    // Verificar que el contexto sigue siendo válido antes de continuar
    if (!context.mounted) {
      print(
          '⚠️ DEBUG: Contexto desactivado en _startBackgroundUpload, cancelando');
      return;
    }

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
        if (context.mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(
                  'Subida iniciada en segundo plano. Puedes salir de la app.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 5),
            ),
          );
        }
        print('✅ DEBUG: SnackBar de éxito mostrado');
      } else {
        if (context.mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Error: ${result['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        inspeccionService.updateSaving(false);
        print('❌ DEBUG: Error en subida: ${result['message']}');
      }
    } catch (e) {
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
