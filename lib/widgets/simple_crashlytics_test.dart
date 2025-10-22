import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:app_qinspecting/services/crashlytics_debug_service.dart';

class SimpleCrashlyticsTest extends StatelessWidget {
  const SimpleCrashlyticsTest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🔥 Crashlytics Debug',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await CrashlyticsDebugService.testCrashlyticsDirectly();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Test ejecutado. Revisa logs y Firebase Console.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Test Directo'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                await CrashlyticsDebugService.checkFirebaseConfig();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Configuración verificada. Revisa logs.'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                }
              },
              child: const Text('Verificar Config'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // Forzar envío de reportes pendientes
                FirebaseCrashlytics.instance.sendUnsentReports();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reportes enviados forzadamente.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Enviar Reportes'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // Registrar un error de prueba
                FirebaseCrashlytics.instance.recordError(
                  Exception('Test error desde UI - ${DateTime.now()}'),
                  StackTrace.current,
                  reason: 'Test desde interfaz de usuario',
                  fatal: false,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error de prueba registrado.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Registrar Error'),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚠️ Nota Importante:',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• En modo DEBUG, los reportes pueden tardar más en aparecer\n'
                    '• Los crashes se envían al reiniciar la app\n'
                    '• Revisa los logs en la consola para verificar funcionamiento\n'
                    '• Los reportes aparecen en Firebase Console en ~5-10 minutos',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
