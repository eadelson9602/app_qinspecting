import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:app_qinspecting/models/inspeccion.dart';
import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/services/services.dart';

class InspectionActionButtons extends StatelessWidget {
  final ResumenPreoperacional inspeccion;
  final int index;
  final VoidCallback onSendPressed;

  const InspectionActionButtons({
    Key? key,
    required this.inspeccion,
    required this.index,
    required this.onSendPressed,
  }) : super(key: key);

  Future<void> _handleDelete(BuildContext context) async {
    final inspeccionProvider =
        Provider.of<InspeccionProvider>(context, listen: false);
    final inspeccionService =
        Provider.of<InspeccionService>(context, listen: false);

    if (inspeccionService.isSaving) return;

    final responseDelete = await inspeccionProvider
        .eliminarResumenPreoperacional(inspeccion.id!);
    await inspeccionProvider
        .eliminarRespuestaPreoperacional(inspeccion.id!);

    showSimpleNotification(
      Text('Inspección ${responseDelete} eliminada'),
      leading: const Icon(Icons.check),
      autoDismiss: true,
      background: Colors.green,
      position: NotificationPosition.bottom,
    );
  }

  void _handlePdf(BuildContext context) {
    final inspeccionService =
        Provider.of<InspeccionService>(context, listen: false);

    if (inspeccionService.isSaving) return;

    inspeccionService.indexSelected = index;
    Navigator.pushNamed(
      context,
      'pdf_offline',
      arguments: [inspeccion],
    );
  }

  @override
  Widget build(BuildContext context) {
    final inspeccionService =
        Provider.of<InspeccionService>(context, listen: true);

    final isDisabled = inspeccionService.isSaving;
    final disabledColor = Colors.grey;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Botón eliminar
          _ActionButton(
            icon: Icons.delete_outline,
            color: isDisabled ? disabledColor : const Color(0xFFF44336),
            onPressed: isDisabled ? null : () => _handleDelete(context),
          ),
          const SizedBox(width: 12),
          // Botón PDF
          _ActionButton(
            icon: Icons.picture_as_pdf_outlined,
            color: isDisabled ? disabledColor : const Color(0xFFE91E63),
            onPressed: isDisabled ? null : () => _handlePdf(context),
          ),
          const SizedBox(width: 12),
          // Botón enviar
          _ActionButton(
            icon: inspeccionService.isSaving
                ? Icons.hourglass_empty
                : Icons.send_outlined,
            color: isDisabled ? disabledColor : const Color(0xFF4CAF50),
            onPressed: isDisabled ? null : onSendPressed,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  const _ActionButton({
    Key? key,
    required this.icon,
    required this.color,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        onPressed: onPressed,
      ),
    );
  }
}

