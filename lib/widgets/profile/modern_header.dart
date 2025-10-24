import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_qinspecting/providers/providers.dart';

class ModernHeader extends StatelessWidget {
  const ModernHeader({
    Key? key,
    this.userPhoto,
    this.onPhotoTap,
  }) : super(key: key);

  final String? userPhoto;
  final VoidCallback? onPhotoTap;

  @override
  Widget build(BuildContext context) {
    final imageProvider =
        Provider.of<LoginFormProvider>(context, listen: false);

    return Container(
      height: 200,
      // decoration: BoxDecoration(
      //   border: Border(
      //     bottom: BorderSide(
      //       color: Colors.white,
      //       width: 4,
      //     ),
      //   ),
      // ),
      child: Stack(
        children: [
          // Fondo con imagen de perfil
          if (userPhoto != null && userPhoto!.isNotEmpty)
            Positioned.fill(
              child: imageProvider.getImage(userPhoto),
            ),

          // Overlay verde con degradado
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: Theme.of(context).brightness == Brightness.dark
                      ? [
                          const Color.fromARGB(
                              200, 84, 147, 76), // Verde más opaco arriba
                          const Color.fromARGB(
                              120, 84, 147, 76), // Verde más transparente abajo
                          Colors
                              .transparent, // Completamente transparente al final
                        ]
                      : [
                          const Color.fromARGB(
                              200, 68, 173, 68), // Verde más opaco arriba
                          const Color.fromARGB(
                              120, 68, 173, 68), // Verde más transparente abajo
                          Colors
                              .transparent, // Completamente transparente al final
                        ],
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // Fallback: fondo verde con degradado si no hay imagen
          if (userPhoto == null || userPhoto!.isEmpty)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: Theme.of(context).brightness == Brightness.dark
                        ? [
                            const Color.fromARGB(
                                255, 84, 147, 76), // Verde sólido arriba
                            const Color.fromARGB(200, 84, 147,
                                76), // Verde más transparente abajo
                            const Color.fromARGB(100, 84, 147,
                                76), // Verde muy transparente al final
                          ]
                        : [
                            const Color.fromARGB(
                                255, 68, 173, 68), // Verde sólido arriba
                            const Color.fromARGB(200, 68, 173,
                                68), // Verde más transparente abajo
                            const Color.fromARGB(100, 68, 173,
                                68), // Verde muy transparente al final
                          ],
                    stops: const [0.0, 0.7, 1.0],
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
        ],
      ),
    );
  }
}
