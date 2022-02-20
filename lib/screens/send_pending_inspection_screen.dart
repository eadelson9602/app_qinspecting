import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/screens/loading_screen.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/widgets/widgets.dart';

class SendPendingInspectionScree extends StatelessWidget {
  const SendPendingInspectionScree({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inspeccionProvider = Provider.of<InspeccionProvider>(context);
    final inspeccionService = Provider.of<InspeccionService>(context);
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
                return CircularProgressIndicator(
                  color: Colors.green,
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
                                  final response = await inspeccionService
                                      .insertPreoperacional(allInspecciones[i]);

                                  // show a notification at top of screen.
                                  showSimpleNotification(
                                      Text(response.message!),
                                      leading: Icon(Icons.check),
                                      autoDismiss: true,
                                      background: Colors.green,
                                      position: NotificationPosition.bottom);
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
