import 'package:flutter/material.dart';
import 'package:app_qinspecting/widgets/widgets.dart';
import 'package:app_qinspecting/ui/app_theme.dart';

class InspeccionScreen extends StatelessWidget {
  const InspeccionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      body: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom -
                100,
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 50, 20, 0),
            child: Text('Inspección'),
          ),
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
