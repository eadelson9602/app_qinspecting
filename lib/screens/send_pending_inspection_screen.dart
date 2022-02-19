import 'package:flutter/material.dart';
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
          itemBuilder: (_, int i) => Dismissible(
              key: UniqueKey(),
              background: Container(
                color: Colors.red,
              ),
              onDismissed: (DismissDirection direction) => print('Borrar'),
              child: ListTile(
                leading: Icon(
                  Icons.find_in_page,
                  color: Colors.green,
                ),
                title: Text('Inspección ${allInspecciones[i].Id}'),
                subtitle:
                    Text('Realizado el ${allInspecciones[i].resuPreFecha}'),
                trailing:
                    const Icon(Icons.keyboard_arrow_right, color: Colors.grey),
                onTap: () {
                  inspeccionService.insertPreoperacional(allInspecciones[i]);
                },
              )),
        ),
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
