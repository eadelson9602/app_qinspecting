import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                          try {
                            // Verificar permisos antes de abrir la cámara
                            final hasPermission = await inspeccionProvider
                                .requestCameraPermission();
                            if (!hasPermission) {
                              print('[pick] Permisos de cámara denegados');
                              return;
                            }

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

                            // Verificar que el archivo existe y es válido
                            final file = File(photo.path);
                            if (!await file.exists()) {
                              print('[pick] ERROR: Archivo no existe');
                              return;
                            }

                            final fileSize = await file.length();
                            print(
                                '[pick] guía path=${photo.path} size=$fileSize bytes');

                            // Validar tamaño del archivo (máximo 10MB)
                            if (fileSize > 10 * 1024 * 1024) {
                              print(
                                  '[pick] ERROR: Archivo demasiado grande ($fileSize bytes)');
                              return;
                            }

                            inspeccionService.resumePreoperacional.urlFotoGuia =
                                photo.path;
                            inspeccionProvider.updateImageGuia(photo.path);
                            print('[pick] ✅ Foto guía guardada exitosamente');
                          } catch (e) {
                            print('[pick] ❌ ERROR capturando foto guía: $e');
                            // Mostrar mensaje de error al usuario
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Error al capturar foto: ${e.toString()}'),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 3),
                              ),
                            );
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
