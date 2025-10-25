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
        child: getImage(url, context),
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
  Widget getImage(String? picture, BuildContext context) {
    if (picture == null) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: 80,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              SizedBox(height: 8),
              Text(
                'No hay imagen',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
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
