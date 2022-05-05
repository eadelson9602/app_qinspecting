import 'package:app_qinspecting/models/empresa.dart';
import 'package:app_qinspecting/screens/screens.dart';
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
    final _sizeScreen = MediaQuery.of(context).size;
    final inspeccionService = Provider.of<InspeccionService>(context);
    if (inspeccionService.isLoading) return LoadingScreen();
    return Scaffold(
      body: AuthBackground(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: _sizeScreen.height * 0.01,
              ),
              const HeaderLogo(),
              SizedBox(
                height: _sizeScreen.height * 0.10,
              ),
              const Text(
                'Iniciar Sesión',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.w800),
              ),
              const SizedBox(
                height: 20,
              ),
              ChangeNotifierProvider(
                create: (_) => LoginFormProvider(),
                child: const _FormLogin(),
              ),
              const SizedBox(
                height: 50,
              ),
              const Text(
                'Recuperar contraseña',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(
                height: _sizeScreen.height * 0.10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: const Image(
                          image: AssetImage('assets/icons/facebook.png'))),
                  IconButton(
                      onPressed: () {},
                      icon: const Image(
                          image: AssetImage('assets/icons/instagram.png'))),
                ],
              )
            ],
          ),
        ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Form(
          key: loginForm.formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: () => loginForm.existUser = true,
          child: Column(
            children: [
              TextFormField(
                autocorrect: false,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Ingrese su usuario';
                  return null;
                },
                onChanged: (value) =>
                    value.isEmpty ? '' : loginForm.usuario = int.parse(value),
                decoration: InputDecorations.authInputDecorations(
                    hintText: '',
                    labelText: 'Usuario',
                    prefixIcon: Icons.person),
              ),
              const SizedBox(
                height: 20,
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
                        onPressed: () {
                          loginForm.updateObscureText(
                              loginForm.obscureText ? false : true);
                        },
                        icon: Icon(
                          loginForm.obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.green,
                        ))),
              ),
              const SizedBox(
                height: 30,
              ),
              if (!loginForm.existUser)
                Container(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.warning,
                          color: Colors.red,
                        ),
                        Text(
                          'Usuario o contraseña inválida',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    )),
              const SizedBox(
                height: 30,
              ),
              const ButtonLogin()
            ],
          )),
    );
  }
}

class ButtonLogin extends StatelessWidget {
  const ButtonLogin({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loginForm = Provider.of<LoginFormProvider>(context);
    final loginService = Provider.of<LoginService>(context, listen: false);
    final inspeccionService =
        Provider.of<InspeccionService>(context, listen: false);
    final storage = new FlutterSecureStorage();

    return MaterialButton(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      minWidth: 300,
      child: TextButtonLogin(loginForm: loginForm),
      onPressed: loginForm.isLoading
          ? null
          : () async {
              if (!loginForm.isValidForm()) return;
              login(
                  context, loginForm, loginService, storage, inspeccionService);
            },
    );
  }

  void login(
      BuildContext context,
      LoginFormProvider loginForm,
      LoginService loginService,
      FlutterSecureStorage storage,
      InspeccionService inspeccionService) async {
    try {
      loginForm.isLoading = true;
      FocusScope.of(context).unfocus();
      List<Empresa> empresas = [];
      bool isConnected = await inspeccionService.checkConnection();

      if (isConnected) {
        final tempEmpresas =
            await loginService.login(loginForm.usuario, loginForm.password);
        if (tempEmpresas.isNotEmpty) {
          tempEmpresas.forEach((element) => empresas.add(element));
        }
      } else {
        final userData = await DBProvider.db.getUserById(loginForm.usuario);
        if (userData != null && userData.usuarioContra == loginForm.password) {
          final tempEmpresas =
              await DBProvider.db.getAllEmpresasByUsuario(loginForm.usuario);
          tempEmpresas!.forEach((element) => empresas.add(element));
          loginService.userDataLogged = userData;
        } else {
          showSimpleNotification(
            Text(
                'Recuerde iniciar sesión con conexión, para ingresar en offline'),
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
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
                        child: getImage(empresas[i].rutaLogo.toString())),
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
                      await storage.write(
                          key: 'usuario', value: '${empresas[i].usuarioUser}');
                      await storage.write(
                          key: 'idEmpresa', value: '${empresas[i].empId}');
                      Navigator.pushNamed(context, 'home');
                    },
                  ),
                ),
              ));
    } catch (error) {
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

  Widget getImage(String? url) {
    if (url == null || url.contains('svg')) {
      return const ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(50)),
        child: Image(
          image: AssetImage('assets/images/no-image.png'),
          height: 40,
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(50)),
      child: FadeInImage(
          placeholder: const AssetImage('assets/images/loading.gif'),
          image: NetworkImage(url)),
    );
  }
}

class TextButtonLogin extends StatelessWidget {
  const TextButtonLogin({
    Key? key,
    required this.loginForm,
  }) : super(key: key);

  final LoginFormProvider loginForm;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: AlignmentGeometry.lerp(Alignment.center, Alignment.center, 15),
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Text(
        loginForm.isLoading ? 'Iniciando sesión...' : 'Iniciar sesión',
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: const LinearGradient(colors: [
            Color.fromRGBO(31, 133, 53, 1),
            Color.fromRGBO(103, 210, 0, 1)
          ])),
    );
  }
}
