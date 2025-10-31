import 'package:flutter/material.dart';

class SettingsThemedDivider extends StatelessWidget {
  const SettingsThemedDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(
      height: 1,
      indent: 52,
      endIndent: 0,
      color: isDark ? Colors.white12 : Colors.black12,
    );
  }
}

