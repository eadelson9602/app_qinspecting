import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/services/services.dart';
import '../providers/providers.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UiProvider>(context);
    final loginService = Provider.of<LoginService>(context, listen: false);
    return Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors
              .white, // set the Color of the drawer transparent; we'll paint above it with the shape
        ),
        child: Drawer(
            child: ListView(
          children: [
            Container(
              padding: EdgeInsets.only(left: 10, top: 15),
              child: Row(
                children: [
                  Image(
                    image: AssetImage('assets/images/logo.png'),
                    height: 40,
                  ),
                ],
              ),
            ),
            Divider(),
            ListTile(
              leading: const Icon(
                Icons.account_box,
                color: Colors.green,
              ),
              title: const Text(
                'Perfil',
                style: TextStyle(color: Colors.green),
              ),
              onTap: () => Navigator.popAndPushNamed(context, 'profile'),
            ),
            ListTile(
                leading: const Icon(Icons.home, color: Colors.green),
                title: const Text(
                  'Escritorio',
                  style: TextStyle(color: Colors.green),
                ),
                onTap: () {
                  uiProvider.selectedMenuOpt = 0;
                  Navigator.popAndPushNamed(context, 'home');
                }),
            // ListTile(
            //     leading: const Icon(Icons.fact_check, color: Colors.green),
            //     title: const Text(
            //       'Inspección',
            //       style: TextStyle(color: Colors.green),
            //     ),
            //     onTap: () {
            //       uiProvider.selectedMenuOpt = 1;
            //       Navigator.popAndPushNamed(context, 'home');
            //     }),
            ListTile(
              leading: Icon(Icons.send, color: Colors.green),
              title: Text('Enviar inspecciones',
                  style: TextStyle(color: Colors.green)),
              onTap: () =>
                  Navigator.popAndPushNamed(context, 'send_pending'),
            ),
            ListTile(
                leading: Icon(Icons.gesture, color: Colors.green),
                title: Text('Firma', style: TextStyle(color: Colors.green)),
                onTap: () =>
                    Navigator.popAndPushNamed(context, 'signature')),
            ListTile(
                leading: Icon(Icons.settings, color: Colors.green),
                title: Text('Configuración',
                    style: TextStyle(color: Colors.green)),
                onTap: () =>
                    Navigator.popAndPushNamed(context, 'settings')),
            ListTile(
                leading: Icon(Icons.logout, color: Colors.green),
                title: Text('Cerrar sesión',
                    style: TextStyle(color: Colors.green)),
                onTap: () {
                  loginService.logout();
                  Navigator.popAndPushNamed(context, 'login');
                })
          ],
        )));
  }
}
