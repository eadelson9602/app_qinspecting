import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
                          final _picker = ImagePicker();
                          print('[pick] solicitando foto guía...');
                          final XFile? photo = await _picker.pickImage(
                              source: ImageSource.camera,
                              imageQuality: 70,
                              maxWidth: 1080,
                              maxHeight: 1080);

                          if (photo == null) {
                            print('[pick] cancelado foto guía');
                            return;
                          }

                          try {
                            print(
                                '[pick] guía path=${photo.path} size=${await File(photo.path).length()} bytes');
                          } catch (_) {}
                          inspeccionService.resumePreoperacional.urlFotoGuia =
                              photo.path;
                          inspeccionProvider.updateImageGuia(photo.path);
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
