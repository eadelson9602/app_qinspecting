import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/services/login_service.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return createAppBar(context);
  }

  AppBar createAppBar(BuildContext context) {
    final loginService = Provider.of<LoginService>(context);
    String url = loginService.userDataLogged.persImagen!;
    return AppBar(
      title: const Text('Qinspecting'),
      backgroundColor: Colors.green,
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: CircleAvatar(
            child: FadeInImage(
              placeholder: const AssetImage('assets/images/loading-2.gif'),
              image: NetworkImage(url.toString()),
              fit: BoxFit.cover,
            ),
          ),
        )
      ],
    );
  }
}
