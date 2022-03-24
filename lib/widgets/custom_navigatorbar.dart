import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/services/services.dart';

class CustomNavigationBar extends StatelessWidget {
  const CustomNavigationBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UiProvider>(context);
    final loginService = Provider.of<LoginService>(context);
    final currentIdex = uiProvider.selectedMenuOpt;

    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Escritorio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.app_registration_sharp),
          label: 'Inspecciones',
        ),
      ],
      currentIndex: currentIdex,
      selectedItemColor: Colors.green,
      onTap: (int i) {
        if (i == 1 && loginService.userDataLogged.firmaId != 0) {
          uiProvider.selectedMenuOpt = i;
        } else if (i == 1 && loginService.userDataLogged.firmaId == 0) {
          Navigator.popAndPushNamed(context, 'signature');
        } else {
          uiProvider.selectedMenuOpt = i;
        }
      },
    );
  }
}
