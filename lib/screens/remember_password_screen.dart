import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/models/models.dart';
import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/screens/screens.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/ui/input_decorations.dart';
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
                    color: Colors.black,
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
                    prefixIcon: Icons.person),
              ),
              const _ButtonRememberAccount(),
              TextButton(
                  onPressed: () => loginService.pageController.previousPage(
                      duration: Duration(microseconds: 1000),
                      curve: Curves.bounceIn),
                  child: Text('Iniciar sesión',
                      style: TextStyle(
                          color: Colors.black,
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

    return MaterialButton(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      minWidth: 300,
      child: CustomStyleButton(
          text: loginForm.isLoading
              ? 'Recuperando datos...'
              : 'Recuperar contraseña'),
      onPressed: loginForm.isLoading
          ? null
          : () async {
              if (!loginForm.isValidForm()) return;
              rememberAccount(
                  context, loginForm, loginService, inspeccionService);
            },
    );
  }

  void rememberAccount(BuildContext context, LoginFormProvider loginForm,
      LoginService loginService, InspeccionService inspeccionService) async {
    try {
      loginForm.isLoading = true;
      FocusScope.of(context).unfocus();
      List<Empresa> empresas = [];
      bool isConnected = await inspeccionService.checkConnection();

      if (isConnected) {
        final tempEmpresas = await loginService.rememberData(loginForm.usuario);
        if (tempEmpresas.isNotEmpty) {
          tempEmpresas.forEach((element) => empresas.add(element));
        } else {
          showSimpleNotification(
            Text('Sin resultados'),
            leading: Icon(Icons.info),
            autoDismiss: true,
            background: Colors.orange,
            position: NotificationPosition.bottom,
          );
          return;
        }

        showModalBottomSheet(
            isScrollControlled: false,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            context: context,
            builder: (context) => Container(
                  height: empresas.length > 2 ? 250 : 150,
                  padding: const EdgeInsets.all(20),
                  child: ListView.builder(
                    itemCount: empresas.length,
                    itemBuilder: (_, int i) => ListTile(
                      leading: Container(
                          width: 50,
                          height: 50,
                          child: loginForm
                              .getImage(empresas[i].rutaLogo.toString())),
                      title: Text(empresas[i].nombreQi.toString()),
                      trailing: const Icon(Icons.arrow_right),
                      onTap: () async {
                        final resSendEmail = await loginService
                            .sendEmailRememberData(empresas[i]);
                        await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: Icon(
                                    Icons.warning,
                                    color: Colors.orange,
                                  ),
                                  content: Text(
                                      '${resSendEmail['message']} con los datos de tu cuenta',
                                      textAlign: TextAlign.center),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: Text('Comprendo',
                                            style: TextStyle(
                                                color: Colors.green))),
                                  ],
                                ));
                        Navigator.pop(context);
                        loginService.pageController.previousPage(
                            duration: Duration(microseconds: 1000),
                            curve: Curves.bounceOut);
                      },
                    ),
                  ),
                ));
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
