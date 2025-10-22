import 'package:flutter/material.dart';

import 'package:app_qinspecting/screens/screens.dart';
import 'package:app_qinspecting/widgets/widgets.dart';
import 'package:app_qinspecting/ui/app_theme.dart';

class InspeccionScreen extends StatelessWidget {
  const InspeccionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              20, 50, 20, 0), // Reducido el espacio superior
          child: InspeccionForm(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 2, // Reducida la sombra
        child: const Icon(
          Icons.menu_rounded,
          size: 24, // Icono más pequeño
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
    );
  }
}
