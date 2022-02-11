import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/providers/providers.dart';

class ItemsInspeccionar extends StatelessWidget {
  const ItemsInspeccionar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inspeccionProvider = Provider.of<InspeccionProvider>(context);
    return Scaffold(
      body: Container(
          child: Stepper(
        margin: EdgeInsets.only(left: 55),
        elevation: 10,
        currentStep: inspeccionProvider.stepStepper,
        onStepCancel: () {
          if (inspeccionProvider.stepStepper > 0) {
            inspeccionProvider.updateStep(inspeccionProvider.stepStepper -= 1);
          }
        },
        onStepContinue: () {
          if (inspeccionProvider.stepStepper <
              inspeccionProvider.steps.length) {
            inspeccionProvider.updateStep(inspeccionProvider.stepStepper += 1);
          }
        },
        onStepTapped: (int index) {
          inspeccionProvider.updateStep(index);
        },
        steps: inspeccionProvider.steps,
      )),
    );
  }
}
