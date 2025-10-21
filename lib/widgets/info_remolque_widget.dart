import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/ui/input_decorations.dart';
import 'package:app_qinspecting/widgets/board_image.dart';

class InfoRemolqueWidget extends StatelessWidget {
  const InfoRemolqueWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inspeccionProvider = Provider.of<InspeccionProvider>(context);
    final inspeccionService = InspeccionService();

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
            final resultRemolque =
                await DBProvider.db.getRemolqueByPlate(value!);
            inspeccionService.resumePreoperacional.placaRemolque = value;
            inspeccionProvider.updateRemolqueSelected(resultRemolque!);

            await inspeccionProvider.listarCategoriaItemsRemolque(value);
          }),
      const SizedBox(
        height: 16,
      ),
      Text('Foto Remolque'),
      Stack(
        children: [
          BoardImage(url: inspeccionProvider.pathFileRemolque),
          Positioned(
              right: 15,
              bottom: 10,
              child: IconButton(
                onPressed: () async {
                  final photoPath = await CameraService.capturePhoto(
                    context: context,
                    logPrefix: '[pick] remolque',
                  );

                  if (photoPath != null) {
                    inspeccionService.resumePreoperacional.urlFotoRemolque =
                        photoPath;
                    inspeccionProvider.updateRemolqueImage(photoPath);
                  }
                },
                icon: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 45,
                ),
              ))
        ],
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
