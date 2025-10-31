import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/screens/screens.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/ui/input_decorations.dart';
import 'package:app_qinspecting/ui/app_theme.dart';
import 'package:app_qinspecting/widgets/widgets.dart';

class RememberPasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final inspeccionService = Provider.of<InspeccionService>(context);
    if (inspeccionService.isLoading) return LoadingScreen();
    return Scaffold(
        body: AuthBackground(
      child: ChangeNotifierProvider(
        create: (_) => LoginFormProvider(),
        child: _FormLogin(),
      ),
    ));
  }
}

class _FormLogin extends StatelessWidget {
  const _FormLogin({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loginForm = Provider.of<LoginFormProvider>(context);
    final loginService = Provider.of<LoginService>(context, listen: false);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Form(
          key: loginForm.formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: () => loginForm.existUser = true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'Recuperar contraseña',
                style: TextStyle(
                    color: Theme.of(context).textTheme.headlineMedium?.color,
                    fontSize: 25,
                    fontWeight: FontWeight.w800),
              ),
              TextFormField(
                autocorrect: false,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Ingrese su usuario';
                  return null;
                },
                onChanged: (value) =>
                    value.isEmpty ? '' : loginForm.usuario = int.parse(value),
                decoration: InputDecorations.authInputDecorations(
                    hintText: '',
                    labelText: 'Usuario',
                    prefixIcon: Icons.person,
                    context: context),
              ),
              const _ButtonRememberAccount(),
              TextButton(
                  onPressed: () => loginService.pageController.previousPage(
                      duration: Duration(microseconds: 1000),
                      curve: Curves.bounceIn),
                  child: Text('Iniciar sesión',
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 16,
                          fontWeight: FontWeight.w800)))
            ],
          )),
    );
  }
}

class _ButtonRememberAccount extends StatelessWidget {
  const _ButtonRememberAccount({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loginForm = Provider.of<LoginFormProvider>(context);
    final loginService = Provider.of<LoginService>(context, listen: false);
    final inspeccionService =
        Provider.of<InspeccionService>(context, listen: false);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: loginForm.isLoading
            ? null
            : () async {
                if (!loginForm.isValidForm()) return;
                rememberAccount(
                    context, loginForm, loginService, inspeccionService);
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: AppTheme.primaryGreen.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          loginForm.isLoading ? 'Recuperando datos...' : 'Recuperar contraseña',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  void rememberAccount(BuildContext context, LoginFormProvider loginForm,
      LoginService loginService, InspeccionService inspeccionService) async {
    try {
      loginForm.isLoading = true;
      FocusScope.of(context).unfocus();
      bool isConnected = await inspeccionService.checkConnection();

      if (isConnected) {
        final result = await loginService.rememberData(loginForm.usuario);
        await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  contentPadding:
                      EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 12),
                  title: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green,
                          size: 28,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Correo enviado',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Text(
                        '${result['message'] ?? 'Operación realizada'}',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Si no ves el mensaje, revisa tu bandeja de correo no deseado (spam) o carpeta de promociones.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.blue.shade800,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        loginForm.formKey.currentState?.reset();
                        loginForm.usuario = 0;
                        Navigator.pop(context, true);
                      },
                      style: TextButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Aceptar',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ));
        loginService.pageController.previousPage(
            duration: Duration(microseconds: 1000), curve: Curves.bounceOut);
      } else {
        showSimpleNotification(
          Text('Debe tener conexión a internet'),
          leading: Icon(Icons.info),
          autoDismiss: true,
          background: Colors.orange,
          position: NotificationPosition.bottom,
        );
        return;
      }
    } on DioException catch (_) {
      showSimpleNotification(
        Text('Error al recuperar datos'),
        leading: Icon(Icons.check),
        autoDismiss: true,
        background: Colors.orange,
        position: NotificationPosition.bottom,
      );
    } finally {
      loginForm.isLoading = false;
    }
  }
}
