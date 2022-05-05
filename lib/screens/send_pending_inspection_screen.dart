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
    inspeccionProvider.cargarTodosInspecciones();
    final allInspecciones = inspeccionProvider.allInspecciones;

    return Scaffold(
      appBar: CustomAppBar(),
      drawer: CustomDrawer(),
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
            child: inspeccionService.isSaving &&
                    inspeccionService.indexSelected == i
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
                            onPressed: inspeccionService.isSaving
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
                              onPressed: inspeccionService.isSaving
                                  ? null
                                  : () {
                                      inspeccionService.indexSelected = i;
                                      inspeccionService
                                          .sendInspeccion(allInspecciones[i]);
                                    }),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ],
                  ),
          );
        });
  }
}
