import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';

import 'screens/screens.dart';
import 'utils/error_handler.dart';
import 'ui/app_theme.dart';

import 'package:app_qinspecting/providers/providers.dart';

import 'services/services.dart';
import 'services/notification_service.dart';
import 'services/background_upload_service.dart';
import 'services/real_background_upload_service.dart';

void main() async {
  // Configurar Flutter para evitar errores del mouse tracker
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicializar Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('[Firebase] ✅ Inicializado correctamente');

    // Inicializar Crashlytics
    await CrashlyticsService.initialize();

    // Configurar Crashlytics para modo debug
    if (kDebugMode) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      print('[Firebase] 🔍 Crashlytics habilitado para debug');
    }

    // Configurar manejo de errores de Flutter
    FlutterError.onError = (FlutterErrorDetails details) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      FlutterError.presentError(details);
      print('Flutter Error: ${details.exception}');
    };

    // Configurar manejo de errores de plataforma
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      print('Platform Error: $error');
      return true;
    };

    // Inicializar servicios de notificaciones y trabajo en segundo plano
    await NotificationService.initialize();
    await BackgroundUploadService.initialize();
    await RealBackgroundUploadService.initialize();

    // Inicializar el manejador de errores
    ErrorHandler.initialize();

    print('[App] ✅ Todos los servicios inicializados correctamente');
  } catch (e) {
    print('[App] ❌ Error al inicializar servicios: $e');
    // Registrar error en Crashlytics si está disponible
    try {
      await CrashlyticsService.recordError(e, StackTrace.current,
          reason: 'Error en inicialización de app');
    } catch (_) {
      // Si Crashlytics no está disponible, continuar sin él
    }
  }

  runApp(const AppState());
}

class AppState extends StatelessWidget {
  const AppState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => UiProvider()),
      ChangeNotifierProvider(create: (_) => LoginService()),
      ChangeNotifierProvider(create: (_) => InspeccionProvider()),
      ChangeNotifierProvider(create: (_) => LoginFormProvider()),
      ChangeNotifierProvider(create: (_) => PerfilFormProvider()),
      ChangeNotifierProvider(create: (_) => InspeccionService()),
      ChangeNotifierProvider(create: (_) => FirmaService()),
    ], child: const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
        child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Qinspecting',
      theme: AppTheme.lightTheme,
      initialRoute: 'check_auth',
      routes: {
        'login': (_) => const LoginScreen(),
        'home': (_) => const HomeScreen(),
        'profile': (_) => const ProfileScreen(),
        'inspeccion': (_) => const InspeccionScreen(),
        'signature': (_) => const SignatureScreen(),
        'send_pending': (_) => const SendPendingInspectionScree(),
        'settings': (_) => const SettingScreen(),
        'inspeccion_vehiculo': (_) => const InspeccionVehiculoScreen(),
        'inspeccion_remolque': (_) => const InspeccionRemolqueScreen(),
        'create_signature': (_) => const CreateSignatureScreen(),
        'check_auth': (_) => CheckScreen(),
        'get_data': (_) => GetDataScreen(),
        'pdf': (_) => PdfScreen(),
        'pdf_offline': (_) => PdfScreenOffline(),
        'remember_password': (_) => RememberPasswordScreen(),
      },
      // Se usa para controlar pagina que no existes 404
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const HomeScreen());
      },
      // Configurar builder para manejar errores
      builder: (context, child) {
        return ErrorHandler.wrapWithErrorHandler(child!);
      },
    ));
  }
}
