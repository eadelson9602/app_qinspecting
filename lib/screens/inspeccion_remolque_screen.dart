import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/screens/screens.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/widgets/widgets.dart';

class InspeccionRemolqueScreen extends StatelessWidget {
  const InspeccionRemolqueScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inspeccionProvider = Provider.of<InspeccionProvider>(context);
    final inspeccionService = Provider.of<InspeccionService>(context);
    final loginService = Provider.of<LoginService>(context);
    final uiProvider = Provider.of<UiProvider>(context);

    if (inspeccionProvider.isSaving) return LoadingScreen();
    return Scaffold(
      appBar: AppBar(),
      body: ItemsInspeccionarRemolque(),
      floatingActionButton: CustomStyleButton(
        text: 'Finalizar',
        icon: Icons.check_circle,
        backgroundColor: Colors.green,
        fontSize: 14,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        onPressed: () async {
          inspeccionProvider.updateSaving(true);
          List<dynamic> tempRespuestas = [];

          inspeccionProvider.itemsInspeccionRemolque.forEach((element) {
            inspeccionProvider.itemsInspeccion.add(element);
          });

          inspeccionProvider.itemsInspeccion.forEach((element) {
            // Asegurar que cada item tenga el parámetro base
            element.items.forEach((item) {
              if (item.respuesta != null) {
                item.base = loginService.selectedEmpresa.nombreBase;
              }
            });
            tempRespuestas.add(element.toJson());
          });
          inspeccionService.resumePreoperacional.respuestas =
              tempRespuestas.toString();
          final idEncabezado = await inspeccionProvider
              .saveInspecicon(inspeccionService.resumePreoperacional);

          List<Future> futureRespuestas = [];
          inspeccionProvider.itemsInspeccion.forEach((categoria) {
            categoria.items.forEach((item) {
              if (item.respuesta != null) {
                item.fkPreoperacional = idEncabezado;
                item.base = loginService.selectedEmpresa.nombreBase;
                futureRespuestas
                    .add(inspeccionProvider.saveRespuestaInspeccion(item));
              }
            });
          });
          await Future.wait(futureRespuestas);
          inspeccionProvider.updateSaving(false);
          uiProvider.selectedMenuOpt = 0;
          // show a notification at top of screen.
          showSimpleNotification(Text('Inspección realizada'),
              leading: Icon(Icons.check),
              autoDismiss: true,
              background: Colors.green,
              position: NotificationPosition.bottom);

          Navigator.pushReplacementNamed(context, 'home');
        },
      ),
    );
  }
}
