import 'dart:io';
import 'package:flutter/material.dart';

class BoardImage extends StatelessWidget {
  const BoardImage({Key? key, this.url}) : super(key: key);
  final String? url;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _buildBoxDecoration(),
      height: 250,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        child: getImage(url),
      ),
    );
  }

  BoxDecoration _buildBoxDecoration() => BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(
                color: Color.fromARGB(13, 0, 0, 0),
                blurRadius: 2,
                offset: Offset(0, 5))
          ]);
  Widget getImage(String? picture) {
    if (picture == null) {
      return Image(
        image: AssetImage('assets/images/no-image.png'),
        // fit: BoxFit.cover,
      );
    }
    return Image.file(
      File(picture),
      fit: BoxFit.cover,
      cacheWidth: 640,
      cacheHeight: 640,
    );
  }
}
