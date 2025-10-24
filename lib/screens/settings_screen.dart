import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:app_qinspecting/services/theme_service.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
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
    try {
      final directory = await getApplicationDocumentsDirectory();
      int deletedFiles = 0;

      await for (var entity in directory.list(recursive: true)) {
        if (entity is File) {
          await entity.delete();
          deletedFiles++;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Se eliminaron $deletedFiles archivos del cache'),
          backgroundColor: Colors.green,
        ),
      );

      _calculateCacheSize();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al limpiar cache: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _toggleTheme() {
    final themeService = Provider.of<ThemeService>(context, listen: false);
    themeService.toggleTheme();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(themeService.isDarkMode ? 'Tema oscuro activado' : 'Tema claro activado'),
        backgroundColor: themeService.isDarkMode ? Colors.grey[800] : Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return Scaffold(
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
                  themeService.isDarkMode ? Icons.light_mode : Icons.dark_mode,
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
                        onPressed: _clearCache,
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
                        icon: Icon(themeService.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                        label: Text(themeService.isDarkMode ? 'Cambiar a Claro' : 'Cambiar a Oscuro'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeService.isDarkMode ? Colors.blue : Colors.grey[800],
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
                        color: themeService.isDarkMode ? Colors.grey[300] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Solicitando acceso al GPS...'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        },
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
                  color: themeService.isDarkMode ? Colors.white : Colors.black87,
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
            color: themeService.isDarkMode ? Colors.grey[300] : Colors.grey[600],
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
