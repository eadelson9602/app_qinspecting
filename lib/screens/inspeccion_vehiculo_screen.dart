import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/widgets/widgets.dart';

class InspeccionVehiculoScreen extends StatelessWidget {
  const InspeccionVehiculoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inspeccionProvider = Provider.of<InspeccionProvider>(context);
    final inspeccionService = Provider.of<InspeccionService>(context);
    final loginService = Provider.of<LoginService>(context);
    final uiProvider = Provider.of<UiProvider>(context);

    return Scaffold(
      appBar: AppBar(),
      body: ItemsInspeccionarVehiculo(),
      floatingActionButton: FloatingActionButton(
        child: inspeccionProvider.tieneRemolque
            ? Icon(Icons.arrow_forward_ios_sharp)
            : Icon(Icons.save),
        onPressed: () async {
          // Si tiene remolque
          if (inspeccionProvider.tieneRemolque) {
            Navigator.pushReplacementNamed(context, 'inspeccion_remolque');
            return;
          }

          // Si no tiene remolque
          final idEncabezado = await inspeccionProvider
              .saveInspecicon(inspeccionService.resumePreoperacional);

          inspeccionProvider.itemsInspeccion.forEach((categoria) {
            categoria.items.forEach((item) {
              if (item.respuesta != null) {
                item.fkPreoperacional = idEncabezado;
                item.base = loginService.selectedEmpresa!.nombreBase;
                inspeccionProvider.saveRespuestaInspeccion(item);
              }
            });
          });

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
