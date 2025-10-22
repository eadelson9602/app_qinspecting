import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/models/models.dart';
import 'package:app_qinspecting/services/services.dart';

class PendingInspectionsCard extends StatelessWidget {
  const PendingInspectionsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final loginService = Provider.of<LoginService>(context, listen: false);

    return FutureBuilder<List<ResumenPreoperacional>?>(
      future: _getInspectionsWithDebug(loginService),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard(primaryColor);
        }

        if (snapshot.hasError) {
          print('❌ Error en PendingInspectionsCard: ${snapshot.error}');
          return _buildErrorCard(
              primaryColor, 'Error al cargar inspecciones: ${snapshot.error}');
        }

        final inspections = snapshot.data ?? [];
        final pendingCount = inspections.length;

        print(
            '📊 PendingInspectionsCard - Inspecciones encontradas: $pendingCount');

        return _buildAnalyticsCard(
          context,
          primaryColor,
          pendingCount,
          inspections,
        );
      },
    );
  }

  Widget _buildLoadingCard(Color primaryColor) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cargando inspecciones...',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Obteniendo datos pendientes',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(Color primaryColor, String message) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Error',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(
    BuildContext context,
    Color primaryColor,
    int pendingCount,
    List<ResumenPreoperacional> inspections,
  ) {
    // Calcular porcentaje más realista basado en el total de inspecciones
    String percentageText;
    if (inspections.isEmpty) {
      percentageText = '0.0%';
    } else {
      final percentage = (pendingCount / inspections.length) * 100;
      percentageText = '${percentage.toStringAsFixed(1)}%';
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: _buildMetricCard(
        'Inspecciones Pendientes',
        pendingCount.toString(),
        percentageText,
        primaryColor, // Usar el color primario del tema
        Icons.pending_actions_rounded,
        onTap: pendingCount > 0
            ? () => _navigateToSendPendingInspections(context)
            : null,
      ),
    );
  }

  /// Navega a la pantalla de envío de inspecciones pendientes
  void _navigateToSendPendingInspections(BuildContext context) {
    print('🔍 DEBUG: Navegando a send_pending...');
    try {
      Navigator.pushNamed(context, 'send_pending');
      print('✅ DEBUG: Navegación exitosa');
    } catch (e) {
      print('❌ DEBUG: Error en navegación: $e');
    }
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String percentage,
    Color backgroundColor,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    Widget cardContent = Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con icono
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // Valor principal
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          // Porcentaje de cambio
          Row(
            children: [
              Icon(
                Icons.trending_up_rounded,
                color: Colors.white.withValues(alpha: 0.8),
                size: 16,
              ),
              SizedBox(width: 4),
              Text(
                percentage,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }

  Future<List<ResumenPreoperacional>?> _getInspectionsWithDebug(
      LoginService loginService) async {
    try {
      print('🔍 Debug PendingInspectionsCard:');
      print('  - Usuario ID: ${loginService.userDataLogged.id}');
      print(
          '  - Usuario numeroDocumento: ${loginService.userDataLogged.numeroDocumento}');
      print('  - Empresa base: ${loginService.selectedEmpresa.nombreBase}');

      final result = await DBProvider.db.getAllInspections(
        loginService.userDataLogged.numeroDocumento!,
        loginService.selectedEmpresa.nombreBase!,
      );

      print('  - Resultado: ${result?.length ?? 0} inspecciones');
      return result;
    } catch (e) {
      print('❌ Error en _getInspectionsWithDebug: $e');
      rethrow;
    }
  }
}
