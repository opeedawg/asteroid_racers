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
    // 1. We remove the Scaffold here. It should be in your screen file,
    // and this widget should just be the "Skin".
    return SizedBox.expand(
      child: Stack(
        children: [
          // 2. THE IMAGE: Using Positioned.fill with BoxFit.cover
          // to ensure it bleeds past all window edges.
          Positioned.fill(
            child: Opacity(
              opacity: 0.4,
              child: Image.asset(
                'assets/images/asteroidRacersSettingsFrame3.jpg',
                fit: BoxFit.cover, // Forces edge-to-edge coverage
                alignment: Alignment.center,
              ),
            ),
          ),

          // 3. THE VIGNETTE: Updated to be very subtle but edge-to-edge
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5, // Pushes the gradient way out past the corners
                  colors: [
                    Colors.black.withValues(
                      alpha: 0.0,
                    ),
                    Colors.black.withValues(
                      alpha: 0.4,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. THE CONTENT
          if (child !=
              null)
            child!,
        ],
      ),
    );
  }
}
