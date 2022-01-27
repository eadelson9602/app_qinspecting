import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/ui/input_decorations.dart';

import 'package:app_qinspecting/providers/providers.dart';

import 'package:app_qinspecting/services/services.dart';

import 'package:app_qinspecting/widgets/widgets.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _sizeScreen = MediaQuery.of(context).size;
    return Scaffold(
      body: AuthBackground(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: _sizeScreen.height * 0.30,
              ),
              const Text(
                'Iniciar Sesión',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.w800),
              ),
              const SizedBox(
                height: 20,
              ),
              ChangeNotifierProvider(
                create: (_) => LoginFormProvider(),
                child: const _FormLogin(),
              ),
              const SizedBox(
                height: 50,
              ),
              const Text(
                'Recuperar contraseña',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(
                height: _sizeScreen.height * 0.10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: const Image(
                          image: AssetImage('assets/icons/facebook.png'))),
                  IconButton(
                      onPressed: () {},
                      icon: const Image(
                          image: AssetImage('assets/icons/instagram.png'))),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _FormLogin extends StatelessWidget {
  const _FormLogin({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loginForm = Provider.of<LoginFormProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Form(
          key: loginForm.formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
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
                    hintText: '1121947539',
                    labelText: 'Usuario',
                    prefixIcon: Icons.person),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                autocorrect: false,
                obscureText: true,
                keyboardType: TextInputType.text,
                onChanged: (value) => loginForm.password = value,
                validator: (value) {
                  if (value!.isEmpty) return 'Ingrese su contraseña';
                  return null;
                },
                decoration: InputDecorations.authInputDecorations(
                    hintText: '******',
                    labelText: 'Contraseña',
                    prefixIcon: Icons.lock_outline_sharp),
              ),
              const SizedBox(
                height: 50,
              ),
              const ButtonLogin()
            ],
          )),
    );
  }
}

class ButtonLogin extends StatelessWidget {
  const ButtonLogin({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loginForm = Provider.of<LoginFormProvider>(context);
    return MaterialButton(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      disabledColor: Colors.green,
      minWidth: 300,
      child: TextButtonLogin(loginForm: loginForm),
      onPressed: loginForm.isLoading
          ? null
          : () async {
              FocusScope.of(context).unfocus();

              final loginService =
                  Provider.of<LoginService>(context, listen: false);

              if (!loginForm.isValidForm()) return;
              loginForm.isLoading = true;

              final empresas = await loginService.login(
                  loginForm.usuario, loginForm.password);

              showModalBottomSheet(
                  isScrollControlled: false,
                  shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20))),
                  context: context,
                  builder: (context) => Container(
                      padding: const EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.usb_rounded),
                              title: const Text('Empresa 1'),
                              trailing: const Icon(Icons.arrow_right_sharp),
                              onTap: () {
                                Navigator.popAndPushNamed(context, 'home');
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.usb_rounded),
                              title: const Text('Empresa 1'),
                              trailing: const Icon(Icons.arrow_right_sharp),
                              onTap: () {
                                Navigator.popAndPushNamed(context, 'home');
                              },
                            ),
                          ],
                        ),
                      )));
            },
    );
  }
}

class TextButtonLogin extends StatelessWidget {
  const TextButtonLogin({
    Key? key,
    required this.loginForm,
  }) : super(key: key);

  final LoginFormProvider loginForm;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: AlignmentGeometry.lerp(Alignment.center, Alignment.center, 15),
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Text(
        loginForm.isLoading ? 'Iniciando sesión...' : 'Iniciar sesión',
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: const LinearGradient(colors: [
            Color.fromRGBO(31, 133, 53, 1),
            Color.fromRGBO(103, 210, 0, 1)
          ])),
    );
  }
}
