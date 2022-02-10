import 'package:flutter/material.dart';

import 'package:app_qinspecting/widgets/widgets.dart';

class SendPendingInspectionScree extends StatelessWidget {
  const SendPendingInspectionScree({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar().createAppBar(),
      drawer: const CustomDrawer(),
      body: Container(
        child: Text('Inspección Form'),
      ),
    );
  }
}
