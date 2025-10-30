import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// flujo embebido: no requiere image_picker directo ni permission_handler aquí

import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/ui/input_decorations.dart';
import 'package:app_qinspecting/widgets/board_image.dart';

class GuiaTransporteWidget extends StatefulWidget {
  const GuiaTransporteWidget({Key? key}) : super(key: key);

  @override
  State<GuiaTransporteWidget> createState() => _GuiaTransporteWidgetState();
}

class _GuiaTransporteWidgetState extends State<GuiaTransporteWidget> {
  @override
  Widget build(BuildContext context) {
    final inspeccionProvider = Provider.of<InspeccionProvider>(context);
    final inspeccionService =
        Provider.of<InspeccionService>(context, listen: false);

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
              BoardImage(
                url: inspeccionProvider.pathFileGuia,
                onImageCaptured: (path) {
                  final inspeccionService =
                      Provider.of<InspeccionService>(context, listen: false);
                  final inspeccionProvider =
                      Provider.of<InspeccionProvider>(context, listen: false);
                  inspeccionService.resumePreoperacional.urlFotoGuia = path;
                  inspeccionProvider.updateImageGuia(path);
                },
              ),
            ],
          )
        : Container();
  }
}
