import 'package:app_qinspecting/screens/loading_screen.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/services/background_upload_service.dart';
import 'package:app_qinspecting/widgets/widgets.dart';
import 'package:app_qinspecting/widgets/upload_options_dialog.dart';
import 'package:app_qinspecting/widgets/upload_progress_widgets.dart';

class SendPendingInspectionScree extends StatelessWidget {
  const SendPendingInspectionScree({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: CustomDrawer(),
      body: Container(
          height: double.infinity,
          padding: EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 50),
          child: ContentCardInspectionPending()),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButton: FloatingActionButton(
      //   mini: true,
      //   onPressed: inspeccionService.isSaving
      //       ? null
      //       : () async {
      //           List<Future> promesas = [];
      //           allInspecciones.forEach((element) {
      //             promesas.add(inspeccionService.sendInspeccion(element));
      //           });
      //           await Future.wait(promesas).then((value) {
      //             print(value);
      //           });
      //         },
      //   child: Icon(Icons.upload_rounded),
      // ),
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoTimer =
          Timer.periodic(const Duration(seconds: 8), (_) => _tryAutoSend());
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    super.dispose();
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
          .eliminarResumenPreoperacional(allInspecciones[0].id!);
      await inspeccionProvider
          .eliminarRespuestaPreoperacional(allInspecciones[0].id!);
      if (mounted) setState(() {});
    } finally {
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
          return Center(child: Text('Sin inspecciones por enviar'));
        }
        return Column(
          children: [
            // Widget de estado de subida en segundo plano
            BackgroundUploadStatusCard(),
            // Lista de inspecciones
            Expanded(
              child: ListView.builder(
                itemCount: allInspecciones.length,
                itemBuilder: (_, int i) {
                  return Column(children: [
                    // Indicador de progreso si está subiendo
                    UploadProgressIndicator(
                      index: i,
                      isUploading: inspeccionService.isSaving,
                    ),
                    // Card de la inspección
                    Card(
                      child: inspeccionService.isSaving &&
                              inspeccionService.indexSelected == i
                          ? Container(
                              padding: EdgeInsets.all(20),
                              child: Column(children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Image(
                                    image: AssetImage(
                                        'assets/images/loading_3.gif'),
                                    // fit: BoxFit.cover,
                                    height: 50,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Center(
                                    child: Text(
                                  'Por favor NO cierre y no se salga de la app, mientras se este enviando la inspección',
                                  textAlign: TextAlign.center,
                                )),
                                SizedBox(
                                  height: 10,
                                ),
                                // Progreso por lote: lote actual / total y barra determinada
                                Text(
                                    'Lote ${inspeccionService.currentBatchIndex} de ${inspeccionService.totalBatches}'),
                                SizedBox(height: 6),
                                LinearProgressIndicator(
                                    value: inspeccionService.batchProgress == 0
                                        ? null
                                        : inspeccionService.batchProgress),
                                SizedBox(height: 8),
                                // Mostrar progreso del proceso en segundo plano si está activo
                                FutureBuilder<bool>(
                                  future: BackgroundUploadService.isUploadInProgress(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData && snapshot.data == true) {
                                      return Column(
                                        children: [
                                          Text(
                                            'Proceso en segundo plano activo',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Progreso: ${(inspeccionService.batchProgress * 100).toStringAsFixed(1)}%',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                    return SizedBox.shrink();
                                  },
                                ),
                              ]),
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  title: Text('Inspección No. ${i + 1}'),
                                  subtitle: Text(
                                      'Realizado el ${allInspecciones[i].fechaPreoperacional}'),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: inspeccionService.isSaving
                                          ? null
                                          : () async {
                                              final responseDelete =
                                                  await inspeccionProvider
                                                      .eliminarResumenPreoperacional(
                                                          allInspecciones[i]
                                                              .id!);
                                              await inspeccionProvider
                                                  .eliminarRespuestaPreoperacional(
                                                      allInspecciones[i].id!);
                                              showSimpleNotification(
                                                  Text(
                                                      'Inspección ${responseDelete} eliminada'),
                                                  leading: Icon(Icons.check),
                                                  autoDismiss: true,
                                                  background: Colors.green,
                                                  position: NotificationPosition
                                                      .bottom);
                                            },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.picture_as_pdf_sharp,
                                        color: Colors.red,
                                      ),
                                      onPressed: inspeccionService.isSaving
                                          ? null
                                          : () async {
                                              inspeccionService.indexSelected =
                                                  i;
                                              Navigator.pushNamed(
                                                  context, 'pdf_offline',
                                                  arguments: [
                                                    allInspecciones[i]
                                                  ]);
                                            },
                                    ),
                                    IconButton(
                                        icon: Icon(
                                          Icons.send,
                                          color: Colors.green,
                                        ),
                                        onPressed: inspeccionService.isSaving
                                            ? null
                                            : () {
                                                // Mostrar diálogo de opciones de subida
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      UploadOptionsDialog(
                                                    inspeccion:
                                                        allInspecciones[i],
                                                    empresa: loginService
                                                        .selectedEmpresa,
                                                    indexSelected: i,
                                                  ),
                                                );
                                              }),
                                    const SizedBox(width: 8),
                                  ],
                                ),
                              ],
                            ),
                    )
                  ]);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
