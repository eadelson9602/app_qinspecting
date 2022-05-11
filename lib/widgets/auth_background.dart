import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final _sizeScreen = MediaQuery.of(context).size;
    return Stack(
      children: [
        const _BubleBox(),
        SingleChildScrollView(
          child: Container(
            height: _sizeScreen.height * 0.9,
            margin: EdgeInsets.only(top: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _HeaderLogo(),
                child,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Image(image: AssetImage('assets/icons/facebook.png'))
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Image(image: AssetImage('assets/icons/instagram.png'))
                    ),
                  ],
                )
              ],
            ),
          ),
        )
      ]
    );
  }
}

class _BubleBox extends StatelessWidget {
  const _BubleBox({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Stack(
        children: const [
          Positioned(
              top: -60,
              left: 0,
              child: _Bubble(
                colorInit: Color.fromRGBO(103, 210, 0, 1),
                colorStop: Color.fromRGBO(249, 195, 56, 1),
              )),
          Positioned(
              top: -20,
              left: -50,
              child: _Bubble(
                colorInit: Color.fromRGBO(31, 133, 53, 1),
                colorStop: Color.fromRGBO(103, 210, 0, 1),
              )),
          Positioned(
              bottom: -60,
              right: 0,
              child: _Bubble(
                colorInit: Color.fromRGBO(249, 195, 56, 1),
                colorStop: Color.fromRGBO(209, 255, 34, 1),
              )),
          Positioned(
              bottom: -20,
              right: -50,
              child: _Bubble(
                colorInit: Color.fromRGBO(31, 133, 53, 1),
                colorStop: Color.fromRGBO(103, 210, 0, 1),
              )),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({Key? key, required this.colorInit, required this.colorStop})
      : super(key: key);
  final Color colorInit;
  final Color colorStop;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: LinearGradient(colors: [colorInit, colorStop])),
    );
  }
}

class _HeaderLogo extends StatelessWidget {
  const _HeaderLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        child: const Image(
          image: AssetImage('assets/images/logo.png'),
          height: 60,
        ),
      ),
    );
  }
}
