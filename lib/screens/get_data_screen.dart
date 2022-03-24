import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/screens/screens.dart';
import 'package:app_qinspecting/services/services.dart';

class GetDataScreen extends StatelessWidget {
  const GetDataScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inspeccionService =
        Provider.of<InspeccionService>(context, listen: false);
    final loginService = Provider.of<LoginService>(context, listen: false);
    return Scaffold(
        body: FutureBuilder(
            future: inspeccionService.getData(loginService.selectedEmpresa),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return LoadHomeScreen();
              } else {
                Future.microtask(() {
                  Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                          pageBuilder: (_, __, ___) => HomeScreen(),
                          transitionDuration: Duration(seconds: 0)));
                });
                return Container();
              }
            }));
  }
}
