import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/screens/screens.dart';

import 'package:app_qinspecting/widgets/widgets.dart';

import 'package:app_qinspecting/providers/providers.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar().createAppBar(),
      drawer: const CustomDrawer(),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: _HomePageBody(),
        ),
      ),
      bottomNavigationBar: const CustomNavigationBar(),
    );
  }
}

class _HomePageBody extends StatelessWidget {
  const _HomePageBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UiProvider>(context);
    final currentIndex = uiProvider.selectedMenuOpt;

    switch (currentIndex) {
      case 0:
        return const DesktopScreen();
      case 1:
        return const InspeccionForm();
      default:
        return const DesktopScreen();
    }
  }
}
