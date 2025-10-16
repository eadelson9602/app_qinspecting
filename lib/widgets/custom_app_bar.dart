import 'package:app_qinspecting/providers/login_form_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/services/services.dart';
import '../ui/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key}) : super(key: key);
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final loginService = Provider.of<LoginService>(context, listen: false);
    final loginForm = Provider.of<LoginFormProvider>(context, listen: false);
    final inspeccionService =
        Provider.of<InspeccionService>(context, listen: false);
    String url = loginService.userDataLogged.urlFoto;

    return AppBar(
      title: const Text(
        'Qinspecting',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      backgroundColor: AppTheme.primaryGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: FutureBuilder(
                future: inspeccionService.checkConnection(),
                builder: (context, snapshot) {
                  if (snapshot.data == true) {
                    return Container(
                        height: 40, width: 40, child: loginForm.getImage(url));
                  }
                  return Container(
                    height: 40,
                    width: 40,
                    child: const Image(
                      image: AssetImage('assets/images/boot_signature.gif'),
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
          ),
        )
      ],
    );
  }
}
