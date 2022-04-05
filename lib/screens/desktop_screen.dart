import 'package:card_swiper/card_swiper.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

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
    return FutureBuilder(
      future: Connectivity().checkConnectivity(),
      builder: (context, snapshot) {
        if (snapshot.data == ConnectivityResult.mobile ||
            snapshot.data == ConnectivityResult.wifi) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 10,
              ),
              // DateRange(loginService, inspeccionService, sizeScreen),
              // SizedBox(
              //   height: 15,
              // ),
              Text(
                'Inspecciones realizadas',
                style: TextStyle(fontSize: 18),
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
                        height: sizeScreen.height * 0.5,
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

  Form DateRange(LoginService loginService, InspeccionService inspeccionService,
      sizeScreen) {
    return Form(
      child: Column(
        children: [
          ElevatedButton(
            child: Container(
              width: 200,
              child: Row(
                children: [
                  Icon(Icons.calendar_today),
                  SizedBox(
                    width: 5,
                  ),
                  Text('Filtrar por rango de fecha')
                ],
              ),
            ),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return Scaffold(
                      appBar: AppBar(),
                      body: SfDateRangePicker(
                        enablePastDates: true,
                        view: DateRangePickerView.month,
                        selectionMode: DateRangePickerSelectionMode.range,
                        monthViewSettings:
                            DateRangePickerMonthViewSettings(firstDayOfWeek: 1),
                        showActionButtons: true,
                        cancelText: 'Cancelar',
                        confirmText: 'Buscar',
                        onCancel: () => Navigator.pop(context),
                        onSubmit: (val) async {
                          PickerDateRange date = val as PickerDateRange;
                          final initialDate =
                              date.startDate.toString().split(' ')[0];
                          final endDate = date.endDate.toString().split(' ')[0];

                          await inspeccionService.getRangeInspections(
                              loginService.selectedEmpresa,
                              initialDate,
                              endDate);

                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
