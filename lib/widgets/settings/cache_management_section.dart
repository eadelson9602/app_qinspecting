import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:app_qinspecting/services/login_service.dart';
import 'package:app_qinspecting/providers/loading_progress_provider.dart';
import 'package:app_qinspecting/widgets/settings/settings_ios_group.dart';
import 'package:app_qinspecting/widgets/settings/settings_ios_tile.dart';
import 'package:app_qinspecting/widgets/settings/settings_themed_divider.dart';

class CacheManagementSection extends StatefulWidget {
  const CacheManagementSection({Key? key}) : super(key: key);

  @override
  State<CacheManagementSection> createState() => _CacheManagementSectionState();
}

class _CacheManagementSectionState extends State<CacheManagementSection> {
  String _cacheSize = 'Calculando...';

  @override
  void initState() {
    super.initState();
    _calculateCacheSize();
  }

  Future<void> _calculateCacheSize() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      int totalSize = 0;

      await for (var entity in directory.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }

      if (mounted) {
        setState(() {
          _cacheSize = _formatBytes(totalSize);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cacheSize = 'Error al calcular';
        });
      }
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Future<void> _clearCache() async {
    final bool? confirmClear = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => _ClearCacheDialog(),
    );

    if (confirmClear != true) return;

    try {
      final loadingProgress =
          Provider.of<LoadingProgressProvider>(context, listen: false);
      loadingProgress.startLoading(message: 'Escaneando archivos...');

      final directory = await getApplicationDocumentsDirectory();
      loadingProgress.updateProgress(0.1, message: 'Contando archivos...');

      List<FileSystemEntity> filesToDelete = [];
      await for (var entity in directory.list(recursive: true)) {
        if (entity is File) {
          filesToDelete.add(entity);
        }
      }

      final totalFiles = filesToDelete.length;

      if (totalFiles == 0) {
        loadingProgress.finishLoading();
        _showSnackBar(
          'No hay archivos para eliminar',
          Colors.orange,
        );
        return;
      }

      int deletedFiles = 0;
      for (int i = 0; i < filesToDelete.length; i++) {
        try {
          await filesToDelete[i].delete();
          deletedFiles++;

          final progress = (i + 1) / totalFiles;
          final message = 'Eliminando archivos... ($deletedFiles/$totalFiles)';
          loadingProgress.updateProgress(progress, message: message);

          await Future.delayed(const Duration(milliseconds: 50));
        } catch (e) {
          continue;
        }
      }

      loadingProgress.updateProgress(1.0, message: 'Finalizando...');
      await Future.delayed(const Duration(milliseconds: 500));
      loadingProgress.finishLoading();

      _showSnackBar(
        'Se eliminaron $deletedFiles archivos del cache',
        Colors.green,
      );

      _calculateCacheSize();

      await Future.delayed(const Duration(seconds: 2));

      final loginService = Provider.of<LoginService>(context, listen: false);
      final resClear = await loginService.logout();
      if (resClear && mounted) {
        Navigator.pushNamedAndRemoveUntil(context, 'login', (r) => false);
      }
    } catch (e) {
      final loadingProgress =
          Provider.of<LoadingProgressProvider>(context, listen: false);
      loadingProgress.finishLoading();

      _showSnackBar('Error al limpiar cache: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loadingProgress =
        Provider.of<LoadingProgressProvider>(context, listen: true);

    return SettingsIosGroup(
      children: [
        SettingsIosTile(
          leading: CupertinoIcons.archivebox,
          title: 'Gestión de Cache',
          subtitle: 'Tamaño del cache',
          trailing: Text(
            _cacheSize,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SettingsThemedDivider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              color: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 12),
              onPressed: loadingProgress.isLoading ? null : _clearCache,
              borderRadius: BorderRadius.circular(10),
              child: const Text(
                'Limpiar Cache',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        )
      ],
    );
  }
}

class _ClearCacheDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Text('Confirmar Limpieza'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¿Estás seguro de que quieres limpiar el cache?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Advertencia',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '• Se borrará TODA la información de inspecciones que tengas almacenada en caché en el dispositivo\n'
                  '• Los datos NO se podrán recuperar\n'
                  '• Se cerrará la sesión automáticamente\n'
                  '• Deberás volver a iniciar sesión',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(
            'Cancelar',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Limpiar Cache',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
