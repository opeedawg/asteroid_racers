import 'package:flutter/material.dart';
import 'package:asteroid_racers/src/widgets/info_dialog.dart';

class AboutGameDialog
    extends
        StatelessWidget {
  const AboutGameDialog({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return InfoDialog(
      title: 'ABOUT ASTEROID RACERS',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'THE MISSION',
            style: TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            'These friendly alien explorers are lightyears away from their home world, stranded in a treacherous and shifting asteroid belt. Your job as a registered Starfleet Pilot is to navigate the chaos, pull the right levers, and guide them safely through the debris before the AI rival beats you to the punch.',
            style: TextStyle(
              color: Colors.white.withValues(
                alpha: 0.8,
              ),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          const Text(
            'THE CREATOR',
            style: TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            'Forged in North Bay, Ontario, Asteroid Racers is the brainchild of a solo polymath developer. Built on a foundation of complex mathematics and advanced software architecture, the engine combines pure grid logic with high-speed retro-arcade action.',
            style: TextStyle(
              color: Colors.white.withValues(
                alpha: 0.8,
              ),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
