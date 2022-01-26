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
      appBar: AppBar(
        title: const Text('Qinspecting'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications))
        ],
      ),
      drawer: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors
                .green, // set the Color of the drawer transparent; we'll paint above it with the shape
          ),
          child: const CustomDrawer()),
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
        return const InspectionScreen();
      default:
        return const DesktopScreen();
    }
  }
}
