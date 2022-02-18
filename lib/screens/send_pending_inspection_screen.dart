import 'package:app_qinspecting/screens/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/widgets/widgets.dart';

class SendPendingInspectionScree extends StatelessWidget {
  const SendPendingInspectionScree({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inspeccionProvider = Provider.of<InspeccionProvider>(context);
    inspeccionProvider.cargarTodosInspecciones();

    if (inspeccionProvider.allInspecciones.length == 0) return LoadingScreen();
    return Scaffold(
      appBar: const CustomAppBar().createAppBar(),
      drawer: const CustomDrawer(),
      body: Container(
        height: double.infinity,
        padding: EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 50),
        child: ListView.builder(
            itemCount: inspeccionProvider.allInspecciones.length,
            itemBuilder: (_, int i) => ListTile(
                  iconColor: Colors.green,
                  shape: Border.all(
                      style: BorderStyle.solid,
                      color: Colors.green,
                      width: 0.2),
                  leading: Icon(
                    Icons.find_in_page,
                  ),
                  title: Text(
                      'Inspección ${inspeccionProvider.allInspecciones[i].Id}'),
                  subtitle: Text(
                      'Realizado el ${inspeccionProvider.allInspecciones[i].resuPreFecha}'),
                  trailing: Icon(
                    Icons.upload,
                  ),
                )),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        mini: true,
        onPressed: () {},
        child: Icon(Icons.upload_rounded),
      ),
    );
  }
}
