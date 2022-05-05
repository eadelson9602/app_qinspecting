import 'package:flutter/material.dart';
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
    final inspeccionProvider = Provider.of<InspeccionProvider>(context, listen: false);
    final loginService = Provider.of<LoginService>(context, listen: false);

    List<Widget> _widgetOptions = [
      DesktopScreen(),
      FutureBuilder(
          future: inspeccionProvider.listarDataInit(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingScreen();
            } else {
              return InspeccionForm();
            }
          })
    ];

    return Scaffold(
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
          if (index == 1 && loginService.userDataLogged.firmaId == 0) {
            Navigator.popAndPushNamed(context, 'signature');
          } else {
            _onItemTapped(index);
          }
        },
      ),
    );
  }
}
