import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _dotAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Create individual animations for each dot
    _dotAnimations = List.generate(3, (index) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.2, // Stagger the animations
            (index + 1) * 0.2,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });

    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: const Color(0xFFFFFFFF),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(
            child: Image(
              image: AssetImage('assets/images/loading_4.gif'),
              width: 180,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Cargando',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black),
              ),
              const SizedBox(width: 4),
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Row(
                    children: List.generate(3, (index) {
                      return AnimatedBuilder(
                        animation: _dotAnimations[index],
                        builder: (context, child) {
                          return Opacity(
                            opacity: _dotAnimations[index].value,
                            child: const Text(
                              '.',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black),
                            ),
                          );
                        },
                      );
                    }),
                  );
                },
              ),
            ],
          )
        ],
      ),
    ));
  }
}
