import 'package:flutter/material.dart';
import 'package:app_qinspecting/ui/app_theme.dart';

class CustomLoadingTruck extends StatefulWidget {
  final double progress;
  final String message;
  final Color? primaryColor;
  final Color? backgroundColor;
  final double opacity;

  const CustomLoadingTruck({
    Key? key,
    required this.progress,
    this.message = 'Cargando...',
    this.primaryColor,
    this.backgroundColor,
    this.opacity = 0.9,
  }) : super(key: key);

  @override
  State<CustomLoadingTruck> createState() => _CustomLoadingTruckState();
}

class _CustomLoadingTruckState extends State<CustomLoadingTruck>
    with TickerProviderStateMixin {
  late AnimationController _wheelsController;
  late Animation<double> _wheelsAnimation;

  @override
  void initState() {
    super.initState();

    // Solo controlador para las ruedas giratorias
    _wheelsController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Animación de las ruedas girando
    _wheelsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _wheelsController,
      curve: Curves.linear,
    ));
    // Iniciar animaciones
    _wheelsController.repeat();
  }

  @override
  void dispose() {
    _wheelsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.primaryColor ?? AppTheme.primaryGreen;
    final backgroundColor =
        widget.backgroundColor ?? Theme.of(context).cardColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Opacity(
      opacity: widget.opacity,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Contenedor del camión y la carretera
            SizedBox(
              height: 120,
              width: 300,
              child: Stack(
                children: [
                  // Camión sincronizado con el progreso
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: widget.progress.clamp(0.0, 1.0) *
                        250, // Posición basada en progreso
                    top: 50,
                    child: _buildTruck(primaryColor, isDark),
                  ),

                  // Barra de progreso
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[700] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: widget.progress.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primaryColor,
                                primaryColor.withValues(alpha: 0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Mensaje
            Text(
              widget.message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Porcentaje de progreso
            Text(
              '${(widget.progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTruck(Color primaryColor, bool isDark) {
    return AnimatedBuilder(
      animation: _wheelsAnimation,
      builder: (context, child) {
        return Container(
          width: 100,
          height: 70,
          child: Stack(
            children: [
              // Camión usando el GIF
              Positioned(
                left: 0,
                top: 0,
                child: Image.asset(
                  'assets/images/truck.gif',
                  width: 100,
                  height: 70,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback en caso de error con el GIF
                    return Container(
                      width: 60,
                      height: 35,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isDark ? Colors.grey[600]! : Colors.grey[400]!,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.local_shipping,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
