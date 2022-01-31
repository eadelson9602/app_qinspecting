import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors
              .white, // set the Color of the drawer transparent; we'll paint above it with the shape
        ),
        child: Drawer(
            child: ListView(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Perfil'),
              onTap: () => Navigator.popAndPushNamed(context, 'profile'),
            ),
            const ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Documentos'),
            ),
            const ListTile(
              leading: Icon(Icons.settings),
              title: Text('Configuración'),
            ),
          ],
        )));
  }
}
