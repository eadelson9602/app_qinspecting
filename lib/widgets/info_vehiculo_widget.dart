import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/providers/providers.dart';

class InfoVehiculoWidget extends StatelessWidget {
  const InfoVehiculoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inspeccionProvider = Provider.of<InspeccionProvider>(context);

    return inspeccionProvider.vehiculoSelected == null
        ? Container()
        : Column(
            children: [
              ListTile(
                dense: true,
                shape: Border(bottom: BorderSide(color: Colors.green)),
                title:
                    Text('Marca del cabezote', style: TextStyle(fontSize: 15)),
                subtitle: Text(inspeccionProvider.vehiculoSelected!.nombreMarca,
                    style: TextStyle(fontSize: 15)),
              ),
              ListTile(
                dense: true,
                shape: Border(bottom: BorderSide(color: Colors.green)),
                title:
                    Text('Modelo del cabezote', style: TextStyle(fontSize: 15)),
                subtitle: Text(
                    inspeccionProvider.vehiculoSelected!.modelo.toString(),
                    style: TextStyle(fontSize: 15)),
              ),
              ListTile(
                dense: true,
                shape: Border(bottom: BorderSide(color: Colors.green)),
                title:
                    Text('Licencia tránsito', style: TextStyle(fontSize: 15)),
                subtitle: Text(
                    inspeccionProvider.vehiculoSelected!.licenciaTransito
                        .toString(),
                    style: TextStyle(fontSize: 15)),
              ),
              ListTile(
                dense: true,
                shape: Border(bottom: BorderSide(color: Colors.green)),
                title: Text('Color de cabezote'),
                subtitle: Text(
                    inspeccionProvider.vehiculoSelected!.color.toString(),
                    style: TextStyle(fontSize: 15)),
              ),
            ],
          );
  }
}
