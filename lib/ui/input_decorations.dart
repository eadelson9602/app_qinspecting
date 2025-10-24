import 'package:flutter/material.dart';
import 'app_theme.dart';

class InputDecorations {
  static InputDecoration authInputDecorations(
      {required String hintText,
      required String labelText,
      IconData? prefixIcon,
      Widget? suffixIcon,
      BuildContext? context}) {
    return InputDecoration(
        filled: true,
        fillColor: context != null 
            ? Theme.of(context).inputDecorationTheme.fillColor
            : AppTheme.surfaceColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: context != null 
                ? Theme.of(context).inputDecorationTheme.enabledBorder?.borderSide.color ?? Colors.grey.shade300
                : Colors.grey.shade300
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: context != null 
                ? Theme.of(context).inputDecorationTheme.focusedBorder?.borderSide.color ?? AppTheme.primaryGreen
                : AppTheme.primaryGreen, 
            width: 2
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: context != null 
                ? Theme.of(context).inputDecorationTheme.errorBorder?.borderSide.color ?? AppTheme.errorColor
                : AppTheme.errorColor
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: context != null 
                ? Theme.of(context).inputDecorationTheme.focusedErrorBorder?.borderSide.color ?? AppTheme.errorColor
                : AppTheme.errorColor, 
            width: 2
          ),
        ),
        hintText: hintText,
        labelText: labelText,
        labelStyle: TextStyle(
          color: context != null 
              ? Theme.of(context).inputDecorationTheme.labelStyle?.color ?? Colors.grey.shade600
              : Colors.grey.shade600,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: TextStyle(
          color: context != null 
              ? Theme.of(context).inputDecorationTheme.floatingLabelStyle?.color ?? AppTheme.primaryGreen
              : AppTheme.primaryGreen,
        ),
        hintStyle: TextStyle(
          color: context != null 
              ? Theme.of(context).inputDecorationTheme.hintStyle?.color ?? Colors.grey.shade500
              : Colors.grey.shade500,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: AppTheme.primaryGreen,
                size: 20,
              )
            : null,
        suffixIcon: suffixIcon != null ? suffixIcon : null);
  }
}
