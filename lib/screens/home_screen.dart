import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/screens/screens.dart';
import 'package:app_qinspecting/widgets/widgets.dart';

class LoadHomeScreen extends StatelessWidget {
  const LoadHomeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UiProvider>(context);
    final inspeccionProvider =
        Provider.of<InspeccionProvider>(context, listen: false);

    List<Widget> _widgetOptions = [
      DesktopScreen(),
      FutureBuilder(
          future: inspeccionProvider.listarDataInit(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingScreen();
            } else {
              return InspeccionForm();
            }
          })
    ];

    return Scaffold(
      appBar: const CustomAppBar().createAppBar(context),
      drawer: const CustomDrawer(),
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: _widgetOptions.elementAt(uiProvider.selectedMenuOpt),
      )),
      bottomNavigationBar: CustomNavigationBar(),
    );
  }
}
