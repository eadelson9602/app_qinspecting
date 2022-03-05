import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/ui/input_decorations.dart';
import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/widgets/widgets.dart';

class AlertDialogValidate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UiProvider>(context);
    if (uiProvider.selectedMenuOpt == 1) return _AlertDialog();
    return Scaffold(
      appBar: const CustomAppBar().createAppBar(),
      drawer: const CustomDrawer(),
      body: _AlertDialog(),
    );
  }
}

class _AlertDialog extends StatelessWidget {
  const _AlertDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String inputPassword = '';
    final loginService = Provider.of<LoginService>(context);

    return AlertDialog(
      title: Text(
        'Verificación de identidad',
        style: TextStyle(),
        textAlign: TextAlign.center,
      ),
      content: Stack(
        children: [
          Positioned(
            right: -40.0,
            top: -40.0,
            child: InkResponse(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: CircleAvatar(
                child: Icon(Icons.close),
                backgroundColor: Colors.red,
              ),
            ),
          ),
          Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  autocorrect: false,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return 'Ingrese su contraseña';
                    return null;
                  },
                  onChanged: (value) {
                    inputPassword = value;
                  },
                  decoration: InputDecorations.authInputDecorations(
                      hintText: '',
                      labelText: 'Contraseña',
                      prefixIcon: Icons.lock),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    child: Text("Verificar"),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (inputPassword ==
                            loginService.userDataLogged.usuarioContra) {
                          Navigator.popAndPushNamed(context, 'inspeccion');
                        } else {
                          print('ELSe');
                          showSimpleNotification(Text('Contraseña erronea'),
                              leading: Icon(Icons.error),
                              autoDismiss: true,
                              background: Colors.red,
                              position: NotificationPosition.top);
                        }
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
