import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:date_range_form_field/date_range_form_field.dart';
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
    final sizeScreen = MediaQuery.of(context).size;
    return FutureBuilder(
      future: Connectivity().checkConnectivity(),
      builder: (context, snapshot) {
        if (snapshot.data == ConnectivityResult.mobile ||
            snapshot.data == ConnectivityResult.wifi) {
          return ListView(
              physics:
                  NeverScrollableScrollPhysics(), // <-- this will disable scroll
              shrinkWrap: true,
              children: [
                DateRange(inspeccionService, sizeScreen),
                FutureBuilder(
                    future: inspeccionService
                        .getLatesInspections(loginService.selectedEmpresa),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        List data = snapshot.data as List;
                        return Container(
                          height: sizeScreen.height * 1,
                          child: ListView.builder(
                              itemCount: data.length,
                              itemBuilder: (_, int i) {
                                return CardInspeccionDesktop(
                                    resumenPreoperacional: data[i]);
                              }),
                        );
                      }
                    })
              ]);
        } else {
          return NoInternet();
        }
      },
    );
  }

  Form DateRange(InspeccionService inspeccionService, sizeScreen) {
    return Form(
      key: inspeccionService.formKey,
      child: Column(
        children: [
          DateRangeField(
              width: sizeScreen.width * 1,
              enabled: true,
              margin: EdgeInsets.only(bottom: 0, top: 20),
              decoration: InputDecoration(
                labelText: 'Rango de fecha',
                prefixIcon: Icon(Icons.date_range),
                hintText: '--/--/-- --/--/--',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null) {
                  return 'Seleccione un rango de fecha';
                }
                return null;
              },
              onChanged: (DateTimeRange? value) {
                inspeccionService.updateDate(value!);
              },
              onSaved: (DateTimeRange? value) {
                inspeccionService.updateDate(value!);
              }),
          ElevatedButton(
            child: Container(
              width: 70,
              child: Row(
                children: [Icon(Icons.search), Text('Buscar')],
              ),
            ),
            onPressed: () {
              if (!inspeccionService.isValidForm()) return;
              print(inspeccionService.myDateRange.toString().split(' '));
            },
          ),
        ],
      ),
    );
  }
}
