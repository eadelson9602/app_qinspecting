import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/screens/screens.dart';
import 'package:app_qinspecting/widgets/widgets.dart';

class ItemsInspeccionarVehiculo extends StatefulWidget {
  ItemsInspeccionarVehiculo({Key? key}) : super(key: key);

  @override
  State<ItemsInspeccionarVehiculo> createState() =>
      _ItemsInspeccionarStateVehiculo();
}

class _ItemsInspeccionarStateVehiculo extends State<ItemsInspeccionarVehiculo> {
  @override
  Widget build(BuildContext context) {
    final inspeccionProvider = Provider.of<InspeccionProvider>(context);
    final itemsInspeccionar = inspeccionProvider.itemsInspeccion;
    List<Step> _renderSteps() {
      List<Step> stepsInspeccion = [];
      for (int i = 0; i < itemsInspeccionar.length; i++) {
        stepsInspeccion.add(Step(
            isActive: inspeccionProvider.stepStepper >= i ? true : false,
            title: Text(itemsInspeccionar[i].categoria),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MaterialButton(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)),
                    child: TextButtonAllok(),
                    onPressed: () {
                      setState(() {
                        for (var item in itemsInspeccionar[i].items) {
                          item.respuesta = 'B';
                        }
                        if (inspeccionProvider.stepStepper <
                                itemsInspeccionar.length &&
                            itemsInspeccionar.length -
                                    inspeccionProvider.stepStepper !=
                                1) {
                          inspeccionProvider
                              .updateStep(inspeccionProvider.stepStepper += 1);
                        }
                      });
                    }),
                SizedBox(height: 20),
                for (var item in itemsInspeccionar[i].items)
                  Column(
                    children: [
                      Container(
                          width: double.infinity,
                          child: Text(
                            item.item,
                            textAlign: TextAlign.start,
                            maxLines: 2,
                          )),
                      Row(
                        children: [
                          Radio(
                            activeColor: Colors.green,
                            groupValue: item.respuesta,
                            value: 'B',
                            onChanged: (value) {
                              setState(() {
                                item.respuesta = value.toString();
                              });
                            },
                          ),
                          Text(
                            'Cumple',
                            style: TextStyle(color: Colors.green),
                          ),
                          Radio(
                            activeColor: Colors.red,
                            groupValue: item.respuesta,
                            value: 'M',
                            onChanged: (value) {
                              setState(() {
                                item.respuesta = value.toString();
                              });
                            },
                          ),
                          Text(
                            'No cumple',
                            style: TextStyle(color: Colors.red),
                          ),
                          Radio(
                            activeColor: Colors.orange,
                            groupValue: item.respuesta,
                            value: 'N/A',
                            onChanged: (value) {
                              setState(() {
                                item.respuesta = value.toString();
                              });
                            },
                          ),
                          Text(
                            'N/A',
                            style: TextStyle(color: Colors.orange),
                          ),
                        ],
                      ),
                      SizedBox(height: 11),
                      if (item.respuesta == 'M')
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.only(right: 20, left: 15),
                          child: TextField(
                            maxLines: 8,
                            decoration: InputDecoration(
                                hintText: "Observaciones",
                                filled: true,
                                contentPadding: EdgeInsets.all(10.0),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always),
                            onChanged: (value) {
                              item.observaciones = value;
                            },
                          ),
                        ),
                      SizedBox(height: 11),
                      if (item.respuesta == 'M')
                        Container(
                          width: 270,
                          child: Stack(
                            children: [
                              BoardImage(
                                url: item.adjunto,
                              ),
                              Positioned(
                                  right: 15,
                                  bottom: 10,
                                  child: IconButton(
                                    onPressed: () async {
                                      final _picker = ImagePicker();
                                      final XFile? photo =
                                          await _picker.pickImage(
                                              source: ImageSource.camera);

                                      if (photo == null) {
                                        return;
                                      }
                                      setState(() {
                                        // Se asigna la imagen en un provider para esta sección
                                        item.adjunto = photo.path;
                                      });
                                    },
                                    icon: Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 45,
                                    ),
                                  ))
                            ],
                          ),
                        ),
                      SizedBox(height: 11),
                    ],
                  ),
              ],
            )));
      }
      return stepsInspeccion;
    }

    if (itemsInspeccionar.isEmpty) return const LoadingScreen();
    return Stepper(
      margin: EdgeInsets.only(left: 55, bottom: 40),
      currentStep: inspeccionProvider.stepStepper,
      onStepCancel: () {
        if (inspeccionProvider.stepStepper > 0) {
          inspeccionProvider.updateStep(inspeccionProvider.stepStepper -= 1);
        }
      },
      onStepContinue: () {
        if (inspeccionProvider.stepStepper < itemsInspeccionar.length) {
          inspeccionProvider.updateStep(inspeccionProvider.stepStepper += 1);
        }
      },
      onStepTapped: (int index) {
        inspeccionProvider.updateStep(index);
      },
      steps: _renderSteps(),
    );
  }
}
