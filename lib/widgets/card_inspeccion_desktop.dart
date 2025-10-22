import 'package:flutter/material.dart';

import 'package:app_qinspecting/models/models.dart';
import '../ui/app_theme.dart';

class CardInspeccionDesktop extends StatelessWidget {
  const CardInspeccionDesktop({Key? key, required this.resumenPreoperacional})
      : super(key: key);

  final ResumenPreoperacionalServer resumenPreoperacional;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 340,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header de la tarjeta
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    color: AppTheme.primaryGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '#${resumenPreoperacional.resuPreId}',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Activa',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Inspección detallada',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.copy_outlined,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          // Contenido de la tarjeta
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    'Detalle',
                    resumenPreoperacional.detalle.toString(),
                    Icons.description_outlined,
                    const Color(0xFF2196F3), // Dark Blue
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    'Responsable',
                    resumenPreoperacional.creado.toString(),
                    Icons.person_outline,
                    const Color(0xFF1976D2), // Blue
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    'Fecha',
                    resumenPreoperacional.fechaPreoperacional.toString(),
                    Icons.calendar_today_outlined,
                    const Color(0xFF4CAF50), // Green
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    'Hora',
                    resumenPreoperacional.hora.toString(),
                    Icons.access_time_outlined,
                    const Color(0xFFFF9800), // Orange
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    'Tanqueo',
                    resumenPreoperacional.tanqueo.toString(),
                    Icons.local_gas_station_outlined,
                    const Color(0xFF9C27B0), // Purple
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoRow(
                          'Fallas graves',
                          resumenPreoperacional.grave.toString(),
                          Icons.warning_outlined,
                          const Color(0xFFF44336), // Red
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoRow(
                          'Fallas moderadas',
                          resumenPreoperacional.moderada.toString(),
                          Icons.info_outline,
                          const Color(0xFFFF9800), // Orange
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Footer con estado
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: AppTheme.successColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Estado',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.successColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'APROBADO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, Color iconColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 16,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

}
