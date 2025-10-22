import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class SafeCrashlyticsTest extends StatefulWidget {
  const SafeCrashlyticsTest({Key? key}) : super(key: key);

  @override
  State<SafeCrashlyticsTest> createState() => _SafeCrashlyticsTestState();
}

class _SafeCrashlyticsTestState extends State<SafeCrashlyticsTest> {
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _safeShowSnackBar(String message, Color color) {
    if (!_isDisposed && mounted) {
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: color,
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (e) {
        print('[SafeCrashlyticsTest] Error showing SnackBar: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🔥 Safe Crashlytics Test',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await FirebaseCrashlytics.instance.log('Safe test - ${DateTime.now()}');
                      await FirebaseCrashlytics.instance.recordError(
                        Exception('Safe test error - ${DateTime.now()}'),
                        StackTrace.current,
                        reason: 'Safe test from UI',
                        fatal: false,
                      );
                      await FirebaseCrashlytics.instance.sendUnsentReports();
                      _safeShowSnackBar('Safe test ejecutado', Colors.green);
                    } catch (e) {
                      print('[SafeCrashlyticsTest] Error: $e');
                      _safeShowSnackBar('Error en test: $e', Colors.red);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                  ),
                  child: const Text('Safe Test', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await FirebaseCrashlytics.instance.sendUnsentReports();
                      _safeShowSnackBar('Reportes enviados', Colors.orange);
                    } catch (e) {
                      print('[SafeCrashlyticsTest] Error sending reports: $e');
                      _safeShowSnackBar('Error enviando: $e', Colors.red);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                  ),
                  child: const Text('Enviar', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
