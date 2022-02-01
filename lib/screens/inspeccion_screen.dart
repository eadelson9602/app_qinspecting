import 'package:flutter/material.dart';

// import 'package:app_qinspecting/screens/screens.dart';
// const InspeccionForm()
import 'package:app_qinspecting/widgets/widgets.dart';

class ScaffoldInspeccionScreen extends StatelessWidget {
  const ScaffoldInspeccionScreen({Key? key}) : super(key: key);

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
