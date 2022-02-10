import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/providers/providers.dart';

class ItemInspeccion extends StatelessWidget {
  const ItemInspeccion({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inspeccionProvider = Provider.of<InspeccionProvider>(context);
    // inspeccionProvider.itemsInspeccion.length;
    return Stepper(
      currentStep: inspeccionProvider.stepStepper,
      onStepCancel: () {
        if (inspeccionProvider.stepStepper > 0) {
          inspeccionProvider.stepStepper -= 1;
        }
      },
      onStepContinue: () {
        if (inspeccionProvider.stepStepper <= 0) {
          inspeccionProvider.stepStepper += 1;
        }
      },
      onStepTapped: (int index) {
        inspeccionProvider.stepStepper = index;
      },
      steps: [
        Step(
          title: const Text('Step 1 title'),
          content: Container(
              alignment: Alignment.centerLeft,
              child: const Text('Content for Step 1')),
        ),
        const Step(
          title: Text('Step 2 title'),
          content: Text('Content for Step 2'),
        ),
      ],
    );
    ;
  }
}
