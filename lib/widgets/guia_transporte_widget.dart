import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/ui/app_theme.dart';
import 'package:app_qinspecting/ui/input_decorations.dart';
import 'package:app_qinspecting/widgets/board_image.dart';
import 'package:app_qinspecting/widgets/profile/photo_option_button.dart';

class GuiaTransporteWidget extends StatefulWidget {
  const GuiaTransporteWidget({Key? key}) : super(key: key);

  @override
  State<GuiaTransporteWidget> createState() => _GuiaTransporteWidgetState();
}

class _GuiaTransporteWidgetState extends State<GuiaTransporteWidget> {
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
                'Seleccionar foto',
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
        final inspeccionProvider =
            Provider.of<InspeccionProvider>(context, listen: false);
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
        final inspeccionProvider =
            Provider.of<InspeccionProvider>(context, listen: false);
        final inspeccionService =
            Provider.of<InspeccionService>(context, listen: false);

        // Actualizar el path en el provider
        inspeccionService.resumePreoperacional.urlFotoGuia = photo.path;
        inspeccionProvider.updateImageGuia(photo.path);

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
                      onPressed: () {
                        _showImageSourceBottomSheet(context);
                      },
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 45,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )
        : Container();
  }
}
