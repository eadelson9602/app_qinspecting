import 'package:flutter/material.dart';
import 'package:app_qinspecting/services/services.dart';

class CrashlyticsTestWidget extends StatelessWidget {
  const CrashlyticsTestWidget({Key? key}) : super(key: key);

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
              '🔥 Firebase Crashlytics - Tests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Prueba la integración de Crashlytics:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await CrashlyticsTestService.testCrashlyticsIntegration();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Tests de integración ejecutados. Revisa Firebase Console.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    child: const Text('Test Completo'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await CrashlyticsTestService.testCameraErrors();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Tests de cámara ejecutados. Revisa Firebase Console.'),
                            backgroundColor: Colors.blue,
                          ),
                        );
                      }
                    },
                    child: const Text('Test Cámara'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await CrashlyticsService.recordError(
                        Exception('Test crash manual'),
                        StackTrace.current,
                        reason: 'Test manual de crash',
                        fatal: false,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Error de prueba registrado.'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text('Test Error'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await CrashlyticsTestService.cleanupTestData();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Datos de prueba limpiados.'),
                            backgroundColor: Colors.grey,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text('Limpiar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📊 Instrucciones:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1. Ejecuta los tests\n'
                    '2. Ve a Firebase Console → Crashlytics\n'
                    '3. Los reportes aparecen en ~5 minutos\n'
                    '4. Revisa Issues, Users y Velocity',
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
