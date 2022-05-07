import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

import 'screens/screens.dart';

import 'package:app_qinspecting/providers/providers.dart';

import 'services/services.dart';

void main() {
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
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
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
      },
      // Se usa para controlar pagina que no existes 404
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const HomeScreen());
      },
    ));
  }
}
