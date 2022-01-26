import 'package:flutter/material.dart';

class InputDecorations {
  static InputDecoration authInputDecorations(
      {required String hintText,
      required String labelText,
      IconData? prefixIcon}) {
    return InputDecoration(
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.green)),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.green, width: 2)),
        hintText: hintText,
        labelText: labelText,
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: Colors.green,
              )
            : null);
  }
}
