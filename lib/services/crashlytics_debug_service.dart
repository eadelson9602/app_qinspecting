import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class CrashlyticsDebugService {
  /// Verifica si Crashlytics está funcionando
  static Future<void> testCrashlyticsDirectly() async {
    try {
      print('[CrashlyticsDebug] 🔍 Iniciando test directo...');
      
      // 1. Verificar si Crashlytics está habilitado
      final isEnabled = await FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled();
      print('[CrashlyticsDebug] 📊 Crashlytics habilitado: $isEnabled');
      
      // 2. Registrar un log
      await FirebaseCrashlytics.instance.log('Test directo de Crashlytics - ${DateTime.now()}');
      print('[CrashlyticsDebug] 📝 Log registrado');
      
      // 3. Registrar información de usuario
      await FirebaseCrashlytics.instance.setUserIdentifier('test_user_debug');
      await FirebaseCrashlytics.instance.setCustomKey('test_key', 'test_value');
      print('[CrashlyticsDebug] 👤 Usuario configurado');
      
      // 4. Registrar un error no fatal
      await FirebaseCrashlytics.instance.recordError(
        Exception('Test error directo - ${DateTime.now()}'),
        StackTrace.current,
        reason: 'Test directo de integración',
        fatal: false,
      );
      print('[CrashlyticsDebug] ❌ Error registrado');
      
      // 5. Forzar envío de datos
      await FirebaseCrashlytics.instance.sendUnsentReports();
      print('[CrashlyticsDebug] 📤 Datos enviados forzadamente');
      
      print('[CrashlyticsDebug] ✅ Test directo completado');
      
    } catch (e) {
      print('[CrashlyticsDebug] ❌ Error en test directo: $e');
    }
  }
  
  /// Fuerza un crash para testing
  static void forceCrash() {
    print('[CrashlyticsDebug] 💥 Forzando crash para testing...');
    FirebaseCrashlytics.instance.crash();
  }
  
  /// Verifica configuración de Firebase
  static Future<void> checkFirebaseConfig() async {
    try {
      print('[CrashlyticsDebug] 🔍 Verificando configuración de Firebase...');
      
      // Verificar si Firebase está inicializado
      print('[CrashlyticsDebug] 📱 Firebase App: ${FirebaseCrashlytics.instance.app.name}');
      
      // Verificar configuración de Crashlytics
      final isEnabled = await FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled();
      print('[CrashlyticsDebug] 📊 Crashlytics habilitado: $isEnabled');
      
      // Habilitar Crashlytics si no está habilitado
      if (!isEnabled) {
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
        print('[CrashlyticsDebug] ✅ Crashlytics habilitado manualmente');
      }
      
    } catch (e) {
      print('[CrashlyticsDebug] ❌ Error verificando configuración: $e');
    }
  }
}
