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
          // Fondo con imagen de perfil y degradado
          if (userPhoto != null && userPhoto!.isNotEmpty)
            Positioned.fill(
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white, // Opaco arriba
                    Colors.white.withValues(alpha: 0.9), // Casi opaco
                    Colors.white.withValues(alpha: 0.7), // Semi-transparente
                    Colors.white.withValues(alpha: 0.5), // Más transparente
                    Colors.white.withValues(alpha: 0.3), // Muy transparente
                    Colors.white.withValues(alpha: 0.1), // Casi invisible
                    Colors.transparent, // Completamente transparente
                  ],
                  stops: const [0.0, 0.2, 0.4, 0.6, 0.75, 0.9, 1.0],
                ).createShader(bounds),
                blendMode: BlendMode.dstIn,
                child: imageProvider.getImage(userPhoto),
              ),
            ),

          // Overlay verde con degradado más suave
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: Theme.of(context).brightness == Brightness.dark
                      ? [
                          const Color.fromARGB(
                              220, 84, 147, 76), // Verde más opaco arriba
                          const Color.fromARGB(180, 84, 147, 76), // Verde medio
                          const Color.fromARGB(
                              140, 84, 147, 76), // Verde más transparente
                          const Color.fromARGB(
                              100, 84, 147, 76), // Verde muy transparente
                          const Color.fromARGB(
                              40, 84, 147, 76), // Verde muy transparente
                          const Color.fromARGB(
                              20, 84, 147, 76), // Verde casi invisible
                          Colors
                              .transparent, // Completamente transparente al final
                        ]
                      : [
                          const Color.fromARGB(
                              220, 68, 173, 68), // Verde más opaco arriba
                          const Color.fromARGB(180, 68, 173, 68), // Verde medio
                          const Color.fromARGB(
                              140, 68, 173, 68), // Verde más transparente
                          const Color.fromARGB(
                              100, 68, 173, 68), // Verde muy transparente
                          const Color.fromARGB(
                              40, 68, 173, 68), // Verde muy transparente
                          const Color.fromARGB(
                              20, 68, 173, 68), // Verde casi invisible
                          Colors
                              .transparent, // Completamente transparente al final
                        ],
                  stops: const [0.0, 0.2, 0.4, 0.6, 0.75, 0.9, 1.0],
                ),
              ),
            ),
          ),

          // Fallback: fondo verde con degradado más suave si no hay imagen
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
                            const Color.fromARGB(
                                220, 84, 147, 76), // Verde más transparente
                            const Color.fromARGB(
                                180, 84, 147, 76), // Verde medio
                            const Color.fromARGB(
                                140, 84, 147, 76), // Verde más transparente
                            const Color.fromARGB(
                                100, 84, 147, 76), // Verde muy transparente
                            const Color.fromARGB(
                                40, 84, 147, 76), // Verde muy transparente
                            const Color.fromARGB(
                                20, 84, 147, 76), // Verde casi invisible
                          ]
                        : [
                            const Color.fromARGB(
                                255, 68, 173, 68), // Verde sólido arriba
                            const Color.fromARGB(
                                220, 68, 173, 68), // Verde más transparente
                            const Color.fromARGB(
                                180, 68, 173, 68), // Verde medio
                            const Color.fromARGB(
                                140, 68, 173, 68), // Verde más transparente
                            const Color.fromARGB(
                                100, 68, 173, 68), // Verde muy transparente
                            const Color.fromARGB(
                                40, 68, 173, 68), // Verde muy transparente
                            const Color.fromARGB(
                                20, 68, 173, 68), // Verde casi invisible
                          ],
                    stops: const [0.0, 0.2, 0.4, 0.6, 0.75, 0.9, 1.0],
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
