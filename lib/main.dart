import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';

import 'screens/screens.dart';
import 'utils/error_handler.dart';

import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/providers/loading_progress_provider.dart';

import 'services/services.dart';
import 'services/background_upload_service.dart';
import 'services/real_background_upload_service.dart';
import 'services/theme_service.dart';

void main() async {
  // Configurar Flutter para evitar errores del mouse tracker
  WidgetsFlutterBinding.ensureInitialized();

  // --- Inicialización mínima antes del primer frame (evita ANR en nativeSurfaceCreated) ---
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kDebugMode) print('[Firebase] ✅ Inicializado correctamente');

    await CrashlyticsService.initialize();
    if (kDebugMode) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      print('[Firebase] 🔍 Crashlytics habilitado para debug');
    }

    FlutterError.onError = (FlutterErrorDetails details) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      FlutterError.presentError(details);
      if (kDebugMode) print('Flutter Error: ${details.exception}');
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      if (kDebugMode) print('Platform Error: $error');
      return true;
    };
  } catch (e) {
    if (kDebugMode) print('[App] ❌ Error en init crítica: $e');
    try {
      await CrashlyticsService.recordError(e, StackTrace.current,
          reason: 'Error en inicialización de app');
    } catch (_) {}
  }

  // Arrancar la UI de inmediato para reducir riesgo de ANR en creación de superficie
  runApp(const AppState());

  // Inicialización diferida tras el primer frame (no bloquea nativeSurfaceCreated)
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _deferredInit();
  });
}

/// Servicios que no son críticos para el primer frame; se ejecutan después de pintar.
Future<void> _deferredInit() async {
  try {
    await NotificationService.initialize();
    await BackgroundUploadService.initialize();
    await RealBackgroundUploadService.initialize();
    ConnectivityListenerService().initialize();
    ErrorHandler.initialize();
    if (kDebugMode) print('[App] ✅ Servicios diferidos inicializados');
  } catch (e) {
    if (kDebugMode) print('[App] ❌ Error en init diferida: $e');
    try {
      await CrashlyticsService.recordError(e, StackTrace.current,
          reason: 'Error en inicialización diferida de app');
    } catch (_) {}
  }
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
      ChangeNotifierProvider(create: (_) => ThemeService()),
      ChangeNotifierProvider(create: (_) => LoadingProgressProvider()),
      Provider<DBProvider>(create: (_) => DBProvider.db),
    ], child: const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return OverlaySupport.global(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Qinspecting',
            theme: themeService.lightTheme,
            darkTheme: themeService.darkTheme,
            themeMode:
                themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            initialRoute: 'check_auth',
            routes: {
              'login': (_) => const LoginScreen(),
              'home': (_) => const HomeScreen(),
              'profile': (_) => const ProfileScreen(),
              'signature': (_) => const SignatureScreen(),
              'send_pending': (_) => const SendPendingInspectionScreen(),
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
              return MaterialPageRoute(
                  builder: (context) => const HomeScreen());
            },
            // Configurar builder para manejar errores y respetar áreas del sistema
            builder: (context, child) {
              return SafeArea(
                child: ErrorHandler.wrapWithErrorHandler(child!),
              );
            },
          ),
        );
      },
    );
  }
}
