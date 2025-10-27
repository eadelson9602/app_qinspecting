import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:app_qinspecting/services/theme_service.dart';
import 'package:app_qinspecting/services/login_service.dart';
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

  Future<void> _requestLocationPermission() async {
    try {
      // Verificar si el servicio de ubicación está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'El servicio de ubicación está deshabilitado. Por favor, actívalo en la configuración del dispositivo.',
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
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }

      // Verificar permisos de ubicación
      LocationPermission permission = await Geolocator.checkPermission();

      // Si el permiso está denegado permanentemente
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Permisos de ubicación denegados permanentemente. Por favor, otorga los permisos en la configuración de la aplicación.',
              style: TextStyle(
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
            duration: const Duration(seconds: 5),
          ),
        );
        return;
      }

      // Si el permiso está denegado, solicitarlo
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitando permiso de ubicación...'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );

        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Permisos de ubicación denegados',
                style: TextStyle(
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
          return;
        }
      }

      // Si llegamos aquí, el permiso fue otorgado
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Permisos de ubicación otorgados correctamente',
              style: TextStyle(
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
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al solicitar permisos: $e',
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
                  icon: const Icon(Icons.arrow_back),
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
              body: Padding(
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
                            onPressed:
                                loadingProgress.isLoading ? null : _clearCache,
                            icon: const Icon(Icons.delete_sweep),
                            label: const Text('Limpiar Cache'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
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
                              padding: const EdgeInsets.symmetric(vertical: 12),
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
                            onPressed: _requestLocationPermission,
                            icon: const Icon(Icons.gps_fixed),
                            label: const Text('Solicitar Acceso GPS'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Overlay del CustomLoadingTruck cuando se está limpiando el cache
            )
          ],
        );
      },
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
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: themeService.isDarkMode ? Colors.white : Colors.black87,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color:
                      themeService.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
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
            color:
                themeService.isDarkMode ? Colors.grey[300] : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: themeService.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }
}
