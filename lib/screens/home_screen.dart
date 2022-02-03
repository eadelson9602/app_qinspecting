import 'package:app_qinspecting/screens/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/screens/screens.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/widgets/widgets.dart';

class LoadHomeScreen extends StatelessWidget {
  const LoadHomeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final loginService = Provider.of<LoginService>(context, listen: false);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => InspeccionService(loginService.selectedEmpresa!)),
      ],
      child: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Al instanciar el servicio, hace la petición al servidor
    final inspeccionService = Provider.of<InspeccionService>(context);
    if (inspeccionService.isLoading) return const LoadingScreen();
    return Scaffold(
      appBar: const CustomAppBar().createAppBar(),
      drawer: const CustomDrawer(),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: _HomePageBody(),
        ),
      ),
      bottomNavigationBar: const CustomNavigationBar(),
    );
  }
}

class _HomePageBody extends StatelessWidget {
  const _HomePageBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UiProvider>(context);
    final currentIndex = uiProvider.selectedMenuOpt;

    final inspeccionService =
        Provider.of<InspeccionService>(context, listen: false);
    // Guarda los departamentos en SQLITE
    for (var departamento in inspeccionService.departamentos) {
      DBProvider.db
          .getDepartamentoById(departamento.value)
          .then((resultFindDepartamento) => {
                if (resultFindDepartamento?.value == null)
                  {DBProvider.db.nuevoDepartamento(departamento)}
              });
    }
    // Guarda las ciudades en SQLITE
    for (var ciudad in inspeccionService.ciudades) {
      DBProvider.db.getCiudadById(ciudad.value).then((resultFindCiudad) => {
            if (resultFindCiudad?.value == null)
              {DBProvider.db.nuevaCiudad(ciudad)}
          });
    }

    switch (currentIndex) {
      case 0:
        return const DesktopScreen();
      case 1:
        return const InspeccionForm();
      default:
        return const DesktopScreen();
    }
  }
}
