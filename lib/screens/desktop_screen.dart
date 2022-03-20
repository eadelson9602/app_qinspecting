import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/widgets/widgets.dart';

class DesktopScreen extends StatelessWidget {
  const DesktopScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loginService = Provider.of<LoginService>(context);
    final inspeccionService = Provider.of<InspeccionService>(context);
    return FutureBuilder(
      future: Connectivity().checkConnectivity(),
      builder: (context, snapshot) {
        if (snapshot.data == ConnectivityResult.mobile ||
            snapshot.data == ConnectivityResult.wifi) {
          return Container(
              height: double.infinity,
              child: FutureBuilder(
                  future: inspeccionService
                      .getLatesInspections(loginService.selectedEmpresa),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      List data = snapshot.data as List;
                      return ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (_, int i) {
                            return CardInspeccionDesktop(
                                resumenPreoperacional: data[i]);
                          });
                    }
                  }));
        } else {
          return NoInternet();
        }
      },
    );
  }
}
