import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_qinspecting/models/inspeccion.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/widgets/inspection_upload_state.dart';
import 'package:app_qinspecting/widgets/inspection_action_buttons.dart';

class PendingInspectionCard extends StatelessWidget {
  final ResumenPreoperacional inspeccion;
  final int index;
  final bool isBackgroundUploadActive;
  final VoidCallback onSendPressed;

  const PendingInspectionCard({
    Key? key,
    required this.inspeccion,
    required this.index,
    required this.isBackgroundUploadActive,
    required this.onSendPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inspeccionService =
        Provider.of<InspeccionService>(context, listen: true);

    final isUploading = (inspeccionService.isSaving &&
            inspeccionService.indexSelected == index) ||
        (isBackgroundUploadActive && inspeccionService.indexSelected == index);

    return Card(
      elevation: 10,
      shadowColor: Theme.of(context).shadowColor,
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.grey.withValues(alpha: 0.2)
              : Theme.of(context).shadowColor.withValues(alpha: 0.2),
        ),
      ),
      child: isUploading
          ? InspectionUploadState(
              isBackgroundUploadActive: isBackgroundUploadActive,
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _InspectionHeader(
                  inspeccion: inspeccion,
                  index: index,
                ),
                InspectionActionButtons(
                  inspeccion: inspeccion,
                  index: index,
                  onSendPressed: onSendPressed,
                ),
              ],
            ),
    );
  }
}

class _InspectionHeader extends StatelessWidget {
  final ResumenPreoperacional inspeccion;
  final int index;

  const _InspectionHeader({
    Key? key,
    required this.inspeccion,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Icono circular con color
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Color(0xFF2196F3), // Azul
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.description_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Información de la inspección
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inspección No. ${index + 1}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Realizado el ${inspeccion.fechaPreoperacional ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

