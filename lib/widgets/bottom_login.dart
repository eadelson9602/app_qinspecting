import 'package:flutter/material.dart';

class CustomStyleButton extends StatelessWidget {
  CustomStyleButton({
    Key? key,
    required this.text
  }) : super(key: key);

  final String text;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: AlignmentGeometry.lerp(Alignment.center, Alignment.center, 15),
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Text(
        text,
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
