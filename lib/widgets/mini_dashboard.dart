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

      if (loginService.userDataLogged.id != null &&
          loginService.selectedEmpresa.nombreBase != null) {
        final stats = await dbProvider.getDashboardStats(
            loginService.userDataLogged.id.toString(),
            loginService.selectedEmpresa.nombreBase!);

        setState(() {
          _stats = stats;
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
      height: 160, // Ajustado para coincidir con el dashboard
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
      height: 160, // Reducido de 180 a 160
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
                    icon: Icons.pending_actions,
                    color: Color(0xFF9C27B0), // Purple
                    subtitle: 'Por enviar',
                    changeText: '↑ 2.1%',
                  ),
                ),
                SizedBox(width: 6), // Reducido de 8 a 6
                Expanded(
                  child: _buildStatCard(
                    title: 'Hoy',
                    value: _stats['dia'] ?? 0,
                    icon: Icons.today,
                    color: Color(0xFFE91E63), // Pink/Red
                    subtitle: 'Inspecciones',
                    changeText: '↑ 2.1%',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 6), // Reducido de 8 a 6
          // Segunda fila
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Semana',
                    value: _stats['semana'] ?? 0,
                    icon: Icons.date_range,
                    color: Color(0xFFFF9800), // Orange
                    subtitle: 'Esta semana',
                    changeText: '↑ 2.1%',
                  ),
                ),
                SizedBox(width: 6), // Reducido de 8 a 6
                Expanded(
                  child: _buildStatCard(
                    title: 'Total',
                    value: _stats['total'] ?? 0,
                    icon: Icons.analytics,
                    color: Color(0xFF2196F3), // Light Blue
                    subtitle: 'Acumulado',
                    changeText: '↑ 2.1%',
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
    required String changeText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10), // Reducido de 12 a 10
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06), // Reducido de 0.08 a 0.06
            blurRadius: 10, // Reducido de 15 a 10
            offset: Offset(0, 2), // Reducido de 3 a 2
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03), // Reducido de 0.04 a 0.03
            blurRadius: 3, // Reducido de 4 a 3
            offset: Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(8), // Reducido de 12 a 8
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header con icono y título
            Row(
              children: [
                Container(
                  width: 24, // Reducido de 28 a 24
                  height: 24, // Reducido de 28 a 24
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(5), // Reducido de 6 a 5
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 14, // Reducido de 16 a 14
                  ),
                ),
                SizedBox(width: 4), // Reducido de 6 a 4
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 11, // Reducido de 12 a 11
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6), // Reducido de 8 a 6
            // Valor principal
            Text(
              _formatValue(value),
              style: TextStyle(
                fontSize: 18, // Reducido de 20 a 18
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
                height: 1.0,
              ),
            ),
            SizedBox(height: 2),
            // Subtítulo
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 9, // Reducido de 10 a 9
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2), // Reducido de 4 a 2
            // Indicador de cambio
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: Color(0xFF4CAF50),
                  size: 10, // Reducido de 12 a 10
                ),
                SizedBox(width: 2),
                Expanded(
                  child: Text(
                    changeText,
                    style: TextStyle(
                      fontSize: 8, // Reducido de 9 a 8
                      color: Color(0xFF4CAF50),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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