import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/models/models.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/widgets/widgets.dart';

class SendPendingInspectionScree extends StatelessWidget {
  const SendPendingInspectionScree({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inspeccionProvider = Provider.of<InspeccionProvider>(context);
    final inspeccionService = Provider.of<InspeccionService>(context);
    // final loginService = Provider.of<LoginService>(context);
    final allInspecciones = inspeccionProvider.allInspecciones;
    inspeccionProvider.cargarTodosInspecciones();

    return Scaffold(
      appBar: const CustomAppBar().createAppBar(),
      drawer: const CustomDrawer(),
      body: Container(
        height: double.infinity,
        padding: EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 50),
        child: allInspecciones.length == 0
            ? Center(
                child: Text('Sin inspecciones pendientes por sincronizar'),
              )
            : ContentCardInspectionPending(
                allInspecciones: allInspecciones,
                inspeccionService: inspeccionService,
                inspeccionProvider: inspeccionProvider),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        mini: true,
        onPressed: () => print('tab'),
        child: Icon(Icons.upload_rounded),
      ),
    );
  }
}

class ContentCardInspectionPending extends StatelessWidget {
  const ContentCardInspectionPending({
    Key? key,
    required this.allInspecciones,
    required this.inspeccionService,
    required this.inspeccionProvider,
  }) : super(key: key);

  final List<ResumenPreoperacional> allInspecciones;
  final InspeccionService inspeccionService;
  final InspeccionProvider inspeccionProvider;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: allInspecciones.length,
        itemBuilder: (_, int i) {
          return Card(
            child: inspeccionService.isSaving
                ? Container(
                    padding: EdgeInsets.all(20),
                    child: Column(children: [
                      Image(
                        image: AssetImage('assets/images/loading_3.gif'),
                        // fit: BoxFit.cover,
                        height: 50,
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      LinearProgressIndicator(),
                    ]),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.search,
                          color: Colors.green,
                        ),
                        title: Text('Inspección No. ${i + 1}'),
                        subtitle: Text(
                            'Realizado el ${allInspecciones[i].resuPreFecha}'),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            child: const Text(
                              'Eliminar',
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: inspeccionService.isLoading
                                ? null
                                : () async {
                                    final responseDelete =
                                        await inspeccionProvider
                                            .eliminarResumenPreoperacional(
                                                allInspecciones[i].id!);

                                    await inspeccionProvider
                                        .eliminarRespuestaPreoperacional(
                                            allInspecciones[i].id!);

                                    showSimpleNotification(
                                        Text(
                                            'Inspección ${responseDelete} eliminada'),
                                        leading: Icon(Icons.check),
                                        autoDismiss: true,
                                        background: Colors.green,
                                        position: NotificationPosition.bottom);
                                  },
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                              child: const Text('Guardar'),
                              onPressed: inspeccionService.isLoading
                                  ? null
                                  : sendInspeccion(allInspecciones[i])),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ],
                  ),
          );
        });
  }

  sendInspeccion(ResumenPreoperacional inspeccion) async {
    try {
      inspeccionService.isSaving = true;
      // Se envia la foto del kilometraje al servidor
      Map<String, dynamic>? responseUploadKilometraje =
          await inspeccionService.uploadImage(
              path: inspeccion.resuPreFotokm!,
              company: 'qinspecting',
              folder: 'inspecciones');
      inspeccion.resuPreFotokm = responseUploadKilometraje?['path'];

      // Se envia la foto de la guia si tiene
      if (inspeccion.resuPreGuia?.isNotEmpty ?? false) {
        Map<String, dynamic>? responseUploadGuia =
            await inspeccionService.uploadImage(
                path: inspeccion.resuPreFotoguia!,
                company: 'qinspecting',
                folder: 'inspecciones');
        inspeccion.resuPreFotoguia = responseUploadGuia?['path'];
      }

      // Asignamos el id del remolque si tiene
      inspeccion.remolId =
          inspeccionProvider.tieneRemolque ? inspeccion.remolId : null;

      // Guardamos el resumen del preoperacional en el server
      final responseResumen =
          await inspeccionService.insertPreoperacional(inspeccion);
      // Consultamos en sqlite las respuestas
      List<Item> respuestas =
          await inspeccionProvider.cargarTodasRespuestas(inspeccion.id!);

      List<Future> Promesas = [];
      respuestas.forEach((element) {
        // loginService.selectedEmpresa!.nombreQi
        element.fkPreoperacional = responseResumen.idInspeccion;
        if (element.adjunto != null) {
          Promesas.add(inspeccionService
              .uploadImage(
                  path: element.adjunto!,
                  company: 'qinspecting',
                  folder: 'inspecciones')
              .then((response) {
            final responseUpload = ResponseUploadFile.fromMap(response!);
            element.adjunto = responseUpload.path;

            inspeccionService.insertRespuestasPreoperacional(element);
          }));
        } else {
          Promesas.add(
              inspeccionService.insertRespuestasPreoperacional(element));
        }
      });

      await inspeccionProvider.eliminarResumenPreoperacional(inspeccion.id!);

      await inspeccionProvider.eliminarRespuestaPreoperacional(inspeccion.id!);

      // Ejecutamos todas las peticiones
      await Future.wait(Promesas).then((value) {
        // print(value);
      });

      // show a notification at top of screen.
      showSimpleNotification(Text(responseResumen.message!),
          leading: Icon(Icons.check),
          autoDismiss: true,
          background: Colors.green,
          position: NotificationPosition.bottom);
      inspeccionService.isSaving = false;
    } catch (error) {
      showSimpleNotification(Text('Error: ${error}'),
          leading: Icon(Icons.check),
          autoDismiss: true,
          background: Colors.orange,
          position: NotificationPosition.bottom);
    }
  }
}
