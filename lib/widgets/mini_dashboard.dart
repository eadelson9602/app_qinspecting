import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_qinspecting/services/login_service.dart';
import 'package:app_qinspecting/providers/db_provider.dart';
import 'package:app_qinspecting/ui/app_theme.dart';

class MiniDashboard extends StatefulWidget {
  const MiniDashboard({Key? key}) : super(key: key);

  @override
  State<MiniDashboard> createState() => _MiniDashboardState();
}

class _MiniDashboardState extends State<MiniDashboard> {
  Map<String, int> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  Future<void> _loadDashboardStats() async {
    try {
      final loginService = Provider.of<LoginService>(context, listen: false);
      final dbProvider = Provider.of<DBProvider>(context, listen: false);

      print('🔍 Debug MiniDashboard:');
      print('  - Usuario ID: ${loginService.userDataLogged.id}');
      print(
          '  - Usuario numeroDocumento: ${loginService.userDataLogged.numeroDocumento}');
      print('  - Empresa base: ${loginService.selectedEmpresa.nombreBase}');

      if (loginService.userDataLogged.id != null &&
          loginService.selectedEmpresa.nombreBase != null) {
        final stats = await dbProvider.getDashboardStats(
            loginService.userDataLogged
                .numeroDocumento!, // Usar numeroDocumento en lugar de id
            loginService.selectedEmpresa.nombreBase!);

        print('📊 MiniDashboard stats recibidas: $stats');

        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      } else {
        print('⚠️ MiniDashboard: Datos de usuario o empresa nulos');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading dashboard stats: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: _isLoading ? _buildLoadingState() : _buildDashboardGrid(),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 190, // Tamaño original restaurado
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
            ),
            SizedBox(height: 12),
            Text(
              'Cargando estadísticas...',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardGrid() {
    return Container(
      height: 250, // Tamaño original restaurado
      child: Column(
        children: [
          // Primera fila
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Pendientes',
                    value: _stats['pendientes'] ?? 0,
                    icon: Icons.schedule,
                    color: Color(0xFF9C27B0), // Purple
                    subtitle: 'Por enviar',
                  ),
                ),
                SizedBox(width: 12), // Tamaño original restaurado
                Expanded(
                  child: _buildStatCard(
                    title: 'Hoy',
                    value: _stats['dia'] ?? 0,
                    icon: Icons.calendar_today,
                    color: Color(0xFFE91E63), // Pink/Red
                    subtitle: 'Inspecciones',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12), // Tamaño original restaurado
          // Segunda fila
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Semana',
                    value: _stats['semana'] ?? 0,
                    icon: Icons.calendar_view_week,
                    color: Color(0xFFFF9800), // Orange
                    subtitle: 'Esta semana',
                  ),
                ),
                SizedBox(width: 12), // Tamaño original restaurado
                Expanded(
                  child: _buildStatCard(
                    title: 'Total',
                    value: _stats['total'] ?? 0,
                    icon: Icons.bar_chart,
                    color: Color(0xFF2196F3), // Light Blue
                    subtitle: 'Acumulado',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    // Calcular porcentaje de progreso basado en el valor
    double progressPercentage = _calculateProgressPercentage(value, title);

    return Stack(
      children: [
        // Card principal
        Container(
          width: double.infinity - 20,
          height: 100,
          margin: EdgeInsets.only(top: 10, right: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: Offset(0, 4),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                SizedBox(height: 8),
                // Valor principal
                Text(
                  _formatValue(value),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                    height: 1.0,
                  ),
                ),
                Spacer(),
                // Barra de progreso
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progressPercentage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Icono circular flotante en la esquina superior derecha
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  double _calculateProgressPercentage(int value, String title) {
    // Calcular porcentaje basado en el tipo de métrica
    switch (title) {
      case 'Pendientes':
        return (value / 20).clamp(0.0, 1.0); // Máximo 20 pendientes = 100%
      case 'Hoy':
        return (value / 10).clamp(0.0, 1.0); // Máximo 10 hoy = 100%
      case 'Semana':
        return (value / 50).clamp(0.0, 1.0); // Máximo 50 semana = 100%
      case 'Total':
        return (value / 200).clamp(0.0, 1.0); // Máximo 200 total = 100%
      default:
        return 0.5; // Valor por defecto
    }
  }

  String _formatValue(int value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    } else if (value >= 100) {
      return '${(value / 100).toStringAsFixed(1)}k';
    } else {
      return value.toString();
    }
  }

  /// Método para refrescar las estadísticas
  Future<void> refreshStats() async {
    setState(() {
      _isLoading = true;
    });
    await _loadDashboardStats();
  }
}
