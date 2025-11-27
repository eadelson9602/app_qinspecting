import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// flujo embebido: no usamos image_picker ni permission_handler aquí

import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/widgets/widgets.dart';
import 'package:app_qinspecting/models/models.dart';

class InfoRemolqueWidget extends StatefulWidget {
  const InfoRemolqueWidget({Key? key}) : super(key: key);

  @override
  State<InfoRemolqueWidget> createState() => _InfoRemolqueWidgetState();
}

class _InfoRemolqueWidgetState extends State<InfoRemolqueWidget> {
  @override
  Widget build(BuildContext context) {
    final inspeccionProvider = Provider.of<InspeccionProvider>(context);
    final inspeccionService =
        Provider.of<InspeccionService>(context, listen: false);

    return Column(children: [
      const SizedBox(
        height: 16,
      ),
      SearchableDropdownField<Remolque>(
          labelText: 'Placa del remolque',
          prefixIcon: Icons.local_shipping,
          items: inspeccionProvider.remolques,
          getDisplayText: (remolque) => remolque.placa,
          getValueFromText: (text) {
            try {
              return inspeccionProvider.remolques.firstWhere(
                (r) => r.placa == text,
              );
            } catch (e) {
              return null;
            }
          },
          initialValue: inspeccionService.resumePreoperacional.placaRemolque,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Seleccione una placa';
            }
            return null;
          },
          onChanged: (remolque) async {
            if (remolque == null) {
              // Si se deselecciona, limpiar toda la información del remolque
              inspeccionService.resumePreoperacional.placaRemolque = null;
              inspeccionProvider.updateRemolqueSelected(null);
            } else {
              final resultRemolque =
                  await DBProvider.db.getRemolqueByPlate(remolque.placa);
              inspeccionService.resumePreoperacional.placaRemolque =
                  remolque.placa;
              inspeccionProvider.updateRemolqueSelected(resultRemolque!);

              print('resultRemolque: ${resultRemolque.placa}');

              final items = await inspeccionProvider
                  .listarCategoriaItemsRemolque(remolque.placa);

              print('items REMOLQUE: ${items.length}');

              // Verificar si hay items de inspección
              if (items.isEmpty) {
                NoInspectionItemsDialog.show(
                  context,
                  placa: remolque.placa,
                  tipo: 'remolque',
                );
              }
            }
          },
          context: context),
      const SizedBox(
        height: 16,
      ),
      Text('Foto Remolque'),
      BoardImage(
        url: inspeccionProvider.pathFileRemolque,
        onImageCaptured: (path) {
          final inspeccionService =
              Provider.of<InspeccionService>(context, listen: false);
          inspeccionService.resumePreoperacional.urlFotoRemolque = path;
          inspeccionProvider.updateRemolqueImage(path);
        },
      ),
      const SizedBox(
        height: 16,
      ),
      if (inspeccionProvider.remolqueSelected != null)
        Column(
          children: [
            ListTile(
                dense: true,
                shape: Border(bottom: BorderSide(color: Colors.green)),
                title: Text('Color', style: TextStyle(fontSize: 15)),
                subtitle: Text(
                    inspeccionProvider.remolqueSelected!.color.toString(),
                    style: TextStyle(fontSize: 15))),
            ListTile(
                dense: true,
                shape: Border(bottom: BorderSide(color: Colors.green)),
                title:
                    Text('Marca del remolque', style: TextStyle(fontSize: 15)),
                subtitle: Text(
                    inspeccionProvider.remolqueSelected!.nombreMarca.toString(),
                    style: TextStyle(fontSize: 15))),
            ListTile(
                dense: true,
                shape: Border(bottom: BorderSide(color: Colors.green)),
                title:
                    Text('Modelo del remolque', style: TextStyle(fontSize: 15)),
                subtitle: Text(
                    inspeccionProvider.remolqueSelected!.modelo.toString(),
                    style: TextStyle(fontSize: 15))),
            ListTile(
                dense: true,
                shape: Border(bottom: BorderSide(color: Colors.green)),
                title: Text('Matrícula del remolque',
                    style: TextStyle(fontSize: 15)),
                subtitle: Text(
                    inspeccionProvider.remolqueSelected!.numeroMatricula
                        .toString(),
                    style: TextStyle(fontSize: 15))),
            ListTile(
                dense: true,
                shape: Border(bottom: BorderSide(color: Colors.green)),
                title: Text('Número de ejes del remolque',
                    style: TextStyle(fontSize: 15)),
                subtitle: Text(
                    inspeccionProvider.remolqueSelected!.numeroEjes.toString(),
                    style: TextStyle(fontSize: 15)))
          ],
        ),
      const SizedBox(
        height: 10,
      ),
    ]);
  }
}
