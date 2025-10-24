import 'package:flutter/material.dart';
import 'package:app_qinspecting/ui/app_theme.dart';

class CustomLoadingTruck extends StatefulWidget {
  final double progress;
  final String message;
  final Color? primaryColor;
  final Color? backgroundColor;

  const CustomLoadingTruck({
    Key? key,
    required this.progress,
    this.message = 'Cargando...',
    this.primaryColor,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<CustomLoadingTruck> createState() => _CustomLoadingTruckState();
}

class _CustomLoadingTruckState extends State<CustomLoadingTruck>
    with TickerProviderStateMixin {
  late AnimationController _truckController;
  late AnimationController _wheelsController;
  late Animation<double> _truckAnimation;
  late Animation<double> _wheelsAnimation;

  @override
  void initState() {
    super.initState();
    
    // Controlador para el movimiento del camión
    _truckController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Controlador para las ruedas giratorias
    _wheelsController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Animación del camión moviéndose de izquierda a derecha
    _truckAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _truckController,
      curve: Curves.easeInOut,
    ));

    // Animación de las ruedas girando
    _wheelsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _wheelsController,
      curve: Curves.linear,
    ));

    // Iniciar animaciones
    _truckController.repeat();
    _wheelsController.repeat();
  }

  @override
  void dispose() {
    _truckController.dispose();
    _wheelsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.primaryColor ?? AppTheme.primaryGreen;
    final backgroundColor = widget.backgroundColor ?? Theme.of(context).cardColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
                // Carretera
                Container(
                  height: 8,
                  width: 300,
                  margin: const EdgeInsets.only(top: 80),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                
                // Líneas de la carretera
                Positioned(
                  top: 84,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) {
                      return Container(
                        width: 20,
                        height: 2,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                          borderRadius: BorderRadius.circular(1),
                        ),
                      );
                    }),
                  ),
                ),

                // Camión animado
                AnimatedBuilder(
                  animation: _truckAnimation,
                  builder: (context, child) {
                    final truckPosition = _truckAnimation.value * 250; // Rango de movimiento
                    return Positioned(
                      left: truckPosition,
                      top: 50,
                      child: _buildTruck(primaryColor, isDark),
                    );
                  },
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
    );
  }

  Widget _buildTruck(Color primaryColor, bool isDark) {
    return AnimatedBuilder(
      animation: _wheelsAnimation,
      builder: (context, child) {
        return Container(
          width: 50,
          height: 30,
          child: Stack(
            children: [
              // Cuerpo del camión
              Container(
                width: 40,
                height: 20,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isDark ? Colors.grey[600]! : Colors.grey[400]!,
                    width: 1,
                  ),
                ),
                child: Stack(
                  children: [
                    // Ventana del conductor
                    Positioned(
                      left: 2,
                      top: 2,
                      child: Container(
                        width: 8,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.blue[100],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    // Luces delanteras
                    Positioned(
                      right: 1,
                      top: 3,
                      child: Container(
                        width: 3,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.yellow[300],
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 1,
                      bottom: 3,
                      child: Container(
                        width: 3,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.yellow[300],
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Ruedas
              Positioned(
                left: 5,
                bottom: 0,
                child: Transform.rotate(
                  angle: _wheelsAnimation.value * 2 * 3.14159,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey[600]!,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              Positioned(
                right: 5,
                bottom: 0,
                child: Transform.rotate(
                  angle: _wheelsAnimation.value * 2 * 3.14159,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey[600]!,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
