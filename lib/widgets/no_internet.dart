import 'package:flutter/material.dart';

class NoInternet extends StatelessWidget {
  const NoInternet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Image(
            image: AssetImage('assets/images/boot.gif'),
            // fit: BoxFit.cover,
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            'Oops!!',
            style: TextStyle(fontSize: 34, color: Colors.black38),
            textAlign: TextAlign.center,
          ),
          Text(
            'Función disponible con conexión a internet...',
            style: TextStyle(fontSize: 24, color: Colors.black38),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
