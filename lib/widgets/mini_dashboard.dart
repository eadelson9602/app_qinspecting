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
      height: 200,
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
      height: 200,
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
                    changeText: '↑ 2.1% vs última semana',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'Hoy',
                    value: _stats['dia'] ?? 0,
                    icon: Icons.today,
                    color: Color(0xFFE91E63), // Pink/Red
                    subtitle: 'Inspecciones',
                    changeText: '↑ 2.1% vs última semana',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
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
                    changeText: '↑ 2.1% vs última semana',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'Total',
                    value: _stats['total'] ?? 0,
                    icon: Icons.analytics,
                    color: Color(0xFF2196F3), // Light Blue
                    subtitle: 'Acumulado',
                    changeText: '↑ 2.1% vs última semana',
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
            // Header con icono y título
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 18,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
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
            SizedBox(height: 4),
            // Subtítulo
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            Spacer(),
            // Indicador de cambio
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: Color(0xFF4CAF50),
                  size: 14,
                ),
                SizedBox(width: 4),
                Text(
                  changeText,
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.w500,
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