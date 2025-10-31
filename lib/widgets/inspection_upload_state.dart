import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_qinspecting/services/services.dart';

class InspectionUploadState extends StatelessWidget {
  final bool isBackgroundUploadActive;

  const InspectionUploadState({
    Key? key,
    required this.isBackgroundUploadActive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inspeccionService =
        Provider.of<InspeccionService>(context, listen: true);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Image(
              image: const AssetImage('assets/images/truck.gif'),
              height: 50,
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              isBackgroundUploadActive
                  ? 'Puedes usar otras apps, pero NO cierres Qinspecting'
                  : 'Por favor NO cierre y no se salga de la app, mientras se este enviando la inspección',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          // Progreso por lote: lote actual / total y barra determinada
          if (!isBackgroundUploadActive) ...[
            Text(
              'Lote ${inspeccionService.currentBatchIndex} de ${inspeccionService.totalBatches}',
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: inspeccionService.batchProgress == 0
                  ? null
                  : inspeccionService.batchProgress,
            ),
          ],
          const SizedBox(height: 8),
          // Mostrar progreso del proceso en segundo plano si está activo
          if (isBackgroundUploadActive)
            Column(
              children: [
                const Text(
                  'Enviando inspección',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Progreso: ${(inspeccionService.batchProgress * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

