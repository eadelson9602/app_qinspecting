import 'dart:io';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/screens/screens.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final inspeccionProvider =
        Provider.of<InspeccionProvider>(context, listen: false);
    final loginService = Provider.of<LoginService>(context, listen: false);

    List<Widget> _widgetOptions = [
      DesktopScreen(),
      FutureBuilder(
          future: inspeccionProvider
              .listarDataInit('${loginService.selectedEmpresa.nombreBase}'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingScreen();
            } else {
              return InspeccionForm();
            }
          })
    ];

    return PopScope(
      canPop: false, // Esto evita que se salga sin tu confirmación

      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldExit = await _onWillPopScope();
        if (shouldExit) {
          if (Platform.isAndroid) {
            await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          } else if (Platform.isIOS) {
            exit(0);
          }
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(),
        drawer: CustomDrawer(),
        body: SafeArea(
            child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: _widgetOptions.elementAt(_selectedIndex),
        )),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Escritorio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.app_registration_sharp),
              label: 'Inspecciones',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.green,
          onTap: (int index) {
            if (index == 1 && loginService.userDataLogged.idFirma == 0) {
              Navigator.popAndPushNamed(context, 'signature');
            } else {
              _onItemTapped(index);
            }
          },
        ),
      ),
    );
  }

  Future<bool> _onWillPopScope() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Icon(Icons.warning, color: Colors.orange),
            content: const Text(
              '¿Seguro que quieres salir de la aplicación?',
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('NO'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true); // <- Aquí devolvemos true
                },
                child: const Text('SI', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class DesktopScreen extends StatelessWidget {
  const DesktopScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loginService = Provider.of<LoginService>(context, listen: false);
    final inspeccionService =
        Provider.of<InspeccionService>(context, listen: false);
    final sizeScreen = MediaQuery.of(context).size;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 10,
        ),
        FutureBuilder(
            future: inspeccionService
                .getLatesInspections(loginService.selectedEmpresa),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                    height: 355,
                    child: Center(child: CircularProgressIndicator()));
              } else if (snapshot.data != false) {
                return Container(
                  height: 420,
                  child: Swiper(
                    layout: SwiperLayout.STACK,
                    itemHeight: sizeScreen.height * 0.8,
                    itemWidth: sizeScreen.height * 0.4,
                    itemBuilder: (BuildContext context, int i) {
                      return CardInspeccionDesktop(
                          resumenPreoperacional:
                              inspeccionService.listInspections[i]);
                    },
                    itemCount: inspeccionService.listInspections.length,
                  ),
                );
              } else {
                return NoInternet();
              }
            }),
      ],
    );
  }
}
