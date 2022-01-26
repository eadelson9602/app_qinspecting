import 'package:app_qinspecting/ui/input_decorations.dart';
import 'package:flutter/material.dart';

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
                height: _sizeScreen.height * 0.25,
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
              const _FormLogin(),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Form(
          child: Column(
        children: [
          TextFormField(
            autocorrect: false,
            keyboardType: TextInputType.number,
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
            decoration: InputDecorations.authInputDecorations(
                hintText: '******',
                labelText: 'Usuario',
                prefixIcon: Icons.lock_outline_sharp),
          ),
          const SizedBox(
            height: 50,
          ),
          MaterialButton(
              elevation: 3,
              onPressed: () {
                Navigator.popAndPushNamed(context, 'home');
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100)),
              disabledColor: Colors.green,
              minWidth: 300,
              child: Container(
                width: double.infinity,
                alignment: AlignmentGeometry.lerp(
                    Alignment.center, Alignment.center, 15),
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: const Text(
                  'Iniciar Sesión',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    gradient: const LinearGradient(colors: [
                      Color.fromRGBO(31, 133, 53, 1),
                      Color.fromRGBO(103, 210, 0, 1)
                    ])),
              ))
        ],
      )),
    );
  }
}
