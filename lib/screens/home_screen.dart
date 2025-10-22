import 'dart:io';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/screens/screens.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/widgets/widgets.dart';
import 'package:app_qinspecting/ui/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
        key: _scaffoldKey,
        drawer: CustomDrawer(),
        body: SafeArea(
            child: Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, 0), // Reducido aún más el espacio superior
          child: _widgetOptions.elementAt(_selectedIndex),
        )),
        bottomNavigationBar: Container(
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Color(0xFF34A853).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 6),
                spreadRadius: 0,
              ),
            ],
            border: Border(
              bottom: BorderSide(
                color: Color(0xFF34A853),
                width: 3,
              ),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Row(
              children: [
                // Botón del sidebar
                Expanded(
                  child: Builder(
                    builder: (context) => InkWell(
                      onTap: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.grid_view_rounded,
                              color: Color(0xFF606060),
                              size: 28,
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Menú',
                              style: TextStyle(
                                color: Color(0xFF606060),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Botón Escritorio
                Expanded(
                  child: InkWell(
                    onTap: () {
                      inspeccionProvider.clearData();
                      _onItemTapped(0);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.home_outlined,
                                color: _selectedIndex == 0
                                    ? Color(0xFF34A853)
                                    : Color(0xFF606060),
                                size: 28,
                              ),
                              if (_selectedIndex == 0)
                                Positioned(
                                  bottom: -2,
                                  child: Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF34A853),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Escritorio',
                            style: TextStyle(
                              color: _selectedIndex == 0
                                  ? Color(0xFF34A853)
                                  : Color(0xFF606060),
                              fontSize: 11,
                              fontWeight: _selectedIndex == 0
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Botón Inspecciones
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (loginService.userDataLogged.idFirma == 0) {
                        Navigator.popAndPushNamed(context, 'signature');
                      } else {
                        _onItemTapped(1);
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.checklist_rounded,
                            color: _selectedIndex == 1
                                ? Color(0xFF34A853)
                                : Color(0xFF606060),
                            size: 28,
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Inspecciones',
                            style: TextStyle(
                              color: _selectedIndex == 1
                                  ? Color(0xFF34A853)
                                  : Color(0xFF606060),
                              fontSize: 11,
                              fontWeight: _selectedIndex == 1
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPopScope() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.warning_rounded, color: AppTheme.warningColor),
                const SizedBox(width: 8),
                const Text('Confirmar salida'),
              ],
            ),
            content: const Text(
              '¿Seguro que quieres salir de la aplicación?',
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Salir'),
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
        SizedBox(height: 5), // Reducido el espacio inicial
        // Mini Dashboard con estadísticas
        MiniDashboard(),
        SizedBox(height: 16),
        FutureBuilder(
            future: inspeccionService
                .getLatesInspections(loginService.selectedEmpresa),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                    height: 355,
                    child: Center(child: CircularProgressIndicator()));
              } else if (snapshot.data != false) {
                if (inspeccionService.listInspections.isEmpty) {
                  return Container(
                    height: 355,
                    alignment: Alignment.center,
                    child: Text(
                      'No hay inspecciones recientes',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  );
                }
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
