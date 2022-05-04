import 'package:flutter/material.dart';

// import 'package:app_qinspecting/widgets/widgets.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _AccessButton(),
      ),
    );
  }
}

class _AccessButton extends StatelessWidget {
  const _AccessButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Es necesario activar el gps'),
        MaterialButton(
          color: Colors.black,
          shape: StadiumBorder(),
          child: Text(
            'Solicitar acceso',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {},
        )
      ],
    );
  }
}

class _EnableGpsMessage extends StatelessWidget {
  const _EnableGpsMessage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('Debe de habilitar el gps');
  }
}
