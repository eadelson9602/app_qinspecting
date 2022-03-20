import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return createAppBar(context);
  }

  AppBar createAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Qinspecting'),
      backgroundColor: Colors.green,
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.notifications))
      ],
    );
  }
}
