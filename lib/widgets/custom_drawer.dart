import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/providers/providers.dart';
import '../ui/app_theme.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UiProvider>(context);
    final loginService = Provider.of<LoginService>(context, listen: false);

    return Drawer(
      backgroundColor: Colors.white,
      elevation: 8,
      child: Column(
        children: [
          // Header del drawer
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Image(
                          image: AssetImage('assets/images/logo.png'),
                          height: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Sistema de Inspecciones',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),

          // Opciones del menú
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 20),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.home_outlined,
                  title: 'Escritorio',
                  onTap: () {
                    uiProvider.selectedMenuOpt = 0;
                    Navigator.popAndPushNamed(context, 'home');
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.person_outline,
                  title: 'Perfil',
                  onTap: () => Navigator.popAndPushNamed(context, 'profile'),
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.send_outlined,
                  title: 'Enviar inspecciones',
                  onTap: () =>
                      Navigator.popAndPushNamed(context, 'send_pending'),
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.edit_outlined,
                  title: 'Firma',
                  onTap: () => Navigator.popAndPushNamed(context, 'signature'),
                ),
                const Divider(height: 20),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.logout_outlined,
                  title: 'Cerrar sesión',
                  isDestructive: true,
                  onTap: () async {
                    final resClear = await loginService.logout();
                    if (resClear)
                      Navigator.pushNamedAndRemoveUntil(
                          context, 'login', (r) => false);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive
                ? AppTheme.errorColor.withValues(alpha: 0.1)
                : AppTheme.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDestructive ? AppTheme.errorColor : AppTheme.primaryGreen,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? AppTheme.errorColor : Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: onTap,
      ),
    );
  }
}
