import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/services/services.dart';

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
    final imageProvider =
        Provider.of<LoginFormProvider>(context, listen: false);

    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF6A4C93) // Púrpura más oscuro para modo oscuro
            : const Color(0xFF8E44AD), // Púrpura sólido para modo claro
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
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),

          // Título PERFIL
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'PERFIL',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),

          // Botón de configuración
          Positioned(
            right: 20,
            top: 40,
            child: IconButton(
              onPressed: () {
                // Navegar a configuración
                Navigator.pushNamed(context, 'settings');
              },
              icon: const Icon(
                Icons.settings,
                color: Colors.white,
                size: 28,
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
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: FutureBuilder(
                    future:
                        Provider.of<InspeccionService>(context, listen: false)
                            .checkConnection(),
                    builder: (context, snapshot) {
                      if (snapshot.data == true) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(56),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(56),
                            ),
                            child: imageProvider.getImage(userPhoto),
                          ),
                        );
                      }
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(40),
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
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.black54,
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
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
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
}
