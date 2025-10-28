import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/ui/input_decorations.dart';
import 'package:app_qinspecting/ui/app_theme.dart';
import 'package:app_qinspecting/widgets/board_image.dart';
import 'package:app_qinspecting/widgets/widgets.dart';

class InfoRemolqueWidget extends StatefulWidget {
  const InfoRemolqueWidget({Key? key}) : super(key: key);

  @override
  State<InfoRemolqueWidget> createState() => _InfoRemolqueWidgetState();
}

class _InfoRemolqueWidgetState extends State<InfoRemolqueWidget> {
  /// Muestra bottom sheet para seleccionar fuente de imagen
  void _showImageSourceBottomSheet(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (modalContext) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Seleccionar foto remolque',
                style: Theme.of(modalContext).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryGreen,
                    ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: PhotoOptionButton(
                      icon: Icons.camera_alt,
                      label: 'Cámara',
                      onTap: () {
                        Navigator.pop(modalContext);
                        _selectImageFromSource(ImageSource.camera);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: PhotoOptionButton(
                      icon: Icons.photo_library,
                      label: 'Galería',
                      onTap: () {
                        Navigator.pop(modalContext);
                        _selectImageFromSource(ImageSource.gallery);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(modalContext),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                          color: Theme.of(modalContext).dividerColor),
                    ),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  /// Selecciona una imagen desde la fuente especificada
  Future<void> _selectImageFromSource(ImageSource source) async {
    try {
      final inspeccionProvider =
          Provider.of<InspeccionProvider>(context, listen: false);
      final inspeccionService =
          Provider.of<InspeccionService>(context, listen: false);

      // Verificar permisos existentes
      bool hasPermission = false;
      if (source == ImageSource.camera) {
        PermissionStatus cameraStatus = await Permission.camera.status;
        hasPermission = cameraStatus == PermissionStatus.granted;
      } else {
        // Para galería, verificar permisos de fotos/almacenamiento
        try {
          PermissionStatus photosStatus = await Permission.photos.status;
          hasPermission = photosStatus == PermissionStatus.granted;
        } catch (e) {
          // Fallback para versiones anteriores de Android
          PermissionStatus storageStatus = await Permission.storage.status;
          hasPermission = storageStatus == PermissionStatus.granted;
        }
      }

      // Solo solicitar permisos si no están otorgados
      if (!hasPermission) {
        hasPermission = await inspeccionProvider.requestCameraPermission();
        if (!hasPermission) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Se requieren permisos para acceder a la imagen'),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }
      }

      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1080,
        maxHeight: 1080,
      );

      if (photo != null) {
        inspeccionService.resumePreoperacional.urlFotoRemolque = photo.path;
        inspeccionProvider.updateRemolqueImage(photo.path);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Imagen seleccionada correctamente'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      print('Error al seleccionar imagen: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
      Stack(
        children: [
          BoardImage(url: inspeccionProvider.pathFileRemolque),
          Positioned(
              right: 15,
              bottom: 10,
              child: IconButton(
                onPressed: () {
                  _showImageSourceBottomSheet(context);
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
