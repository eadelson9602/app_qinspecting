import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_qinspecting/services/services.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const CustomBottomNavigation({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.scaffoldKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loginService = Provider.of<LoginService>(context, listen: false);
    final inspeccionProvider =
        Provider.of<InspeccionService>(context, listen: false);

    return Container(
      margin: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
          // BoxShadow(
          //   color: Color(0xFF34A853).withValues(alpha: 0.3),
          //   blurRadius: 8,
          //   offset: const Offset(0, 2),
          //   spreadRadius: 0,
          // ),
        ],
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
                    scaffoldKey.currentState?.openDrawer();
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
                        // SizedBox(height: 6),
                        // Text(
                        //   'Menú',
                        //   style: TextStyle(
                        //     color: Color(0xFF606060),
                        //     fontSize: 11,
                        //     fontWeight: FontWeight.w500,
                        //   ),
                        // ),
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
                  onItemTapped(0);
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
                            color: selectedIndex == 0
                                ? Color(0xFF34A853)
                                : Color(0xFF606060),
                            size: 28,
                          ),
                          if (selectedIndex == 0)
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
                      // SizedBox(height: 6),
                      // Text(
                      //   'Escritorio',
                      //   style: TextStyle(
                      //     color: selectedIndex == 0
                      //         ? Color(0xFF34A853)
                      //         : Color(0xFF606060),
                      //     fontSize: 11,
                      //     fontWeight: selectedIndex == 0
                      //         ? FontWeight.w600
                      //         : FontWeight.w500,
                      //   ),
                      // ),
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
                    onItemTapped(1);
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
                        color: selectedIndex == 1
                            ? Color(0xFF34A853)
                            : Color(0xFF606060),
                        size: 28,
                      ),
                      // SizedBox(height: 6),
                      // Text(
                      //   'Inspecciones',
                      //   style: TextStyle(
                      //     color: selectedIndex == 1
                      //         ? Color(0xFF34A853)
                      //         : Color(0xFF606060),
                      //     fontSize: 11,
                      //     fontWeight: selectedIndex == 1
                      //         ? FontWeight.w600
                      //         : FontWeight.w500,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
