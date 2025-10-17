import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_qinspecting/services/services.dart';

/// Widget para mostrar el progreso de subida en el listado
class UploadProgressIndicator extends StatelessWidget {
  final int index;
  final bool isUploading;

  const UploadProgressIndicator({
    Key? key,
    required this.index,
    required this.isUploading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isUploading) return SizedBox.shrink();

    return Consumer<InspeccionService>(
      builder: (context, inspeccionService, child) {
        // Solo mostrar si es la inspección que se está subiendo
        if (inspeccionService.indexSelected != index) {
          return SizedBox.shrink();
        }

        return Container(
          margin: EdgeInsets.symmetric(vertical: 8),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.cloud_upload, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'Subiendo Inspección',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  Spacer(),
                  if (inspeccionService.batchProgress > 0)
                    Text(
                      '${(inspeccionService.batchProgress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 8),
              LinearProgressIndicator(
                value: inspeccionService.batchProgress,
                backgroundColor: Colors.blue.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              SizedBox(height: 8),
              Text(
                'Progreso: ${inspeccionService.currentBatchIndex}/${inspeccionService.totalBatches}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Widget para mostrar el estado de subida en segundo plano
class BackgroundUploadStatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<InspeccionService>(
      builder: (context, inspeccionService, child) {
        // Solo mostrar si hay una subida en segundo plano
        if (!inspeccionService.isSaving) {
          return SizedBox.shrink();
        }

        return Card(
          margin: EdgeInsets.all(8),
          color: Colors.green.shade50,
          child: ListTile(
            leading: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            title: Text(
              'Subida en Segundo Plano',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Una inspección se está subiendo en segundo plano',
                  style: TextStyle(color: Colors.green.shade700),
                ),
                if (inspeccionService.batchProgress > 0)
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: LinearProgressIndicator(
                      value: inspeccionService.batchProgress,
                      backgroundColor: Colors.green.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.cancel, color: Colors.red),
              onPressed: () async {
                await inspeccionService.cancelBackgroundUpload();
              },
            ),
          ),
        );
      },
    );
  }
}
