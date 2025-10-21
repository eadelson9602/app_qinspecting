import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/ui/input_decorations.dart';
import 'package:app_qinspecting/widgets/board_image.dart';

class GuiaTransporteWidget extends StatelessWidget {
  const GuiaTransporteWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inspeccionProvider = Provider.of<InspeccionProvider>(context);
    final inspeccionService = InspeccionService();

    return inspeccionProvider.tieneGuia
        ? Column(
            children: [
              TextFormField(
                autocorrect: false,
                keyboardType: TextInputType.text,
                onChanged: (value) {
                  inspeccionService.resumePreoperacional.numeroGuia = value;
                },
                validator: (value) {
                  if (value!.isEmpty) return 'Ingrese la guía de transporte';
                  return null;
                },
                decoration: InputDecorations.authInputDecorations(
                    hintText: '',
                    labelText: 'Guía transporte',
                    prefixIcon: Icons.speed),
              ),
              const SizedBox(
                height: 16,
              ),
              Text('Foto guía de transporte'),
              Stack(
                children: [
                  BoardImage(
                    url: inspeccionProvider.pathFileGuia,
                  ),
                  Positioned(
                      right: 15,
                      bottom: 10,
                      child: IconButton(
                        onPressed: () async {
                          final photoPath = await CameraService.capturePhoto(
                            context: context,
                            logPrefix: '[pick] guía',
                          );

                          if (photoPath != null) {
                            inspeccionService.resumePreoperacional.urlFotoGuia =
                                photoPath;
                            inspeccionProvider.updateImageGuia(photoPath);
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
            ],
          )
        : Container();
  }
}
