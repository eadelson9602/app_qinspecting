import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// flujo embebido: no usamos image_picker/permission_handler aquí

import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/screens/screens.dart';
import 'package:app_qinspecting/widgets/widgets.dart';

class ItemsInspeccionarRemolque extends StatefulWidget {
  ItemsInspeccionarRemolque({Key? key}) : super(key: key);

  @override
  State<ItemsInspeccionarRemolque> createState() =>
      _ItemsInspeccionarStateRemolque();
}

class _ItemsInspeccionarStateRemolque extends State<ItemsInspeccionarRemolque> {
  @override
  Widget build(BuildContext context) {
    final inspeccionProvider = Provider.of<InspeccionProvider>(context);
    final itemsInspeccionar = inspeccionProvider.itemsInspeccionRemolque;
    List<Step> _renderSteps() {
      List<Step> stepsInspeccion = [];
      for (int i = 0; i < itemsInspeccionar.length; i++) {
        stepsInspeccion.add(Step(
            isActive:
                inspeccionProvider.stepStepperRemolque >= i ? true : false,
            title: Text(itemsInspeccionar[i].categoria),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MaterialButton(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)),
                    child: TextButtonPersonalized(
                      textButton: 'Todo ok',
                      iconButton: Icons.check,
                    ),
                    onPressed: () {
                      setState(() {
                        // Revalidar límites por si la lista cambió
                        final currentList =
                            inspeccionProvider.itemsInspeccionRemolque;
                        if (i < 0 || i >= currentList.length) return;
                        for (var item in currentList[i].items) {
                          item.respuesta = 'B';
                        }
                        if (inspeccionProvider.stepStepperRemolque <
                                currentList.length &&
                            currentList.length -
                                    inspeccionProvider.stepStepperRemolque !=
                                1) {
                          inspeccionProvider.updateStepRemolque(
                              inspeccionProvider.stepStepperRemolque += 1);
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
                                onImageCaptured: (path) {
                                  setState(() {
                                    item.adjunto = path;
                                  });
                                },
                              ),
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
    final safeCurrentStep = itemsInspeccionar.isEmpty
        ? 0
        : inspeccionProvider.stepStepperRemolque
            .clamp(0, itemsInspeccionar.length - 1);
    return Stepper(
      margin: EdgeInsets.only(left: 55, bottom: 40),
      currentStep: safeCurrentStep,
      controlsBuilder: (context, details) {
        return Row(
          children: [
            if (inspeccionProvider.stepStepperRemolque > 0)
              MaterialButton(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100)),
                onPressed: details.onStepCancel,
                child: Container(
                  child: Row(
                    children: [
                      Text(
                        'Regresar',
                        style: TextStyle(color: Colors.red, fontSize: 18),
                      )
                    ],
                  ),
                ),
              ),
            if (inspeccionProvider.stepStepperRemolque !=
                itemsInspeccionar.length - 1)
              MaterialButton(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                  child: TextButtonPersonalized(
                    textButton: 'Continuar',
                  ),
                  onPressed: inspeccionProvider.stepStepperRemolque ==
                          itemsInspeccionar.length
                      ? null
                      : details.onStepContinue),
          ],
        );
      },
      onStepCancel: () {
        if (inspeccionProvider.stepStepperRemolque > 0) {
          inspeccionProvider
              .updateStepRemolque(inspeccionProvider.stepStepperRemolque -= 1);
        }
      },
      onStepContinue: () {
        if (inspeccionProvider.stepStepperRemolque !=
            itemsInspeccionar.length - 1) {
          inspeccionProvider
              .updateStepRemolque(inspeccionProvider.stepStepperRemolque += 1);
        }
      },
      onStepTapped: (int index) {
        final boundedIndex = index.clamp(0, itemsInspeccionar.length - 1);
        inspeccionProvider.updateStepRemolque(boundedIndex);
      },
      steps: _renderSteps(),
    );
  }
}
