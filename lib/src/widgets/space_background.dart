import 'package:flutter/material.dart';

class SpaceBackground
    extends
        StatelessWidget {
  final Widget? child;

  const SpaceBackground({
    super.key,
    this.child,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.black, // This fixes the "grey/ugly" gap issue
      body: Stack(
        children: [
          // 1. The Art - Set to 'contain' so it NEVER distorts
          Positioned.fill(
            child: Image.asset(
              'assets/images/asteroidRacersSettingsFrame2.jpg',
              fit: BoxFit.contain, // Keeps art perfectly proportional
              alignment: Alignment.center,
            ),
          ),

          // 2. The Dark Vignette
          // This creates a smooth transition between the art and the black background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    Colors.black.withOpacity(
                      0.2,
                    ), // Let art show in center
                    Colors.black.withOpacity(
                      0.9,
                    ), // Fade to black at edges
                  ],
                ),
              ),
            ),
          ),

          // 3. Your UI Content
          if (child !=
              null)
            child!,
        ],
      ),
    );
  }
}
