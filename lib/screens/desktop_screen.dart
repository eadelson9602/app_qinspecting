import 'package:app_qinspecting/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/providers/inspeccion_provider.dart';
import 'package:app_qinspecting/services/services.dart';

class DesktopScreen extends StatelessWidget {
  const DesktopScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inspeccionProvider = Provider.of<InspeccionProvider>(context);
    final inspeccionService = Provider.of<InspeccionService>(context);

    final allInspecciones = inspeccionProvider.allInspecciones;
    inspeccionProvider.cargarTodosInspecciones();

    return Container(
      height: double.infinity,
      padding: EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 50),
      child: ListView.builder(
          itemCount: allInspecciones.length,
          itemBuilder: (_, int i) {
            if (inspeccionService.isSaving)
              return Container(
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
              );
            return CardInspeccionDesktop(
                resumenPreoperacional: allInspecciones[i]);
          }),
    );
  }
}
