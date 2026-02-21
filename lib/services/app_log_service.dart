import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Servicio para registrar errores y fallos en un archivo de log
/// que el usuario puede ver y compartir desde Configuración.
class AppLogService {
  static const String _logFileName = 'qinspecting_log.txt';
  static const int _maxLogSizeBytes = 512 * 1024; // 512 KB máximo

  static Future<File> _getLogFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_logFileName');
  }

  /// Escribe una entrada de error en el log con fecha y categoría.
  static Future<void> logError(
    String category,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) async {
    try {
      final file = await _getLogFile();
      final buffer = StringBuffer();
      final now = DateTime.now();
      final timestamp =
          '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

      buffer.writeln('[$timestamp] [$category] $message');
      if (error != null) {
        buffer.writeln('  Error: $error');
      }
      if (stackTrace != null) {
        buffer.writeln('  StackTrace:');
        for (final line in stackTrace.toString().split('\n')) {
          buffer.writeln('    $line');
        }
      }
      buffer.writeln('---');

      String existing = '';
      if (await file.exists()) {
        existing = await file.readAsString();
      }
      String newContent = existing + buffer.toString();

      // Limitar tamaño: quedarnos con la parte final del log
      if (newContent.length > _maxLogSizeBytes) {
        newContent = '... (log truncado por tamaño)\n\n' +
            newContent.substring(newContent.length - _maxLogSizeBytes);
      }

      await file.writeAsString(newContent, mode: FileMode.write);
    } catch (_) {
      // No fallar la app si no se puede escribir el log
    }
  }

  /// Escribe una entrada informativa (opcional).
  static Future<void> logInfo(String category, String message) async {
    try {
      final file = await _getLogFile();
      final now = DateTime.now();
      final timestamp =
          '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

      String existing = '';
      if (await file.exists()) {
        existing = await file.readAsString();
      }
      String newContent =
          '$existing[$timestamp] [$category] $message\n';

      if (newContent.length > _maxLogSizeBytes) {
        newContent = '... (log truncado)\n\n' +
            newContent.substring(newContent.length - _maxLogSizeBytes);
      }

      await file.writeAsString(newContent, mode: FileMode.write);
    } catch (_) {}
  }

  /// Devuelve la ruta del archivo de log (para compartir).
  static Future<String?> getLogFilePath() async {
    final file = await _getLogFile();
    if (await file.exists()) return file.path;
    return null;
  }

  /// Devuelve todo el contenido del log como texto.
  static Future<String> getLogContent() async {
    try {
      final file = await _getLogFile();
      if (await file.exists()) {
        return await file.readAsString();
      }
    } catch (_) {}
    return '';
  }

  /// Indica si hay contenido en el log (para habilitar Ver/Compartir).
  static Future<bool> hasLogContent() async {
    final content = await getLogContent();
    return content.trim().isNotEmpty;
  }

  /// Borra el archivo de log.
  static Future<void> clearLog() async {
    try {
      final file = await _getLogFile();
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}
