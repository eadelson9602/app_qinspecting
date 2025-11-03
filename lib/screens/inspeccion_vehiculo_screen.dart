import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/screens/screens.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/widgets/widgets.dart';

class InspeccionVehiculoScreen extends StatelessWidget {
  const InspeccionVehiculoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inspeccionProvider =
        Provider.of<InspeccionProvider>(context, listen: false);
    final inspeccionService =
        Provider.of<InspeccionService>(context, listen: false);
    final loginService = Provider.of<LoginService>(context, listen: false);
    final uiProvider = Provider.of<UiProvider>(context, listen: false);

    // Debug: Verificar el valor de tieneRemolque al construir el widget
    print(
        '🔍 DEBUG InspeccionVehiculoScreen - tieneRemolque: ${inspeccionProvider.tieneRemolque}');

    // Usar Consumer para escuchar cambios en isSaving
    return Consumer<InspeccionProvider>(
      builder: (context, inspeccionProviderConsumer, _) {
        // Si está guardando, mostrar LoadingScreen
        if (inspeccionProviderConsumer.isSaving) {
          return LoadingScreen();
        }

        // Si no está guardando, mostrar el contenido con Selector para tieneRemolque
        return Selector<InspeccionProvider, bool>(
          selector: (_, provider) {
            print(
                '🔍 DEBUG Selector - tieneRemolque: ${provider.tieneRemolque}');
            return provider.tieneRemolque;
          },
          builder: (context, tieneRemolque, child) {
            print('🔍 DEBUG Builder - tieneRemolque: $tieneRemolque');

            return Scaffold(
              appBar: AppBar(),
              body: ItemsInspeccionarVehiculo(),
              floatingActionButton: CustomStyleButton(
                text: tieneRemolque ? 'Siguiente' : 'Guardar',
                icon:
                    tieneRemolque ? Icons.arrow_forward_ios_sharp : Icons.save,
                backgroundColor: Colors.green,
                fontSize: 14,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                onPressed: () async {
                  // Obtener el valor actual de tieneRemolque del provider
                  final tieneRemolqueActual =
                      Provider.of<InspeccionProvider>(context, listen: false)
                          .tieneRemolque;

                  // Si tiene remolque
                  if (tieneRemolqueActual) {
                    Navigator.pushNamed(context, 'inspeccion_remolque');
                    return;
                  }
                  inspeccionProvider.updateSaving(true);

                  // Si no tiene remolque
                  List<dynamic> tempRespuestas = [];
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
                        futureRespuestas.add(
                            inspeccionProvider.saveRespuestaInspeccion(item));
                      }
                    });
                  });

                  await Future.wait(futureRespuestas);
                  inspeccionProvider.updateSaving(false);

                  // Limpiar todos los datos de la inspección completada
                  inspeccionService.clearData();
                  inspeccionProvider.clearData();

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
          },
        );
      },
    );
  }
}
