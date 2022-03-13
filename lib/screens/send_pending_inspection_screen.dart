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
            : ListView.builder(
                itemCount: allInspecciones.length,
                itemBuilder: (_, int i) {
                  return Card(
                    child: inspeccionService.isSaving
                        ? Container(
                            padding: EdgeInsets.all(20),
                            child: Column(children: [
                              Image(
                                image:
                                    AssetImage('assets/images/loading_3.gif'),
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
                                                        allInspecciones[i].Id!);

                                            await inspeccionProvider
                                                .eliminarRespuestaPreoperacional(
                                                    allInspecciones[i].Id!);

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
                                  const SizedBox(width: 8),
                                  TextButton(
                                    child: const Text('Guardar'),
                                    onPressed: inspeccionService.isLoading
                                        ? null
                                        : () async {
                                            try {
                                              inspeccionService.isSaving = true;
                                              // Se envia la foto del kilometraje al servidor
                                              Map<String, dynamic>?
                                                  responseUploadKilometraje =
                                                  await inspeccionService.uploadImage(
                                                      path: allInspecciones[i]
                                                          .resuPreFotokm!,
                                                      company: 'qinspecting',
                                                      folder: 'inspecciones');
                                              allInspecciones[i].resuPreFotokm =
                                                  responseUploadKilometraje?[
                                                      'path'];

                                              // Se envia la foto de la guia si tiene
                                              if (allInspecciones[i]
                                                      .resuPreGuia
                                                      ?.isNotEmpty ??
                                                  false) {
                                                Map<String, dynamic>?
                                                    responseUploadGuia =
                                                    await inspeccionService.uploadImage(
                                                        path: allInspecciones[i]
                                                            .resuPreFotoguia!,
                                                        company: 'qinspecting',
                                                        folder: 'inspecciones');
                                                allInspecciones[i]
                                                        .resuPreFotoguia =
                                                    responseUploadGuia?['path'];
                                              }

                                              // Asignamos el id del remolque si tiene
                                              allInspecciones[i]
                                                  .remolId = inspeccionProvider
                                                      .tieneRemolque
                                                  ? allInspecciones[i].remolId
                                                  : null;

                                              // Guardamos el resumen del preoperacional en el server
                                              final responseResumen =
                                                  await inspeccionService
                                                      .insertPreoperacional(
                                                          allInspecciones[i]);
                                              // Consultamos en sqlite las respuestas
                                              List<Item> respuestas =
                                                  await inspeccionProvider
                                                      .cargarTodasRespuestas(
                                                          allInspecciones[i]
                                                              .Id!);

                                              List<Future> Promesas = [];
                                              respuestas.forEach((element) {
                                                // loginService.selectedEmpresa!.nombreQi
                                                element.fkPreoperacional =
                                                    responseResumen
                                                        .idInspeccion;
                                                if (element.adjunto != null) {
                                                  Promesas.add(inspeccionService
                                                      .uploadImage(
                                                          path:
                                                              element.adjunto!,
                                                          company:
                                                              'qinspecting',
                                                          folder:
                                                              'inspecciones')
                                                      .then((response) {
                                                    final responseUpload =
                                                        ResponseUploadFile
                                                            .fromMap(response!);
                                                    element.adjunto =
                                                        responseUpload.path;

                                                    inspeccionService
                                                        .insertRespuestasPreoperacional(
                                                            element);
                                                  }));
                                                } else {
                                                  Promesas.add(inspeccionService
                                                      .insertRespuestasPreoperacional(
                                                          element));
                                                }
                                              });

                                              await inspeccionProvider
                                                  .eliminarResumenPreoperacional(
                                                      allInspecciones[i].Id!);

                                              await inspeccionProvider
                                                  .eliminarRespuestaPreoperacional(
                                                      allInspecciones[i].Id!);

                                              // Ejecutamos todas las peticiones
                                              await Future.wait(Promesas)
                                                  .then((value) {
                                                // print(value);
                                              });

                                              // show a notification at top of screen.
                                              showSimpleNotification(
                                                  Text(
                                                      responseResumen.message!),
                                                  leading: Icon(Icons.check),
                                                  autoDismiss: true,
                                                  background: Colors.green,
                                                  position: NotificationPosition
                                                      .bottom);
                                              inspeccionService.isSaving =
                                                  false;
                                            } catch (error) {
                                              showSimpleNotification(
                                                  Text('Error: ${error}'),
                                                  leading: Icon(Icons.check),
                                                  autoDismiss: true,
                                                  background: Colors.orange,
                                                  position: NotificationPosition
                                                      .bottom);
                                            }
                                          },
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            ],
                          ),
                  );
                }),
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
