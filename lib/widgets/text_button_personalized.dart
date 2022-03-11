import 'package:flutter/material.dart';

class TextButtonPersonalized extends StatelessWidget {
  TextButtonPersonalized({Key? key, required this.textButton, this.iconButton})
      : super(key: key);
  final String textButton;
  final IconData? iconButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconButton,
            color: Colors.white,
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            textButton,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          )
        ],
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
