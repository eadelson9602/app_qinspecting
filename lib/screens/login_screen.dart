import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';

import 'package:app_qinspecting/models/empresa.dart';
import 'package:app_qinspecting/screens/screens.dart';
import 'package:app_qinspecting/ui/input_decorations.dart';
import 'package:app_qinspecting/ui/app_theme.dart';
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
                    color: Theme.of(context).textTheme.headlineMedium?.color,
                    fontSize: 25,
                    fontWeight: FontWeight.w800),
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
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      validator: (value) {
                        if (value!.isEmpty) return 'Ingrese su usuario';
                        return null;
                      },
                      onChanged: (value) => value.isEmpty
                          ? ''
                          : loginForm.usuario = int.parse(value),
                      decoration: InputDecorations.authInputDecorations(
                          hintText: '',
                          labelText: 'Usuario',
                          prefixIcon: Icons.person,
                          context: context),
                    ),
                    TextFormField(
                      autocorrect: false,
                      obscureText: loginForm.obscureText,
                      keyboardType: TextInputType.text,
                      onChanged: (value) {
                        loginForm.password = value;
                        print('[LOGIN FORM] 🔐 Contraseña actualizada (length: ${value.length})');
                      },
                      validator: (value) {
                        if (value!.isEmpty) return 'Ingrese su contraseña';
                        return null;
                      },
                      decoration: InputDecorations.authInputDecorations(
                          hintText: '******',
                          labelText: 'Contraseña',
                          prefixIcon: Icons.lock_outline_sharp,
                          context: context,
                          suffixIcon: IconButton(
                              onPressed: () => loginForm.updateObscureText(
                                  loginForm.obscureText ? false : true),
                              icon: Icon(
                                loginForm.obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.green,
                              ))),
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
                    Text('Usuario o contraseña inválida',
                        style: TextStyle(color: Colors.red)),
                  ],
                )),
              const _ButtonLogin(),
              TextButton(
                  onPressed: () => loginService.pageController.nextPage(
                      duration: Duration(microseconds: 1000),
                      curve: Curves.bounceIn),
                  child: Text('Recuperar contraseña',
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 16,
                          fontWeight: FontWeight.w800)))
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
    final inspeccionService =
        Provider.of<InspeccionService>(context, listen: false);
    final storage = new FlutterSecureStorage();

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: loginForm.isLoading
            ? null
            : () async {
                print('[LOGIN BUTTON] 🔘 Botón presionado');
                print('[LOGIN BUTTON] 📝 Usuario: ${loginForm.usuario}');
                print('[LOGIN BUTTON] 📝 Password length: ${loginForm.password.length}');
                
                if (!loginForm.isValidForm()) {
                  print('[LOGIN BUTTON] ❌ Formulario inválido');
                  return;
                }
                print('[LOGIN BUTTON] ✅ Formulario válido, iniciando login...');
                login(context, loginForm, loginService, storage,
                    inspeccionService);
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: AppTheme.primaryGreen.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          loginForm.isLoading ? 'Iniciando sesión...' : 'Iniciar sesión',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  void login(
      BuildContext context,
      LoginFormProvider loginForm,
      LoginService loginService,
      FlutterSecureStorage storage,
      InspeccionService inspeccionService) async {
    try {
      print('[LOGIN SCREEN] 🚀 Iniciando proceso de login...');
      print('[LOGIN SCREEN] 📝 Usuario: ${loginForm.usuario}');
      print('[LOGIN SCREEN] 📝 Password length: ${loginForm.password.length}');
      
      loginForm.isLoading = true;
      FocusScope.of(context).unfocus();
      List<Empresa> empresas = [];
      bool isConnected = await inspeccionService.checkConnection();
      
      print('[LOGIN SCREEN] 🌐 Conexión: ${isConnected ? "ONLINE" : "OFFLINE"}');

      if (isConnected) {
        print('[LOGIN SCREEN] 📡 Modo ONLINE - Obteniendo token...');
        final resGetToken =
            await loginService.getToken(loginForm.usuario, loginForm.password);
        
        print('[LOGIN SCREEN] 📥 Respuesta getToken:');
        print('[LOGIN SCREEN]    - Keys: ${resGetToken.keys.toList()}');
        print('[LOGIN SCREEN]    - Contiene token: ${resGetToken.containsKey('token')}');
        print('[LOGIN SCREEN]    - Mensaje: ${resGetToken['message']}');
        print('[LOGIN SCREEN]    - Error: ${resGetToken['error']}');
        
        if (resGetToken.containsKey('token')) {
          print('[LOGIN SCREEN] ✅ Token obtenido, procediendo con login...');
          final tempEmpresas =
              await loginService.login(loginForm.usuario, loginForm.password);
          print('[LOGIN SCREEN] 📊 Empresas recibidas: ${tempEmpresas.length}');
          
          if (tempEmpresas.isNotEmpty) {
            tempEmpresas.forEach((element) => empresas.add(element));
            print('[LOGIN SCREEN] ✅ ${empresas.length} empresa(s) agregada(s)');
          } else {
            print('[LOGIN SCREEN] ❌ No se recibieron empresas del servidor');
            print('[LOGIN SCREEN]    - Esto puede indicar credenciales incorrectas');
            loginForm.existUser = false;
            loginForm.isLoading = false;
            return;
          }
        } else {
          print('[LOGIN SCREEN] ❌ No se pudo obtener el token');
          print('[LOGIN SCREEN]    - Mensaje del servidor: ${resGetToken['message']}');
          print('[LOGIN SCREEN]    - Error: ${resGetToken['error']}');
          loginForm.existUser = false;
          loginForm.isLoading = false;
          return;
        }
      } else {
        final tempEmpresas = await DBProvider.db.getAllEmpresasByUsuario(
            '${loginForm.usuario}', '${loginForm.password}');
        if (tempEmpresas!.isNotEmpty) {
          tempEmpresas.forEach((element) => empresas.add(element));
        } else {
          showSimpleNotification(
            Text(
                'Recuerde iniciar sesión con conexión, para ingresar en offline'),
            leading: Icon(Icons.info),
            autoDismiss: true,
            background: Colors.orange,
            position: NotificationPosition.bottom,
          );
          loginForm.existUser = false;
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
                        child: isConnected
                            ? loginForm
                                .getImage(empresas[i].rutaLogo.toString())
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Image(
                                    fit: BoxFit.cover,
                                    image: AssetImage(
                                        'assets/images/truck.gif')))),
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
                      final userData = await DBProvider.db.getUser(
                          '${loginForm.usuario}',
                          '${loginForm.password}',
                          '${empresas[i].nombreBase}');
                      loginService.userDataLogged = userData!;

                      // Guardar datos necesarios para sesiones futuras
                      await storage.write(
                          key: 'usuario',
                          value: '${empresas[i].numeroDocumento}');
                      await storage.write(
                          key: 'nombreBase',
                          value: '${empresas[i].nombreBase}');
                      await storage.write(
                          key: 'idEmpresa', value: '${empresas[i].idEmpresa}');
                      // Guardar la empresa en SQLite si no existe
                      await DBProvider.db.nuevaEmpresa(empresas[i]);
                      print('[LOGIN OFFLINE] ✅ Empresa guardada en SQLite');

                      // Asignar la empresa seleccionada al servicio
                      loginService.selectedEmpresa = empresas[i];
                      print(
                          '[LOGIN OFFLINE] ✅ Empresa asignada al LoginService');

                      // Verificar si hay token guardado de sesión anterior para este usuario
                      String tokenKey = 'token_${empresas[i].numeroDocumento}';
                      final existingToken = await storage.read(key: tokenKey);
                      if (existingToken == null || existingToken.isEmpty) {
                        print(
                            '⚠️ [LOGIN OFFLINE] No hay token guardado para este usuario');
                        print(
                            '   El usuario necesita conectarse para usar funciones que requieren token');
                      } else {
                        print(
                            '✅ [LOGIN OFFLINE] Token encontrado de sesión anterior para este usuario');
                        print('   - Token key: $tokenKey');
                        // Configurar headers con el token existente
                        loginService.dio.options.headers = {
                          "x-access-token": existingToken
                        };
                        loginService.options.headers = {
                          "x-access-token": existingToken
                        };
                      }

                      Navigator.pushNamed(context, 'home');
                    },
                  ),
                ),
              ));
    } on DioException catch (error) {
      print('[LOGIN SCREEN] ❌ DioException en login:');
      print('[LOGIN SCREEN]    - Type: ${error.type}');
      print('[LOGIN SCREEN]    - Message: ${error.message}');
      print('[LOGIN SCREEN]    - Response: ${error.response?.data}');
      print('[LOGIN SCREEN]    - Status Code: ${error.response?.statusCode}');
      
      String errorMessage = 'Error al iniciar sesión';
      if (error.response?.statusCode == 401 || error.response?.statusCode == 403) {
        errorMessage = 'Usuario o contraseña incorrectos';
      } else if (error.response?.data != null && error.response!.data is Map) {
        errorMessage = error.response!.data['message'] ?? errorMessage;
      }
      
      showSimpleNotification(
        Text(errorMessage),
        leading: Icon(Icons.error),
        autoDismiss: true,
        background: Colors.red,
        position: NotificationPosition.bottom,
      );
    } catch (e, stackTrace) {
      print('[LOGIN SCREEN] ❌ Error inesperado: $e');
      print('[LOGIN SCREEN]    - Stack trace: $stackTrace');
      
      showSimpleNotification(
        Text('Error inesperado al iniciar sesión'),
        leading: Icon(Icons.error),
        autoDismiss: true,
        background: Colors.red,
        position: NotificationPosition.bottom,
      );
    } finally {
      loginForm.isLoading = false;
    }
  }
}
