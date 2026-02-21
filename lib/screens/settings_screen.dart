import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:app_qinspecting/services/theme_service.dart';
import 'package:app_qinspecting/services/login_service.dart';
import 'package:app_qinspecting/services/app_log_service.dart';
import 'package:app_qinspecting/widgets/custom_loading_truck.dart';
import 'package:app_qinspecting/providers/loading_progress_provider.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  String _cacheSize = 'Calculando...';
  int _totalFiles = 0;
  int _deletedFiles = 0;
  bool _hasLogContent = false;

  @override
  void initState() {
    super.initState();
    _calculateCacheSize();
    _refreshLogState();
  }

  Future<void> _refreshLogState() async {
    final hasContent = await AppLogService.hasLogContent();
    if (mounted) setState(() => _hasLogContent = hasContent);
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

      setState(() {
        _cacheSize = _formatBytes(totalSize);
      });
    } catch (e) {
      setState(() {
        _cacheSize = 'Error al calcular';
      });
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
    // Mostrar diálogo de confirmación
    final bool? confirmClear = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
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
                      '• Se borrará TODA la información almacenada en el dispositivo\n'
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
      },
    );

    // Si el usuario cancela, no hacer nada
    if (confirmClear != true) return;

    try {
      // Inicializar variables de progreso y el provider
      final loadingProgress =
          Provider.of<LoadingProgressProvider>(context, listen: false);
      loadingProgress.startLoading(message: 'Escaneando archivos...');

      setState(() {
        _totalFiles = 0;
        _deletedFiles = 0;
      });

      final directory = await getApplicationDocumentsDirectory();

      // Primero contar todos los archivos
      loadingProgress.updateProgress(0.1, message: 'Contando archivos...');

      List<FileSystemEntity> filesToDelete = [];
      await for (var entity in directory.list(recursive: true)) {
        if (entity is File) {
          filesToDelete.add(entity);
        }
      }

      _totalFiles = filesToDelete.length;

      if (_totalFiles == 0) {
        loadingProgress.finishLoading();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'No hay archivos para eliminar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        return;
      }

      // Ahora eliminar archivos uno por uno con progreso
      for (int i = 0; i < filesToDelete.length; i++) {
        try {
          await filesToDelete[i].delete();
          _deletedFiles++;

          setState(() {
            // Solo actualizar contadores locales
          });

          // Actualizar el provider también
          final progress = (i + 1) / _totalFiles;
          final message =
              'Eliminando archivos... ($_deletedFiles/$_totalFiles)';
          loadingProgress.updateProgress(progress, message: message);

          // Pequeño delay para que se vea el progreso
          await Future.delayed(const Duration(milliseconds: 50));
        } catch (e) {
          // Continuar con el siguiente archivo si hay error
          continue;
        }
      }

      // Finalizar proceso
      loadingProgress.updateProgress(1.0, message: 'Finalizando...');

      await Future.delayed(const Duration(milliseconds: 500));

      loadingProgress.finishLoading();

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Se eliminaron $_deletedFiles archivos del cache',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );

      // Actualizar el tamaño del cache
      _calculateCacheSize();

      // Cerrar sesión automáticamente después de un breve delay
      await Future.delayed(const Duration(seconds: 2));

      final loginService = Provider.of<LoginService>(context, listen: false);
      final resClear = await loginService.logout();
      if (resClear) {
        Navigator.pushNamedAndRemoveUntil(context, 'login', (r) => false);
      }
    } catch (e) {
      final loadingProgress =
          Provider.of<LoadingProgressProvider>(context, listen: false);
      loadingProgress.finishLoading();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al limpiar cache: $e',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<void> _showLogContent() async {
    final content = await AppLogService.getLogContent();
    if (!mounted) return;
    final themeService = Provider.of<ThemeService>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: themeService.isDarkMode ? Colors.grey[900] : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Registro de errores',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: themeService.isDarkMode
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    content.isEmpty ? 'No hay registros de error.' : content,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: themeService.isDarkMode
                          ? Colors.grey[300]
                          : Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _shareLog() async {
    final path = await AppLogService.getLogFilePath();
    if (path == null || path.isEmpty) return;
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(path)],
          text: 'Registro de errores Qinspecting',
          subject: 'Log de errores - Qinspecting',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo compartir: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _clearLogConfirm() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Borrar registro de errores'),
        content: const Text(
          '¿Borrar todo el contenido del registro? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Borrar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await AppLogService.clearLog();
      await _refreshLogState();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registro de errores borrado'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Simula un error de prueba para verificar que el log se crea y se puede compartir.
  Future<void> _simulateError() async {
    await AppLogService.logError(
      'PRUEBA',
      'Error de prueba generado desde Configuración para verificar el registro.',
      error: 'Simulación: fallo de conexión al enviar inspección',
      stackTrace: StackTrace.current,
    );
    await _refreshLogState();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Se agregó una entrada de prueba al registro. Usa "Ver log" o "Compartir" para comprobarlo.',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  void _toggleTheme() {
    final themeService = Provider.of<ThemeService>(context, listen: false);
    themeService.toggleTheme();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          themeService.isDarkMode
              ? 'Tema oscuro activado'
              : 'Tema claro activado',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor:
            themeService.isDarkMode ? Colors.grey[900] : Colors.blue[600],
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
    if (loadingProgress.isLoading)
      return Scaffold(
          body: Center(
              child: CustomLoadingTruck(
        progress: loadingProgress.progress,
        message: loadingProgress.message,
        opacity: 1.0,
      )));
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                elevation: 0,
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
                title: const Text(
                  'Configuración',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                actions: [
                  IconButton(
                    onPressed: _toggleTheme,
                    icon: Icon(
                      themeService.isDarkMode
                          ? Icons.light_mode
                          : Icons.dark_mode,
                    ),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sección de Cache
                      _buildSectionCard(
                        context: context,
                        themeService: themeService,
                        title: 'Gestión de Cache',
                        icon: Icons.storage,
                        children: [
                          _buildInfoRow(
                            context: context,
                            themeService: themeService,
                            label: 'Tamaño del cache:',
                            value: _cacheSize,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: loadingProgress.isLoading
                                  ? null
                                  : _clearCache,
                              icon: const Icon(Icons.delete_sweep),
                              label: const Text('Limpiar Cache'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Sección de Tema
                      _buildSectionCard(
                        context: context,
                        themeService: themeService,
                        title: 'Apariencia',
                        icon: Icons.palette,
                        children: [
                          _buildInfoRow(
                            context: context,
                            themeService: themeService,
                            label: 'Tema actual:',
                            value: themeService.isDarkMode ? 'Oscuro' : 'Claro',
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _toggleTheme,
                              icon: Icon(themeService.isDarkMode
                                  ? Icons.light_mode
                                  : Icons.dark_mode),
                              label: Text(themeService.isDarkMode
                                  ? 'Cambiar a Claro'
                                  : 'Cambiar a Oscuro'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeService.isDarkMode
                                    ? Colors.blue
                                    : Colors.grey[800],
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Sección de GPS (original)
                      _buildSectionCard(
                        context: context,
                        themeService: themeService,
                        title: 'Ubicación',
                        icon: Icons.location_on,
                        children: [
                          Text(
                            'Es necesario activar el GPS para el correcto funcionamiento de la aplicación.',
                            style: TextStyle(
                              fontSize: 14,
                              color: themeService.isDarkMode
                                  ? Colors.grey[300]
                                  : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Solicitando acceso al GPS...'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.gps_fixed),
                              label: const Text('Solicitar Acceso GPS'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Sección Registro de errores
                      _buildSectionCard(
                        context: context,
                        themeService: themeService,
                        title: 'Registro de errores',
                        icon: Icons.bug_report_outlined,
                        children: [
                          Text(
                            'Si tienes problemas al enviar inspecciones, aquí puedes ver y compartir el registro de errores (archivo .txt) para reportarlos.',
                            style: TextStyle(
                              fontSize: 14,
                              color: themeService.isDarkMode
                                  ? Colors.grey[300]
                                  : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            context: context,
                            themeService: themeService,
                            label: 'Estado:',
                            value: _hasLogContent
                                ? 'Hay registros'
                                : 'No hay registros',
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _showLogContent,
                                  icon: const Icon(Icons.visibility, size: 20),
                                  label: const Text('Ver log'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _hasLogContent ? _shareLog : null,
                                  icon: const Icon(Icons.share, size: 20),
                                  label: const Text('Compartir'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed:
                                      _hasLogContent ? _clearLogConfirm : null,
                                  icon: const Icon(Icons.delete_outline,
                                      size: 20),
                                  label: const Text('Borrar'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // const SizedBox(height: 12),
                          // SizedBox(
                          //   width: double.infinity,
                          //   child: OutlinedButton.icon(
                          //     onPressed: _simulateError,
                          //     icon: const Icon(Icons.science, size: 20),
                          //     label: const Text('Simular error de prueba'),
                          //     style: OutlinedButton.styleFrom(
                          //       padding:
                          //           const EdgeInsets.symmetric(vertical: 12),
                          //       shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(12),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Overlay del CustomLoadingTruck cuando se está limpiando el cache
            )
          ],
        );
      },
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required ThemeService themeService,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: themeService.isDarkMode
                ? Colors.grey[400]
                : Colors.grey[600],
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: themeService.isDarkMode
                  ? Colors.grey[200]
                  : Colors.grey[800],
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required ThemeService themeService,
required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeService.isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
