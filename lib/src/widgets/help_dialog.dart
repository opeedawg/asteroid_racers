import 'package:flutter/material.dart';
import 'package:asteroid_racers/src/widgets/info_dialog.dart';

class HelpDialog
    extends
        StatelessWidget {
  const HelpDialog({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return InfoDialog(
      title: 'HOW TO PLAY',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHelpRow(
            Icons.swipe_up,
            'SHIFT COLUMNS',
            'Use the Left/Right arrows to select a lever, then press Up/Down to shift the entire column of asteroids and aliens.',
          ),
          const SizedBox(
            height: 16,
          ),
          _buildHelpRow(
            Icons.arrow_downward,
            'GRAVITY RULES',
            'After a shift, gravity takes hold. Any alien unsupported by an asteroid will fall towards the bottom of the grid.',
          ),
          const SizedBox(
            height: 16,
          ),
          _buildHelpRow(
            Icons.directions_run,
            'MAKE YOUR MOVE',
            'Your aliens will automatically march one step forward if their path is clear.',
          ),
          const SizedBox(
            height: 16,
          ),
          _buildHelpRow(
            Icons.military_tech,
            'SCORE POINTS',
            'Guide your blue aliens entirely off your side of the board to score. The pilot with the most rescued aliens wins the sortie!',
          ),
        ],
      ),
    );
  }

  Widget _buildHelpRow(
    IconData icon,
    String title,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.cyanAccent,
          size: 28,
        ),
        const SizedBox(
          width: 16,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withValues(
                    alpha: 0.7,
                  ),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
