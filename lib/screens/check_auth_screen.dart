import 'package:app_qinspecting/screens/home_screen.dart';
import 'package:app_qinspecting/screens/login_screen.dart';
import 'package:app_qinspecting/services/login_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CheckScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loginService = Provider.of<LoginService>(context, listen: false);
    return Scaffold(
      body: Center(
        child: FutureBuilder(
            future: loginService.readToken(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (!snapshot.hasData) return Text('Espere');
              if (snapshot.data == '') {
                Future.microtask(() {
                  Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                          pageBuilder: (_, __, ___) => LoginScreen(),
                          transitionDuration: Duration(seconds: 0)));
                });
              } else {
                Future.microtask(() {
                  Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                          pageBuilder: (_, __, ___) => HomeScreen(),
                          transitionDuration: Duration(seconds: 0)));
                });
              }
              return Container();
            }),
      ),
    );
  }
}
