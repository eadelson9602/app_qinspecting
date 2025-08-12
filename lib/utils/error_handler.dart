import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' show PlatformDispatcher;

class ErrorHandler {
  static void initialize() {
    // Configurar manejo de errores del framework
    FlutterError.onError = (FlutterErrorDetails details) {
      _handleFlutterError(details);
    };

    // Configurar manejo de errores no capturados
    PlatformDispatcher.instance.onError = (error, stack) {
      _handlePlatformError(error, stack);
      return true;
    };
  }

  static void _handleFlutterError(FlutterErrorDetails details) {
    // Lista de errores conocidos del framework que se pueden ignorar
    final knownErrors = [
      'mouse_tracker.dart',
      'PointerAddedEvent',
      'PointerRemovedEvent',
      'Failed assertion',
      'onDisplayChanged',
      'updatePointerIcon',
    ];

    // Verificar si es un error conocido del framework
    final errorString = details.exception.toString();
    bool isKnownError = knownErrors.any((error) => errorString.contains(error));

    if (isKnownError) {
      // Solo log del error, no mostrar al usuario
      print('Framework error (ignored): ${details.exception}');
      print('Stack trace: ${details.stack}');
      return;
    }

    // Para errores críticos, usar el handler por defecto
    FlutterError.presentError(details);
  }

  static void _handlePlatformError(Object error, StackTrace stack) {
    // Manejar errores de la plataforma
    print('Platform error: $error');
    print('Stack trace: $stack');
  }

  // Método para configurar el sistema de errores en widgets
  static Widget wrapWithErrorHandler(Widget child) {
    return ErrorBoundary(child: child);
  }
}

// Widget boundary para capturar errores en widgets específicos
class ErrorBoundary extends StatefulWidget {
  final Widget child;

  const ErrorBoundary({Key? key, required this.child}) : super(key: key);

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    // Configurar manejo de errores específicos para este widget
    SystemChannels.platform.setMethodCallHandler((call) async {
      // Manejar llamadas específicas del sistema
      switch (call.method) {
        case 'SystemNavigator.pop':
          // Manejar navegación del sistema
          break;
        default:
          // Manejar otras llamadas del sistema
          break;
      }
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorWidget();
    }

    return widget.child;
  }

  Widget _buildErrorWidget() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Algo salió mal',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _errorMessage = '';
                });
              },
              child: Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
