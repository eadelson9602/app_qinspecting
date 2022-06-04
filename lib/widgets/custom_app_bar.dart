import 'package:app_qinspecting/providers/login_form_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/services/services.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key}) : super(key: key);
  Size get preferredSize => const Size.fromHeight(50);

  @override
  Widget build(BuildContext context) {
    final loginService = Provider.of<LoginService>(context, listen: false);
    final loginForm = Provider.of<LoginFormProvider>(context, listen: false);
    final inspeccionService = Provider.of<InspeccionService>(context, listen: false);
    String url = loginService.userDataLogged.urlFoto;
    return AppBar(
      title: const Text('Qinspecting'),
      backgroundColor: Colors.green,
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: CircleAvatar(
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(25)),
              child: FutureBuilder(
                future: inspeccionService.checkConnection(),
                builder: (context, snapshot) {
                  if(snapshot.data == true){

                    return Container(
                      height: 40,
                      child: loginForm.getImage(url)
                    );
                  }
                  return Image(image: AssetImage('assets/images/loading-2.gif'));
                },
              ),
            ),
          ),
        )
      ],
    );
  }
}
