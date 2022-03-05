import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/providers/providers.dart';

class CustomNavigationBar extends StatelessWidget {
  const CustomNavigationBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UiProvider>(context);
    final currentIdex = uiProvider.selectedMenuOpt;

    return BottomNavigationBar(
      currentIndex: currentIdex,
      onTap: (int i) {
        uiProvider.selectedMenuOpt = i;
      },
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Escritorio'),
        BottomNavigationBarItem(
            icon: Icon(Icons.app_registration_sharp), label: 'Inspecciones'),
      ],
    );
  }
}
