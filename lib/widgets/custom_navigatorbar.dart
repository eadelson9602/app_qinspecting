import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/ui/input_decorations.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/providers/providers.dart';

class CustomNavigationBar extends StatelessWidget {
  const CustomNavigationBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UiProvider>(context);
    final currentIdex = uiProvider.selectedMenuOpt;
    final inspeccionProvider = Provider.of<InspeccionProvider>(context);
    final loginService = Provider.of<LoginService>(context);
    String passwordVerify = '';
    String messageError = '';

    Future<void> _showMyDialog() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return ChangeNotifierProvider(
            create: (_) => InspeccionProvider(),
            child: AlertDialog(
              title: const Text(
                'Verificación de indentidad',
                style: TextStyle(),
                textAlign: TextAlign.center,
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    const Text(
                      'Por favor ingrese su contraseña ',
                      style: TextStyle(),
                      textAlign: TextAlign.center,
                    ),
                    TextFormField(
                      autocorrect: false,
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == '') return 'Ingrese contraseña';
                        return null;
                      },
                      onChanged: (value) {
                        passwordVerify = value;
                      },
                      decoration: InputDecorations.authInputDecorations(
                          hintText: '',
                          labelText: 'Contraseña',
                          prefixIcon: Icons.lock),
                    ),
                    if (inspeccionProvider.isValidPassword == false)
                      Text(
                        messageError,
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Validar'),
                  onPressed: () {
                    print(inspeccionProvider.isValidPassword);
                    if (passwordVerify == '') {
                      messageError = 'Por favor ingrese su contraseña';
                      inspeccionProvider.updateIsValidPassword(false);
                      return;
                    } else if (passwordVerify ==
                        loginService.userDataLogged.usuarioContra) {
                      Navigator.of(context).pop();
                    } else {
                      messageError = 'La contraseña es erronea';
                      inspeccionProvider.updateIsValidPassword(false);
                    }
                  },
                ),
              ],
            ),
          );
        },
      );
    }

    return BottomNavigationBar(
      currentIndex: currentIdex,
      onTap: (int i) {
        uiProvider.selectedMenuOpt = i;
        if (i == 1) {
          _showMyDialog();
        }
      },
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Escritorio'),
        BottomNavigationBarItem(
            icon: Icon(Icons.app_registration_sharp), label: 'Inspecciones'),
      ],
    );
  }
}
