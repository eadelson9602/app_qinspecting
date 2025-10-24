import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/services/services.dart';

class ModernHeader extends StatelessWidget {
  const ModernHeader({
    Key? key,
    required this.userName,
    required this.lastName,
    this.userPhoto,
    this.onPhotoTap,
  }) : super(key: key);

  final String userName;
  final String lastName;
  final String? userPhoto;
  final VoidCallback? onPhotoTap;

  @override
  Widget build(BuildContext context) {
    final imageProvider =
        Provider.of<LoginFormProvider>(context, listen: false);

    return Container(
      height: 280,
      child: Stack(
        children: [
          // Fondo con imagen de perfil
          if (userPhoto != null && userPhoto!.isNotEmpty)
            Positioned.fill(
              child: ClipRRect(
                child: imageProvider.getImage(userPhoto),
              ),
            ),

          // Overlay verde con transparencia
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color.fromARGB(180, 84, 147,
                        76) // Verde con transparencia para modo oscuro
                    : const Color.fromARGB(180, 68, 173,
                        68), // Verde con transparencia para modo claro
              ),
            ),
          ),

          // Fallback: fondo verde sólido si no hay imagen
          if (userPhoto == null || userPhoto!.isEmpty)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color.fromARGB(
                          255, 84, 147, 76) // Verde sólido para modo oscuro
                      : const Color.fromARGB(
                          255, 68, 173, 68), // Verde sólido para modo claro
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
              ),
            ),
          // Botón de volver
          Positioned(
            left: 20,
            top: 40,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back,
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
                'Perfil',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),

          // Avatar circular - removido para evitar duplicación
          // El avatar ahora se maneja desde profile_screen.dart con z-index

          // Nombre del usuario
          Positioned(
            bottom: 80, // Más arriba para estar en el header
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

          // Apellido del usuario
          Positioned(
            bottom: 50, // Más arriba para estar en el header
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                lastName,
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
