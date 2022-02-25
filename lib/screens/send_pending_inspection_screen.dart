import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/screens/loading_screen.dart';
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

    if (allInspecciones.length == 0) return LoadingScreen();
    return Scaffold(
      appBar: const CustomAppBar().createAppBar(),
      drawer: const CustomDrawer(),
      body: Container(
        height: double.infinity,
        padding: EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 50),
        child: ListView.builder(
            itemCount: allInspecciones.length,
            itemBuilder: (_, int i) {
              if (inspeccionService.isLoading)
                return Container(
                  padding: EdgeInsets.all(20),
                  child: Row(children: [
                    Text(
                      'Enviando al servidor...',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(
                      width: 30,
                    ),
                    CircularProgressIndicator(
                      color: Colors.green,
                    )
                  ]),
                );
              return Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.search,
                        color: Colors.green,
                      ),
                      title: Text('Inspección No. ${allInspecciones[i].Id}'),
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
                              : () {/* ... */},
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          child: const Text('Guardar'),
                          onPressed: inspeccionService.isLoading
                              ? null
                              : () async {
                                  // Map<String, dynamic>? response =
                                  //     await inspeccionService.uploadImage(
                                  //         path:
                                  //             allInspecciones[i].resuPreFotokm!,
                                  //         company: 'qinspecting',
                                  //         folder: 'inspecciones');
                                  // allInspecciones[i].resuPreFotokm =
                                  //     response!['path'];

                                  List<Item> respuestas =
                                      await inspeccionProvider
                                          .cargarTodasRespuestas(
                                              allInspecciones[i].Id!);

                                  List<Future> Promesas = [];
                                  respuestas.forEach((element) {
                                    // loginService.selectedEmpresa!.nombreQi

                                    if (element.adjunto != null) {
                                      Promesas.add(
                                          inspeccionService.uploadImage(
                                              path: element.adjunto!,
                                              company: 'qinspecting',
                                              folder: 'inspecciones'));
                                    }
                                  });

                                  await Future.wait(Promesas).then((value) {
                                    print(value);
                                  });
                                  // final response = await inspeccionService
                                  //     .insertPreoperacional(allInspecciones[i]);

                                  // show a notification at top of screen.
                                  // showSimpleNotification(
                                  //     Text(response.message!),
                                  //     leading: Icon(Icons.check),
                                  //     autoDismiss: true,
                                  //     background: Colors.green,
                                  //     position: NotificationPosition.bottom);
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
