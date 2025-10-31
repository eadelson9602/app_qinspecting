import 'package:app_qinspecting/screens/loading_screen.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/services/background_upload_service.dart';
import 'package:app_qinspecting/models/inspeccion.dart';
import 'package:app_qinspecting/widgets/widgets.dart';
import 'package:app_qinspecting/widgets/upload_progress_widgets.dart';
import 'package:app_qinspecting/widgets/notification_permission_dialog.dart';
import 'package:app_qinspecting/widgets/notification_permission_banner.dart';

class SendPendingInspectionScreen extends StatelessWidget {
  const SendPendingInspectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Inspecciones por enviar'),
      ),
      body: Container(
          height: double.infinity, child: ContentCardInspectionPending()),
    );
  }
}

class ContentCardInspectionPending extends StatefulWidget {
  const ContentCardInspectionPending({Key? key}) : super(key: key);

  @override
  State<ContentCardInspectionPending> createState() =>
      _ContentCardInspectionPendingState();
}

class _ContentCardInspectionPendingState
    extends State<ContentCardInspectionPending> {
  Timer? _autoTimer;
  Timer? _progressTimer;
  bool _isBackgroundUploadActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoTimer =
          Timer.periodic(const Duration(seconds: 8), (_) => _tryAutoSend());
      // Timer para actualizar el progreso del proceso en segundo plano
      _progressTimer = Timer.periodic(
          const Duration(seconds: 2), (_) => _updateBackgroundProgress());
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _progressTimer?.cancel();
    super.dispose();
  }

  Future<void> _updateBackgroundProgress() async {
    final isActive = await BackgroundUploadService.isUploadInProgress();
    if (mounted && _isBackgroundUploadActive != isActive) {
      setState(() {
        _isBackgroundUploadActive = isActive;
      });
    }
  }

  Future<void> _tryAutoSend() async {
    if (!mounted) return;
    final inspeccionProvider =
        Provider.of<InspeccionProvider>(context, listen: false);
    final loginService = Provider.of<LoginService>(context, listen: false);
    final inspeccionService =
        Provider.of<InspeccionService>(context, listen: false);

    if (inspeccionService.isSaving) return;

    final stable = await inspeccionService.isConnectionStable();
    if (!stable) return;

    final allInspecciones = await inspeccionProvider.cargarTodosInspecciones(
        loginService.userDataLogged.numeroDocumento!,
        loginService.userDataLogged.base!);
    if ((allInspecciones == null) || (allInspecciones.isEmpty)) return;

    try {
      inspeccionService.indexSelected = 0;
      inspeccionService.updateSaving(true);
      await inspeccionService.sendInspeccion(
          allInspecciones[0], loginService.selectedEmpresa);
      await inspeccionProvider
          .marcarResumenPreoperacionalComoEnviado(allInspecciones[0].id!);
      if (mounted) setState(() {});
    } finally {
      inspeccionService.updateSaving(false);
    }
  }

  Future<void> _startBackgroundUploadDirectly(BuildContext context,
      ResumenPreoperacional inspeccion, int indexSelected) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final inspeccionService =
        Provider.of<InspeccionService>(context, listen: false);
    final loginService = Provider.of<LoginService>(context, listen: false);

    // Verificar si ya hay un envío en progreso
    if (inspeccionService.isSaving) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
              'Ya hay una inspección enviándose. Por favor espera a que termine.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    try {
      // Verificar permisos de notificación
      final hasPermissions =
          await NotificationService.areNotificationsEnabled();

      if (!hasPermissions) {
        // Mostrar diálogo de permisos si no los tiene
        showDialog(
          context: context,
          builder: (dialogContext) => NotificationPermissionDialog(
            onPermissionGranted: () {
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
              // Intentar nuevamente después de otorgar permisos
              _startBackgroundUploadDirectly(
                  context, inspeccion, indexSelected);
            },
            onPermissionDenied: () {
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
              if (context.mounted) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                        'Se requieren permisos de notificación para el envío en segundo plano'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            inspeccion: inspeccion,
            empresa: loginService.selectedEmpresa,
            indexSelected: indexSelected,
          ),
        );
        return;
      }

      // Iniciar envío en segundo plano
      inspeccionService.indexSelected = indexSelected;
      inspeccionService.updateSaving(true);

      final result = await inspeccionService.sendInspeccionBackground(
          inspeccion, loginService.selectedEmpresa);

      if (result['ok']) {
        // Verificar permisos de notificación antes de mostrar el mensaje
        final hasNotificationsEnabled =
            await NotificationService.areNotificationsEnabled();

        if (hasNotificationsEnabled) {
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
              content: Text(
                  'Subida iniciada en segundo plano. Se requiere activar notificaciones para recibir actualizaciones.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );
        }
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

  @override
  Widget build(BuildContext context) {
    final inspeccionProvider = Provider.of<InspeccionProvider>(context);
    final loginService = Provider.of<LoginService>(context, listen: false);

    final inspeccionService =
        Provider.of<InspeccionService>(context, listen: true);
    return FutureBuilder(
      future: inspeccionProvider.cargarTodosInspecciones(
          loginService.userDataLogged.numeroDocumento!,
          loginService.userDataLogged.base!),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.data == null) {
          return LoadingScreen();
        }
        final allInspecciones = snapshot.data;
        if (allInspecciones.isEmpty) {
          return Column(
            children: [
              const NotificationPermissionBanner(),
              const SizedBox(height: 16),
              const EmptyInspectionsCard(),
              const SizedBox(height: 16),
            ],
          );
        }
        return Column(
          children: [
            // Banner de permisos de notificación (solo si no tiene permisos)
            const NotificationPermissionBanner(),
            // Widget de estado de subida en segundo plano
            BackgroundUploadStatusCard(),
            // Lista de inspecciones
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: allInspecciones.length,
                itemBuilder: (_, int i) {
                  return Column(
                    children: [
                      UploadProgressIndicator(
                        index: i,
                        isUploading: inspeccionService.isSaving,
                      ),
                      const SizedBox(height: 8),
                      PendingInspectionCard(
                        inspeccion: allInspecciones[i],
                        index: i,
                        isBackgroundUploadActive: _isBackgroundUploadActive,
                        onSendPressed: () => _startBackgroundUploadDirectly(
                          context,
                          allInspecciones[i],
                          i,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
