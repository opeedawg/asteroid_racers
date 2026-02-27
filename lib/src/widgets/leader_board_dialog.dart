import 'package:flutter/material.dart';
import 'package:asteroid_racers/src/widgets/info_dialog.dart';

class LeaderboardDialog
    extends
        StatelessWidget {
  const LeaderboardDialog({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return InfoDialog(
      title: 'GLOBAL LEADERBOARD',
      content: Column(
        children: [
          const Text(
            'ESTABLISHING SECURE CONNECTION...',
            style: TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          // A mock header row for the table
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RANK',
                style: TextStyle(
                  color: Colors.white.withValues(
                    alpha: 0.5,
                  ),
                  fontSize: 12,
                ),
              ),
              Text(
                'PILOT',
                style: TextStyle(
                  color: Colors.white.withValues(
                    alpha: 0.5,
                  ),
                  fontSize: 12,
                ),
              ),
              Text(
                'WINS',
                style: TextStyle(
                  color: Colors.white.withValues(
                    alpha: 0.5,
                  ),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Divider(
            color: Colors.cyanAccent.withValues(
              alpha: 0.3,
            ),
            height: 16,
          ),

          // A few mock rows to show what it will look like
          _buildMockRow(
            '1',
            'OPEEDAWG',
            '42',
            Colors.amber,
          ),
          _buildMockRow(
            '2',
            'STARLORD',
            '38',
            Colors.blueGrey.shade300,
          ),
          _buildMockRow(
            '3',
            'RIPLEY',
            '31',
            Colors.brown.shade300,
          ),
          _buildMockRow(
            '4',
            'SPACEMAN_SPIFF',
            '24',
            Colors.white,
          ),
          _buildMockRow(
            '5',
            'GUEST_99',
            '12',
            Colors.white,
          ),

          const SizedBox(
            height: 24,
          ),
          Text(
            'Starfleet engineering is currently building the live database link. Check back soon for live rankings!',
            style: TextStyle(
              color: Colors.cyanAccent.withValues(
                alpha: 0.7,
              ),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMockRow(
    String rank,
    String tag,
    String wins,
    Color rankColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '#$rank',
            style: TextStyle(
              color: rankColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            tag,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            wins,
            style: const TextStyle(
              color: Colors.cyanAccent,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
