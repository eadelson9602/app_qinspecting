import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/screens/screens.dart';
import 'package:app_qinspecting/ui/app_theme.dart';
import 'package:app_qinspecting/widgets/widgets.dart';

class ItemsInspeccionarRemolque extends StatefulWidget {
  ItemsInspeccionarRemolque({Key? key}) : super(key: key);

  @override
  State<ItemsInspeccionarRemolque> createState() =>
      _ItemsInspeccionarStateRemolque();
}

class _ItemsInspeccionarStateRemolque extends State<ItemsInspeccionarRemolque> {
  /// Muestra bottom sheet para seleccionar fuente de imagen
  void _showImageSourceBottomSheet(
    BuildContext context,
    dynamic item,
  ) {
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
                        _selectImageFromSource(
                          ImageSource.camera,
                          item,
                        );
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
                        _selectImageFromSource(
                          ImageSource.gallery,
                          item,
                        );
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
  Future<void> _selectImageFromSource(
    ImageSource source,
    dynamic item,
  ) async {
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
        setState(() {
          item.adjunto = photo.path;
        });

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
    final itemsInspeccionar = inspeccionProvider.itemsInspeccionRemolque;
    List<Step> _renderSteps() {
      List<Step> stepsInspeccion = [];
      for (int i = 0; i < itemsInspeccionar.length; i++) {
        stepsInspeccion.add(Step(
            isActive:
                inspeccionProvider.stepStepperRemolque >= i ? true : false,
            title: Text(itemsInspeccionar[i].categoria),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MaterialButton(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)),
                    child: TextButtonPersonalized(
                      textButton: 'Todo ok',
                      iconButton: Icons.check,
                    ),
                    onPressed: () {
                      setState(() {
                        // Revalidar límites por si la lista cambió
                        final currentList =
                            inspeccionProvider.itemsInspeccionRemolque;
                        if (i < 0 || i >= currentList.length) return;
                        for (var item in currentList[i].items) {
                          item.respuesta = 'B';
                        }
                        if (inspeccionProvider.stepStepperRemolque <
                                currentList.length &&
                            currentList.length -
                                    inspeccionProvider.stepStepperRemolque !=
                                1) {
                          inspeccionProvider.updateStepRemolque(
                              inspeccionProvider.stepStepperRemolque += 1);
                        }
                      });
                    }),
                SizedBox(height: 20),
                for (var item in itemsInspeccionar[i].items)
                  Column(
                    children: [
                      Container(
                          width: double.infinity,
                          child: Text(
                            item.item,
                            textAlign: TextAlign.start,
                            maxLines: 2,
                          )),
                      Row(
                        children: [
                          Radio(
                            activeColor: Colors.green,
                            groupValue: item.respuesta,
                            value: 'B',
                            onChanged: (value) {
                              setState(() {
                                item.respuesta = value.toString();
                              });
                            },
                          ),
                          Text(
                            'Cumple',
                            style: TextStyle(color: Colors.green),
                          ),
                          Radio(
                            activeColor: Colors.red,
                            groupValue: item.respuesta,
                            value: 'M',
                            onChanged: (value) {
                              setState(() {
                                item.respuesta = value.toString();
                              });
                            },
                          ),
                          Text(
                            'No cumple',
                            style: TextStyle(color: Colors.red),
                          ),
                          Radio(
                            activeColor: Colors.orange,
                            groupValue: item.respuesta,
                            value: 'N/A',
                            onChanged: (value) {
                              setState(() {
                                item.respuesta = value.toString();
                              });
                            },
                          ),
                          Text(
                            'N/A',
                            style: TextStyle(color: Colors.orange),
                          ),
                        ],
                      ),
                      SizedBox(height: 11),
                      if (item.respuesta == 'M')
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.only(right: 20, left: 15),
                          child: TextField(
                            maxLines: 8,
                            decoration: InputDecoration(
                                hintText: "Observaciones",
                                filled: true,
                                contentPadding: EdgeInsets.all(10.0),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always),
                            onChanged: (value) {
                              item.observaciones = value;
                            },
                          ),
                        ),
                      SizedBox(height: 11),
                      if (item.respuesta == 'M')
                        Container(
                          width: 270,
                          child: Stack(
                            children: [
                              BoardImage(
                                url: item.adjunto,
                              ),
                              Positioned(
                                  right: 15,
                                  bottom: 10,
                                  child: IconButton(
                                    onPressed: () {
                                      _showImageSourceBottomSheet(
                                          context, item);
                                    },
                                    icon: Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 45,
                                    ),
                                  ))
                            ],
                          ),
                        ),
                      SizedBox(height: 11),
                    ],
                  ),
              ],
            )));
      }
      return stepsInspeccion;
    }

    if (itemsInspeccionar.isEmpty) return const LoadingScreen();
    final safeCurrentStep = itemsInspeccionar.isEmpty
        ? 0
        : inspeccionProvider.stepStepperRemolque
            .clamp(0, itemsInspeccionar.length - 1);
    return Stepper(
      margin: EdgeInsets.only(left: 55, bottom: 40),
      currentStep: safeCurrentStep,
      controlsBuilder: (context, details) {
        return Row(
          children: [
            if (inspeccionProvider.stepStepperRemolque > 0)
              MaterialButton(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100)),
                onPressed: details.onStepCancel,
                child: Container(
                  child: Row(
                    children: [
                      Text(
                        'Regresar',
                        style: TextStyle(color: Colors.red, fontSize: 18),
                      )
                    ],
                  ),
                ),
              ),
            if (inspeccionProvider.stepStepperRemolque !=
                itemsInspeccionar.length - 1)
              MaterialButton(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                  child: TextButtonPersonalized(
                    textButton: 'Continuar',
                  ),
                  onPressed: inspeccionProvider.stepStepperRemolque ==
                          itemsInspeccionar.length
                      ? null
                      : details.onStepContinue),
          ],
        );
      },
      onStepCancel: () {
        if (inspeccionProvider.stepStepperRemolque > 0) {
          inspeccionProvider
              .updateStepRemolque(inspeccionProvider.stepStepperRemolque -= 1);
        }
      },
      onStepContinue: () {
        if (inspeccionProvider.stepStepperRemolque !=
            itemsInspeccionar.length - 1) {
          inspeccionProvider
              .updateStepRemolque(inspeccionProvider.stepStepperRemolque += 1);
        }
      },
      onStepTapped: (int index) {
        final boundedIndex = index.clamp(0, itemsInspeccionar.length - 1);
        inspeccionProvider.updateStepRemolque(boundedIndex);
      },
      steps: _renderSteps(),
    );
  }
}
