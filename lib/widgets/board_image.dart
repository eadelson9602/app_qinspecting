import 'package:flutter/material.dart';

class BoardImage extends StatelessWidget {
  const BoardImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _buildBoxDecoration(),
      height: 250,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        child: FadeInImage(
          image: NetworkImage('https://via.placeholder.com/400x300/green'),
          placeholder: AssetImage('assets/images/loading-2.gif'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  BoxDecoration _buildBoxDecoration() => BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 5))
          ]);
}
