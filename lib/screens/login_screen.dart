import 'package:app_qinspecting/models/empresa.dart';
import 'package:app_qinspecting/screens/screens.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:app_qinspecting/ui/input_decorations.dart';
import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/widgets/widgets.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inspeccionService = Provider.of<InspeccionService>(context);
    final loginService = Provider.of<LoginService>(context, listen: false);
    if (inspeccionService.isLoading) return LoadingScreen();

    return Scaffold(
      body: PageView(
        controller: loginService.pageController,
        children: [
          AuthBackground(
            child: ChangeNotifierProvider(
              create: (_) => LoginFormProvider(),
              child: const _FormLogin(),
            ),
          ),
          RememberPasswordScreen(),
        ],
      ),
    );
  }
}

class _FormLogin extends StatelessWidget {
  const _FormLogin({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loginForm = Provider.of<LoginFormProvider>(context);
    final loginService = Provider.of<LoginService>(context, listen: false);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Form(
      key: loginForm.formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: () => loginForm.existUser = true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            'Iniciar sesión',
            style: TextStyle(
              color: Colors.black,
              fontSize: 25,
              fontWeight: FontWeight.w800
            ),
          ),
          Container(
            // color: Colors.red,
            height: 180,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextFormField(
                  autocorrect: false,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return 'Ingrese su usuario';
                    return null;
                  },
                  onChanged: (value) => value.isEmpty ? '' : loginForm.usuario = int.parse(value),
                  decoration: InputDecorations.authInputDecorations(
                    hintText: '',
                    labelText: 'Usuario',
                    prefixIcon: Icons.person
                  ),
                ),
                TextFormField(
                  autocorrect: false,
                  obscureText: loginForm.obscureText,
                  keyboardType: TextInputType.text,
                  onChanged: (value) => loginForm.password = value,
                  validator: (value) {
                    if (value!.isEmpty) return 'Ingrese su contraseña';
                    return null;
                  },
                  decoration: InputDecorations.authInputDecorations(
                    hintText: '******',
                    labelText: 'Contraseña',
                    prefixIcon: Icons.lock_outline_sharp,
                    suffixIcon: IconButton(
                      onPressed: () => loginForm.updateObscureText(loginForm.obscureText ? false : true),
                      icon: Icon(
                        loginForm.obscureText ? Icons.visibility : Icons.visibility_off,
                        color: Colors.green,
                      )
                    )
                  ),
                ),
              ],
            ),
          ),
          if (!loginForm.existUser)
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning,
                    color: Colors.red,
                  ),
                  Text(
                    'Usuario o contraseña inválida',
                    style: TextStyle(color: Colors.red)
                  ),
                ],
              )
            ),
          const _ButtonLogin(),
          TextButton(
            onPressed: () => loginService.pageController.nextPage(duration: Duration(microseconds: 1000), curve: Curves.bounceIn), 
            child: Text('Recuperar contraseña', style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w800
            ))
          )
        ],
      )),
    );
  }
}

class _ButtonLogin extends StatelessWidget {
  const _ButtonLogin({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loginForm = Provider.of<LoginFormProvider>(context);
    final loginService = Provider.of<LoginService>(context, listen: false);
    final inspeccionService = Provider.of<InspeccionService>(context, listen: false);
    final storage = new FlutterSecureStorage();

    return MaterialButton(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      minWidth: 300,
      child: CustomStyleButton(text: loginForm.isLoading ? 'Iniciando sesión...' : 'Iniciar sesión'),
      onPressed: loginForm.isLoading
        ? null
        : () async {
          if (!loginForm.isValidForm()) return;
          login(context, loginForm, loginService, storage, inspeccionService);
        },
    );
  }

  void login(
    BuildContext context,
    LoginFormProvider loginForm,
    LoginService loginService,
    FlutterSecureStorage storage,
    InspeccionService inspeccionService
  ) async {
    try {
      loginForm.isLoading = true;
      FocusScope.of(context).unfocus();
      List<Empresa> empresas = [];
      bool isConnected = await inspeccionService.checkConnection();

      if (isConnected) {
        final resGetToken = await loginService.getToken(loginForm.usuario, loginForm.password);
        if(resGetToken.containsKey('token')){
          final tempEmpresas = await loginService.login(loginForm.usuario, loginForm.password);
          if (tempEmpresas.isNotEmpty) {
            tempEmpresas.forEach((element) => empresas.add(element));
          } else {
            loginForm.existUser = false;
            return;
          }
        } else {
          loginForm.existUser = false;
          return;
        }
      } else {
        final userData = await DBProvider.db.getUserById('${loginForm.usuario}');
        if (userData != null && userData.password == loginForm.password) {
          final tempEmpresas = await DBProvider.db.getAllEmpresasByUsuario(loginForm.usuario);
          tempEmpresas!.forEach((element) => empresas.add(element));
          loginService.userDataLogged = userData;
        } else if (userData != null && userData.password != loginForm.password){
          loginForm.existUser = false;
          return;
        } else {
          showSimpleNotification(
            Text('Recuerde iniciar sesión con conexión, para ingresar en offline'),
            leading: Icon(Icons.info),
            autoDismiss: true,
            background: Colors.orange,
            position: NotificationPosition.bottom,
          );
          return;
        }
      }

      showModalBottomSheet(
        isScrollControlled: false,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        context: context,
        builder: (context) => Container(
          height: empresas.length > 2 ? 250 : 150,
          padding: const EdgeInsets.all(20),
          child: ListView.builder(
            itemCount: empresas.length,
            itemBuilder: (_, int i) => ListTile(
              leading: Container(
                width: 50,
                height: 50,
                child: isConnected ? loginForm.getImage(empresas[i].rutaLogo.toString()) : Image(image: AssetImage('assets/images/loading_4.gif'))
              ),
              title: Text(empresas[i].nombreQi.toString()),
              trailing: const Icon(Icons.arrow_right),
              onTap: () async {
                // Asignamos al servicio la empresa seleccionada
                loginService.selectedEmpresa = empresas[i];
                // online
                if (isConnected) {
                  await loginService.getUserData(empresas[i]);
                  Navigator.popAndPushNamed(context, 'get_data');
                  return;
                }
                // Offline
                await storage.write(key: 'usuario', value: '${empresas[i].numeroDocumento}');
                await storage.write(key: 'idEmpresa', value: '${empresas[i].idEmpresa}');
                Navigator.pushNamed(context, 'home');
              },
            ),
          ),
        )
      );
    } on DioError catch (_) {
      showSimpleNotification(
        Text('Error al iniciar sesión'),
        leading: Icon(Icons.check),
        autoDismiss: true,
        background: Colors.orange,
        position: NotificationPosition.bottom,
      );
    } finally {
      loginForm.isLoading = false;
    }
  }
}
