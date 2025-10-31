import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:app_qinspecting/services/theme_service.dart';
import 'package:app_qinspecting/widgets/settings/settings_ios_group.dart';
import 'package:app_qinspecting/widgets/settings/settings_ios_tile.dart';

class AppearanceSection extends StatelessWidget {
  const AppearanceSection({Key? key}) : super(key: key);

  void _toggleTheme(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context, listen: false);
    themeService.toggleTheme();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          themeService.isDarkMode
              ? 'Tema oscuro activado'
              : 'Tema claro activado',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor:
            themeService.isDarkMode ? Colors.grey[900] : Colors.blue[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);

    return SettingsIosGroup(
      children: [
        SettingsIosTile(
          leading: CupertinoIcons.paintbrush,
          title: 'Apariencia',
          subtitle: 'Tema oscuro',
          trailing: Switch.adaptive(
            value: themeService.isDarkMode,
            onChanged: (_) => _toggleTheme(context),
          ),
        ),
      ],
    );
  }
}

