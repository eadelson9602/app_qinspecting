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
                leading: const Icon(Icons.fact_check, color: Colors.green),
                title: const Text(
                  'Inspección',
                  style: TextStyle(color: Colors.green),
                ),
                onTap: () => Navigator.popAndPushNamed(context, 'inspeccion')),
            const ListTile(
              leading: Icon(Icons.send, color: Colors.green),
              title: Text('Enviar inspecciones',
                  style: TextStyle(color: Colors.green)),
            ),
            ListTile(
                leading: Icon(Icons.gesture, color: Colors.green),
                title: Text('Firma', style: TextStyle(color: Colors.green)),
                onTap: () => Navigator.popAndPushNamed(context, 'signature')),
            const ListTile(
              leading: Icon(Icons.settings, color: Colors.green),
              title:
                  Text('Configuración', style: TextStyle(color: Colors.green)),
            ),
          ],
        )));
  }
}
