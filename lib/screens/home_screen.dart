import 'dart:io';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/screens/screens.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/widgets/widgets.dart';
import 'package:app_qinspecting/ui/app_theme.dart';
import 'package:app_qinspecting/models/models.dart';

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

    // Validar datos de empresa
    print('[HOME SCREEN] Verificando datos de empresa:');
    print('  - nombreBase: ${loginService.selectedEmpresa.nombreBase}');
    print(
        '  - numeroDocumento: ${loginService.selectedEmpresa.numeroDocumento}');

    List<Widget> _widgetOptions = [
      DesktopScreen(),
      loginService.selectedEmpresa.nombreBase == null ||
              loginService.selectedEmpresa.nombreBase!.isEmpty
          ? Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.orange,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No se pudo cargar la información de la empresa',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                ],
              ),
            )
          : FutureBuilder(
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
            child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                // Padding inferior para evitar que el contenido se corte con el bottom navigation
                100), // Aumentado para dar espacio al bottom navigation
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
        )),
        bottomNavigationBar: CustomBottomNavigation(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
          scaffoldKey: _scaffoldKey,
        ),
      ),
    );
  }

  Future<bool> _onWillPopScope() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 6,
            shadowColor:
                Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            title: Text(
              '¿Desea salir de la aplicación?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            content: Text(
              'Puedes perder tus datos sin guardar.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            actionsPadding:
                EdgeInsets.only(top: 0, bottom: 10, left: 10, right: 10),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.errorColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Salir',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ),
                ],
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
    final inspeccionProvider =
        Provider.of<InspeccionProvider>(context, listen: false);

    if (inspeccionProvider.vehiculoSelected?.modelo != null) {
      inspeccionProvider.clearData();
    }

    return Column(
      children: [
        SizedBox(height: 5), // Reducido el espacio inicial
        // Mini Dashboard con estadísticas
        MiniDashboard(),
        FutureBuilder<bool>(
            future: inspeccionService.checkConnection(),
            builder: (context, connectionSnapshot) {
              if (connectionSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return Container(
                    height: 300,
                    child: Center(child: CircularProgressIndicator()));
              }

              final hasConnection = connectionSnapshot.data ?? false;

              // Si hay conexión, cargar desde el servicio
              if (hasConnection) {
                return FutureBuilder(
                    future: inspeccionService
                        .getLatesInspections(loginService.selectedEmpresa),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                            height: 300,
                            child: Center(child: CircularProgressIndicator()));
                      } else if (snapshot.data != false) {
                        if (inspeccionService.listInspections.isEmpty) {
                          return Container(
                            height: 300,
                            alignment: Alignment.center,
                            child: Text(
                              'No hay inspecciones recientes',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color),
                            ),
                          );
                        }
                        return Container(
                          height: 410,
                          child: Swiper(
                            layout: SwiperLayout.STACK,
                            itemHeight: 410, // Altura fija del card
                            itemWidth: 500, // Ancho fijo del card
                            itemBuilder: (BuildContext context, int i) {
                              return CardInspeccionDesktop(
                                  resumenPreoperacional:
                                      inspeccionService.listInspections[i]);
                            },
                            itemCount: inspeccionService.listInspections.length,
                          ),
                        );
                      } else {
                        // Si hay algún error con el servicio, intentar mostrar offline
                        return _buildOfflineInspections(
                            context, loginService, inspeccionProvider);
                      }
                    });
              } else {
                // No hay conexión, mostrar inspecciones offline
                return _buildOfflineInspections(
                    context, loginService, inspeccionProvider);
              }
            }),
      ],
    );
  }

  Widget _buildOfflineInspections(BuildContext context,
      LoginService loginService, InspeccionProvider inspeccionProvider) {
    // Validar que los datos del usuario estén disponibles
    if (loginService.userDataLogged.numeroDocumento == null ||
        loginService.userDataLogged.base == null) {
      return Container(
        height: 300,
        alignment: Alignment.center,
        child: Text(
          'No hay inspecciones para mostrar',
          style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).textTheme.bodyMedium?.color),
        ),
      );
    }

    return FutureBuilder<List<ResumenPreoperacional>?>(
        future: inspeccionProvider.cargarTodosInspecciones(
            loginService.userDataLogged.numeroDocumento!,
            loginService.userDataLogged.base!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
                height: 300, child: Center(child: CircularProgressIndicator()));
          }

          final allInspecciones = snapshot.data ?? [];

          if (allInspecciones.isEmpty) {
            return Container(
              height: 410,
              width: 500,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.white
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black.withValues(alpha: 0.08)
                        : Theme.of(context).shadowColor.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black.withValues(alpha: 0.04)
                        : Theme.of(context).shadowColor.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 150,
                    width: 150,
                    child: const Image(
                      image: AssetImage('assets/images/boot_signature_2.gif'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 8),
                  AnimatedTextKit(
                    isRepeatingAnimation: true,
                    animatedTexts: [
                      TypewriterAnimatedText('No hay inspecciones para mostrar',
                          speed: Duration(milliseconds: 100),
                          textAlign: TextAlign.center,
                          textStyle: TextStyle(
                            fontSize: 16,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                            fontWeight: FontWeight.w600,
                          )),
                    ],
                  ),
                ],
              ),
            );
          }

          // Convertir ResumenPreoperacional a ResumenPreoperacionalServer
          final convertedInspecciones = allInspecciones.map((inspeccion) {
            return ResumenPreoperacionalServer(
              resuPreId: inspeccion.id,
              consecutivo: null, // No disponible en SQLite
              fechaPreoperacional: inspeccion.fechaPreoperacional,
              creado: inspeccion.fechaPreoperacional,
              hora: null, // Extraer de fechaPreoperacional si es necesario
              detalle: null, // Se carga desde respuestas
              placaVehiculo: inspeccion.placaVehiculo,
              kilometraje: inspeccion.kilometraje,
              tanqueo: inspeccion.cantTanqueoGalones != null &&
                      inspeccion.cantTanqueoGalones! > 0
                  ? 'SI'
                  : 'NO',
              numeroGuia: inspeccion.numeroGuia,
              grave: 0, // Calcular desde respuestas si es necesario
              moderada: 0, // Calcular desde respuestas si es necesario
              estado: inspeccion.enviado == 1 ? 'ENVIADO' : 'PENDIENTE',
              cantFallas: '0',
              nota: null,
            );
          }).toList();

          return Container(
            height: 410,
            child: Swiper(
              layout: SwiperLayout.STACK,
              itemHeight: 410,
              itemWidth: 500,
              itemBuilder: (BuildContext context, int i) {
                return CardInspeccionDesktop(
                  resumenPreoperacional: convertedInspecciones[i],
                  inspeccionOffline: allInspecciones[i],
                );
              },
              itemCount: convertedInspecciones.length,
            ),
          );
        });
  }
}
