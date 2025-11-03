import 'package:flutter/material.dart';
import 'package:app_qinspecting/screens/screens.dart';

/// Widget reutilizable que muestra un diálogo cuando no hay items de inspección disponibles
class NoInspectionItemsDialog extends StatelessWidget {
  final String placa;
  final String tipo; // "vehículo" o "remolque"

  const NoInspectionItemsDialog({
    Key? key,
    required this.placa,
    this.tipo = 'vehículo',
  }) : super(key: key);

  /// Muestra el diálogo de forma estática
  static Future<void> show(
    BuildContext context, {
    required String placa,
    String tipo = 'vehículo',
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => NoInspectionItemsDialog(
        placa: placa,
        tipo: tipo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Sin items de inspección',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No se encontraron items de inspección para la placa $placa del $tipo.',
          ),
          SizedBox(height: 12),
          Text(
            '¿Desea volver a descargar los datos de inspección?',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            // Navegar a la pantalla de carga de datos
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GetDataScreen(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: Text('Descargar datos'),
        ),
      ],
    );
  }
}

