import 'dart:async';
import 'package:flutter/material.dart';
import 'package:asteroid_racers/src/screens/launch_screen.dart';

class SplashScreen
    extends
        StatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override
  State<
    SplashScreen
  >
  createState() => _SplashScreenState();
}

class _SplashScreenState
    extends
        State<
          SplashScreen
        >
    with
        TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<
    double
  >
  _pulseAnimation;
  late AnimationController _entranceController;
  late Animation<
    double
  >
  _entranceAnimation;

  bool _canContinue = false;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 1,
      ),
    );
    _entranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeIn,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 1,
      ),
    );
    _pulseAnimation =
        Tween<
              double
            >(
              begin: 0.6,
              end: 1.0,
            )
            .animate(
              CurvedAnimation(
                parent: _pulseController,
                curve: Curves.easeInOut,
              ),
            );

    Future.delayed(
      const Duration(
        seconds: 3,
      ),
      () {
        if (mounted) {
          setState(
            () => _canContinue = true,
          );
          _entranceController.forward().then(
            (
              _,
            ) {
              _pulseController.repeat(
                reverse: true,
              );
            },
          );
        }
      },
    );
  }

  @override
  void didChangeDependencies() {
    precacheImage(
      const AssetImage(
        "assets/images/asteroidRacersSplash.png",
      ),
      context,
    );
    super.didChangeDependencies();
  }

  void _navigateToNext() async {
    if (!_canContinue ||
        !mounted)
      return;

    // OPTIONAL: Resize window back to a wider format for the main game
    // await windowManager.setSize(const Size(1280, 800));
    // await windowManager.center();

    Navigator.of(
      context,
    ).pushReplacement(
      MaterialPageRoute(
        builder:
            (
              context,
            ) => const PilotRegistrationScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _navigateToNext,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // Background Image fills the new vertical window
            Positioned.fill(
              child: Image.asset(
                'assets/images/asteroidRacersSplash.png',
                fit: BoxFit.cover,
              ),
            ),

            // Prompt Area
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _entranceAnimation,
                child: ScaleTransition(
                  scale: _pulseAnimation,
                  child: const Column(
                    children: [
                      Text(
                        'TAP OR CLICK TO START',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Icon(
                        Icons.touch_app,
                        color: Colors.white70,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
