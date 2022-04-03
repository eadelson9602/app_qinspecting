import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:date_range_form_field/date_range_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/widgets/widgets.dart';

class DesktopScreen extends StatefulWidget {
  const DesktopScreen({Key? key}) : super(key: key);

  @override
  State<DesktopScreen> createState() => _DesktopScreenState();
}

class _DesktopScreenState extends State<DesktopScreen> {
  GlobalKey<FormState> myFormKey = new GlobalKey();
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
              DateRange(inspeccionService, sizeScreen),
              SizedBox(
                height: 15,
              ),
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
                        height: 350,
                        child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: data.length,
                            itemBuilder: (_, int i) => CardInspeccionDesktop(
                                resumenPreoperacional: data[i])),
                      );
                    }
                  }),
              // Text(
              //   'Demo Headline 2',
              //   style: TextStyle(fontSize: 18),
              // ),
              // Expanded(
              //   child: ListView.builder(
              //     shrinkWrap: true,
              //     itemBuilder: (ctx, int) {
              //       return Card(
              //         child: ListTile(
              //             title: Text('Motivation $int'),
              //             subtitle:
              //                 Text('this is a description of the motivation')),
              //       );
              //     },
              //   ),
              // ),
            ],
          );
        } else {
          return NoInternet();
        }
      },
    );
  }

  Form DateRange(InspeccionService inspeccionService, sizeScreen) {
    return Form(
      key: myFormKey,
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
              bool isValidForm() {
                return myFormKey.currentState?.validate() ?? false;
              }

              if (!isValidForm()) return;
            },
          ),
        ],
      ),
    );
  }
}
