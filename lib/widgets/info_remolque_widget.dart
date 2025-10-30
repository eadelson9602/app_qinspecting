import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// flujo embebido: no usamos image_picker ni permission_handler aquí

import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/ui/input_decorations.dart';
import 'package:app_qinspecting/widgets/board_image.dart';
import 'package:app_qinspecting/widgets/widgets.dart';

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
      DropdownButtonFormField<String>(
          decoration: InputDecorations.authInputDecorations(
              prefixIcon: Icons.local_shipping,
              hintText: '',
              labelText: 'Placa del remolque'),
          validator: (value) {
            if (value == null) return 'Seleccione una placa';
            return null;
          },
          items: inspeccionProvider.remolques.map((e) {
            return DropdownMenuItem(
              child: Text(e.placa),
              value: e.placa,
            );
          }).toList(),
          onChanged: (value) async {
            if (value == null) {
              // Si se deselecciona, limpiar toda la información del remolque
              inspeccionService.resumePreoperacional.placaRemolque = null;
              inspeccionProvider.updateRemolqueSelected(null);
            } else {
              final resultRemolque =
                  await DBProvider.db.getRemolqueByPlate(value);
              inspeccionService.resumePreoperacional.placaRemolque = value;
              inspeccionProvider.updateRemolqueSelected(resultRemolque!);

              await inspeccionProvider.listarCategoriaItemsRemolque(value);
            }
          }),
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
