import 'package:flutter/services.dart';

class UploadForegroundService {
  static const MethodChannel _channel = MethodChannel('upload_service');

  /// Inicia el servicio de primer plano
  static Future<String> startForegroundService() async {
    try {
      final String result = await _channel.invokeMethod('startForegroundService');
      print('🔋 DEBUG: Servicio de primer plano iniciado: $result');
      return result;
    } catch (e) {
      print('❌ ERROR: Error iniciando servicio de primer plano: $e');
      rethrow;
    }
  }

  /// Detiene el servicio de primer plano
  static Future<String> stopForegroundService() async {
    try {
      final String result = await _channel.invokeMethod('stopForegroundService');
      print('🔋 DEBUG: Servicio de primer plano detenido: $result');
      return result;
    } catch (e) {
      print('❌ ERROR: Error deteniendo servicio de primer plano: $e');
      rethrow;
    }
  }
}
