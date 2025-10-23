import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/ui/app_theme.dart';

class ModernHeader extends StatelessWidget {
  const ModernHeader({
    Key? key,
    required this.userName,
    this.userPhoto,
    this.onPhotoTap,
  }) : super(key: key);

  final String userName;
  final String? userPhoto;
  final VoidCallback? onPhotoTap;

  @override
  Widget build(BuildContext context) {
    print('[MODERN HEADER] userPhoto: $userPhoto');
    return Container(
      height: 280,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        children: [
          // Botón de volver
          Positioned(
            left: 20,
            top: 40,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.green,
                  size: 30,
                ),
              ),
            ),
          ),

          // Avatar circular
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: onPhotoTap,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: FutureBuilder(
                      future:
                          Provider.of<InspeccionService>(context, listen: false)
                              .checkConnection(),
                      builder: (context, snapshot) {
                        print('[MODERN HEADER] Mostrando imagen: $userPhoto');
                        if (snapshot.data == true) {
                          print('SNAPSHOT DATA: ${userPhoto}');
                          return _buildImageWidget(context);
                        }
                        return Container(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                          child: const Image(
                            image: AssetImage('assets/images/loading-2.gif'),
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Botón de cámara
          Positioned(
            bottom: 70,
            right: MediaQuery.of(context).size.width / 2 - 15,
            child: GestureDetector(
              onTap: onPhotoTap,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),

          // Nombre del usuario
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(BuildContext context) {
    print('[MODERN HEADER] _buildImageWidget userPhoto: $userPhoto');
    if (userPhoto != null && userPhoto!.isNotEmpty) {
      print('[MODERN HEADER] userPhoto is not empty');
      // Verificar si es una ruta local (imagen temporal)
      if (userPhoto!.startsWith('/')) {
        print('[MODERN HEADER] userPhoto starts with /');
        return Image.file(
          File(userPhoto!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('[MODERN HEADER] error: $error');
            return const Image(
              image: AssetImage('assets/images/no-image.png'),
              fit: BoxFit.cover,
            );
          },
        );
      } else {
        // Es una URL del servidor
        print(
            '[MODERN HEADER] Usando LoginFormProvider.getImage() para URL: $userPhoto');

        // Verificar si la URL es válida
        if (userPhoto!.startsWith('http://') ||
            userPhoto!.startsWith('https://')) {
          print('[MODERN HEADER] URL válida detectada');
          final imageWidget =
              Provider.of<LoginFormProvider>(context, listen: false)
                  .getImage(userPhoto!);
          print(
              '[MODERN HEADER] Widget de imagen creado: ${imageWidget.runtimeType}');
          return imageWidget;
        } else {
          print('[MODERN HEADER] URL inválida, mostrando imagen por defecto');
          return const Image(
            image: AssetImage('assets/images/no-image.png'),
            fit: BoxFit.cover,
          );
        }
      }
    } else {
      print('[MODERN HEADER] userPhoto is empty');
      return const Image(
        image: AssetImage('assets/images/no-image.png'),
        fit: BoxFit.cover,
      );
    }
  }
}
