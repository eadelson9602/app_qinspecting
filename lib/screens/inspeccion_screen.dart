import 'package:flutter/material.dart';

import 'package:app_qinspecting/screens/screens.dart';
import 'package:app_qinspecting/widgets/widgets.dart';

class InspeccionScreen extends StatelessWidget {
  const InspeccionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: CustomDrawer(),
      body: InspeccionForm(),
    );
  }
}
