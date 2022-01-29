import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return createAppBar();
  }

  AppBar createAppBar() {
    return AppBar(
    title: const Text('Qinspecting'),
    actions: [
      IconButton(onPressed: () {}, icon: const Icon(Icons.notifications))
    ],
  );
  }
}
