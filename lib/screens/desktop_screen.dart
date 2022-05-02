import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/widgets/widgets.dart';

class DesktopScreen extends StatefulWidget {
  const DesktopScreen({Key? key}) : super(key: key);

  @override
  State<DesktopScreen> createState() => _DesktopScreenState();
}

class _DesktopScreenState extends State<DesktopScreen> {
  @override
  Widget build(BuildContext context) {
    final loginService = Provider.of<LoginService>(context);
    final inspeccionService = Provider.of<InspeccionService>(context);
    final sizeScreen = MediaQuery.of(context).size;
    final inspeccionProvider =
        Provider.of<InspeccionProvider>(context, listen: false);

    inspeccionService.resumePreoperacional.ciuId = 0;
    inspeccionService.resumePreoperacional.resuPreKilometraje = 0;
    inspeccionService.resumePreoperacional.vehId = 0;
    inspeccionProvider.vehiculoSelected = null;
    inspeccionProvider.remolqueSelected = null;
    inspeccionProvider.pathFileKilometraje = null;
    inspeccionProvider.stepStepperRemolque = 0;
    inspeccionProvider.stepStepper = 0;
    inspeccionProvider.pathFileGuia = null;
    inspeccionProvider.realizoTanqueo = false;
    inspeccionProvider.tieneRemolque = false;
    inspeccionProvider.tieneGuia = false;
    inspeccionProvider.itemsInspeccion.clear();
    inspeccionProvider.itemsInspeccionRemolque.clear();

    return FutureBuilder(
      future: inspeccionService.checkConnection(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.data == true) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 10,
              ),
              FutureBuilder(
                  future: inspeccionService
                      .getLatesInspections(loginService.selectedEmpresa),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      List data = snapshot.data as List;
                      return Container(
                        height: sizeScreen.height * 0.446,
                        child: Swiper(
                          layout: SwiperLayout.STACK,
                          itemHeight: sizeScreen.height * 0.9,
                          itemWidth: sizeScreen.height * 0.5,
                          itemBuilder: (BuildContext context, int i) {
                            return CardInspeccionDesktop(
                                resumenPreoperacional: data[i]);
                          },
                          itemCount: data.length,
                        ),
                      );
                    }
                  }),
            ],
          );
        } else {
          return NoInternet();
        }
      },
    );
  }
}
