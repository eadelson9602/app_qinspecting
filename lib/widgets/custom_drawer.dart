import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/providers/providers.dart';
import '../ui/app_theme.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  /// Función para abrir URLs directamente en el navegador
  Future<void> _launchUrlWithContext(BuildContext context, String url) async {
    try {
      // Asegurar que la URL tenga un esquema válido
      if (!url.startsWith('http://') &&
          !url.startsWith('https://') &&
          !url.startsWith('mailto:')) {
        throw Exception('URL sin esquema válido: $url');
      }

      final Uri uri = Uri.parse(url);

      // Verificar que la URL sea válida antes de intentar abrirla
      if (!uri.hasScheme) {
        throw Exception('URI sin esquema: $uri');
      }

      // Intentar abrir directamente en el navegador externo
      bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception('No se pudo abrir la URL: $url');
      }
    } catch (e) {
      print('Error al abrir URL: $e');
      // Si falla, intentar con modo por defecto como fallback
      try {
        final Uri uri = Uri.parse(url);
        bool launched = await launchUrl(uri);

        if (!launched) {
          print('Error: No se pudo abrir la URL con ningún método: $url');
        }
      } catch (e2) {
        print('Error secundario al abrir URL: $e2');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UiProvider>(context);
    final loginService = Provider.of<LoginService>(context, listen: false);

    return Drawer(
      backgroundColor: Theme.of(context).cardColor,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          gradient: Theme.of(context).brightness == Brightness.dark
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).cardColor,
                    Theme.of(context).cardColor,
                    Theme.of(context).cardColor,
                  ],
                  stops: const [0.0, 0.6, 1.0],
                )
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primaryGreen,
                    AppTheme.primaryGreenLight,
                    AppTheme.accentGreen,
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header con perfil de usuario
              _buildUserHeader(context, loginService),

              // Separador
              Container(
                height: 1,
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),

              // Menú de navegación
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildMenuItem(
                      context: context,
                      icon: Icons.home_outlined,
                      title: 'Escritorio',
                      isSelected: uiProvider.selectedMenuOpt == 0,
                      onTap: () {
                        uiProvider.selectedMenuOpt = 0;
                        Navigator.popAndPushNamed(context, 'home');
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.person_outline,
                      title: 'Perfil',
                      onTap: () =>
                          Navigator.popAndPushNamed(context, 'profile'),
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.send_outlined,
                      title: 'Enviar inspecciones',
                      onTap: () =>
                          Navigator.popAndPushNamed(context, 'send_pending'),
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.edit_outlined,
                      title: 'Firma',
                      onTap: () =>
                          Navigator.popAndPushNamed(context, 'signature'),
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.settings_outlined,
                      title: 'Configuración',
                      onTap: () =>
                          Navigator.popAndPushNamed(context, 'settings'),
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.privacy_tip_outlined,
                      title: 'Política de Privacidad',
                      onTap: () => _launchUrlWithContext(context,
                          'https://www.qinspecting.com/politica-tratamiento-datos-personales'),
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.description_outlined,
                      title: 'Términos y Condiciones',
                      onTap: () => _launchUrlWithContext(context,
                          'https://www.qinspecting.com/terminos-y-condiciones'),
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.contact_mail_outlined,
                      title: 'Contacto',
                      onTap: () => _launchUrlWithContext(context,
                          'https://api.whatsapp.com/send?phone=573137840166&text=Hola!%20Estoy%20en%20la%20p%C3%A1gina%20web%20de%20Qinspecting%20y%20quiero%20m%C3%A1s%20informaci%C3%B3n%20acerca%20de%20su%20Plataforma.%20Mi%20nombre%20es...'),
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.help_outline,
                      title: 'Ayuda',
                      onTap: () => _launchUrlWithContext(
                          context, 'mailto:soporte@qinspecting.com  '),
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.info_outline,
                      title: 'Acerca de',
                      onTap: () => _launchUrlWithContext(
                          context, 'https://www.qinspecting.com/about'),
                    ),
                  ],
                ),
              ),

              // Footer con logout
              _buildFooter(context, loginService),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, LoginService loginService) {
    final loginForm = Provider.of<LoginFormProvider>(context, listen: false);
    final inspeccionService =
        Provider.of<InspeccionService>(context, listen: false);
    String url = loginService.userDataLogged.urlFoto;

    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
      child: Column(
        children: [
          // Botón de cerrar drawer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    size: 20,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'V2.1.0',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Avatar del usuario usando el mismo método que el appbar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).dividerColor, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: FutureBuilder(
                future: inspeccionService.checkConnection(),
                builder: (context, snapshot) {
                  if (snapshot.data == true) {
                    return Container(
                      height: 80,
                      width: 80,
                      child: loginForm.getImage(url),
                    );
                  }
                  return Container(
                    height: 80,
                    width: 80,
                    child: const Image(
                      image: AssetImage('assets/images/boot_signature.gif'),
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Nombre del usuario
          Text(
            loginService.userDataLogged.nombres ?? 'Usuario',
            style: TextStyle(
              color: Theme.of(context).textTheme.titleLarge?.color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4),

          // Empresa seleccionada
          Text(
            loginService.selectedEmpresa.nombres ?? 'Empresa',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).dividerColor
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: Theme.of(context).dividerColor)
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, LoginService loginService) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Separador
          Container(
            height: 1,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(1),
            ),
          ),

          // Botón de logout
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                final resClear = await loginService.logout();
                if (resClear) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, 'login', (r) => false);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.logout_outlined,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Cerrar sesión',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
