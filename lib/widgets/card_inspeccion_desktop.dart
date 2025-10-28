import 'package:flutter/material.dart';

import 'package:app_qinspecting/models/inspeccion.dart';
import 'package:app_qinspecting/services/services.dart';
import '../ui/app_theme.dart';

class CardInspeccionDesktop extends StatelessWidget {
  const CardInspeccionDesktop({
    Key? key,
    required this.resumenPreoperacional,
    this.inspeccionOffline,
  }) : super(key: key);

  final ResumenPreoperacionalServer resumenPreoperacional;
  final ResumenPreoperacional? inspeccionOffline;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black.withValues(alpha: 0.08)
                : Theme.of(context).shadowColor.withValues(alpha: 0.2),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                            'Inspección',
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.titleLarge?.color,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          // Mostrar ID local si hay datos offline, sino mostrar consecutivo
                          inspeccionOffline != null
                              ? '${inspeccionOffline!.id}'
                              : '${resumenPreoperacional.consecutivo ?? "Pendiente"}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  // padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Colors.red.shade500,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.picture_as_pdf_outlined),
                    color: Colors.white,
                    onPressed: () async {
                      // Verificar conexión
                      final inspeccionService = InspeccionService();
                      final hasConnection =
                          await inspeccionService.checkConnection();

                      if (hasConnection) {
                        // Con conexión: usar pdf normal
                        Navigator.pushNamed(context, 'pdf',
                            arguments: [resumenPreoperacional]);
                      } else {
                        // Sin conexión: usar pdf offline
                        if (inspeccionOffline != null) {
                          Navigator.pushNamed(context, 'pdf_offline',
                              arguments: [inspeccionOffline]);
                        } else {
                          // Si no hay datos offline, mostrar mensaje
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'No hay datos disponibles para generar el PDF offline'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // Contenido de la tarjeta
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: _buildInfoRow(
                        'Responsable',
                        resumenPreoperacional.creado.toString(),
                        Icons.person_outline,
                        const Color(0xFF1976D2), // Blue
                        context,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoRow(
                        'Placa',
                        resumenPreoperacional.placaVehiculo.toString(),
                        Icons.local_shipping_outlined,
                        const Color(0xFF2196F3), // Dark Blue
                        context,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoRow(
                          'Fecha',
                          resumenPreoperacional.fechaPreoperacional.toString(),
                          Icons.calendar_today_outlined,
                          const Color(0xFF4CAF50), // Green
                          context,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoRow(
                          'Hora',
                          resumenPreoperacional.hora == null
                              ? '--'
                              : resumenPreoperacional.hora.toString(),
                          Icons.access_time_outlined,
                          const Color(0xFFFF9800), // Orange
                          context,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: _buildInfoRow(
                        'Kilometraje',
                        resumenPreoperacional.kilometraje.toString(),
                        Icons.directions_run_outlined,
                        const Color(0xFF4CAF50), // Green
                        context,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoRow(
                        'Tanqueo',
                        resumenPreoperacional.tanqueo.toString(),
                        Icons.local_gas_station_outlined,
                        const Color(0xFF9C27B0), // Purple
                        context,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoRow(
                          'Fallas graves',
                          resumenPreoperacional.grave.toString(),
                          Icons.warning_outlined,
                          const Color(0xFFF44336), // Red
                          context,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoRow(
                          'Fallas moderadas',
                          resumenPreoperacional.moderada.toString(),
                          Icons.info_outline,
                          const Color(0xFFFF9800), // Orange
                          context,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
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
                Text(
                  'Estado',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
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

  Widget _buildInfoRow(String label, String value, IconData icon,
      Color iconColor, BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 14,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleMedium?.color,
                  fontSize: 13,
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
