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
    final loginService = Provider.of<LoginService>(context, listen: false);
    final inspeccionService = Provider.of<InspeccionService>(context, listen: false);
    final sizeScreen = MediaQuery.of(context).size;
    final inspeccionProvider = Provider.of<InspeccionProvider>(context, listen: false);

    inspeccionService.clearData();
    inspeccionProvider.clearData();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 10,
        ),
        FutureBuilder(
          future: inspeccionService.getLatesInspections(loginService.selectedEmpresa),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: 355,
                child: Center(
                  child: CircularProgressIndicator()
                )
              );
            } else if (snapshot.data != false) {
              return Container(
                height: 355,
                child: Swiper(
                  layout: SwiperLayout.STACK,
                  itemHeight: sizeScreen.height * 1,
                  itemWidth: sizeScreen.height * 0.5,
                  itemBuilder: (BuildContext context, int i) {
                    return CardInspeccionDesktop(resumenPreoperacional: inspeccionService.listInspections[i]);
                  },
                  itemCount: inspeccionService.listInspections.length,
                ),
              );
            } else {
              return NoInternet();
            }
          }
        ),
      ],
    );
  }
}
