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
    final imageProvider =
        Provider.of<LoginFormProvider>(context, listen: false);

    return Container(
      height: 280,
      decoration: BoxDecoration(
        gradient: Theme.of(context).brightness == Brightness.dark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryGreen,
                  AppTheme.primaryGreen.withValues(alpha: 0.8),
                ],
              )
            : AppTheme.primaryGradient,
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
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.green,
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
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).cardColor
                        : Colors.white,
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor,
                        blurRadius: 20,
                        offset: const Offset(0, 10),
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
                                border: Border.all(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Theme.of(context).dividerColor
                                      : AppTheme.cardColor,
                                  width: 4,
                                ),
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
                  color: AppTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor,
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
}
