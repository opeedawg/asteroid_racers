import 'dart:async';
import 'package:asteroid_racers/src/screens/authentication_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // <-- 1. New Import

import 'package:asteroid_racers/src/screens/settings_screen.dart';

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
        seconds: 1,
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

  // --- 2. The New Auth Gate Logic ---
  void _navigateToNext() async {
    if (!_canContinue ||
        !mounted) {
      return;
    }

    // Check if the user is already logged in locally
    final session = Supabase.instance.client.auth.currentSession;

    if (session !=
        null) {
      // 3. User HAS a token -> Go straight to Game Settings
      Navigator.of(
        context,
      ).pushReplacement(
        MaterialPageRoute(
          builder:
              (
                context,
              ) => const SettingsScreen(),
        ),
      );
    } else {
      // 3. User has NO token -> Go to Authentication
      Navigator.of(
        context,
      ).pushReplacement(
        MaterialPageRoute(
          builder:
              (
                context,
              ) => const AuthenticationScreen(),
        ),
      );
    }
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
            Positioned.fill(
              child: Image.asset(
                'assets/images/asteroidRacersSplash.png',
                fit: BoxFit.cover,
              ),
            ),
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
