import 'package:flutter/material.dart';
import 'package:asteroid_racers/src/services/data_access.dart';
import 'package:intl/intl.dart'; // For date formatting

class PilotProfileDialog
    extends
        StatelessWidget {
  final String pilotTag;
  final VoidCallback onLogout;

  const PilotProfileDialog({
    super.key,
    required this.pilotTag,
    required this.onLogout,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child:
          FutureBuilder<
            Map<
              String,
              dynamic
            >
          >(
            future: DataAccess().getDetailedPilotStats(),
            builder:
                (
                  context,
                  snapshot,
                ) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.cyanAccent,
                      ),
                    );
                  }

                  final stats = snapshot.data!;
                  final DateTime joinedDate = DateTime.parse(
                    stats['joined'],
                  );

                  return Container(
                    width: 400,
                    padding: const EdgeInsets.all(
                      24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(
                        alpha: 0.85,
                      ),
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                      border: Border.all(
                        color: Colors.cyanAccent.withValues(
                          alpha: 0.5,
                        ),
                        width: 2,
                      ),
                      image: const DecorationImage(
                        image: AssetImage(
                          'assets/images/ProfileBackground.png',
                        ),
                        fit: BoxFit.cover,
                        opacity: 0.2, // Adjust this if you want the alien to be more or less visible
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'PILOT PROFILE: ${pilotTag.toUpperCase()}',
                          style: const TextStyle(
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: 2,
                          ),
                        ),
                        const Divider(
                          color: Colors.white24,
                          height: 32,
                        ),

                        _buildStatRow(
                          'ENLISTED',
                          DateFormat(
                            'MMMM dd, yyyy',
                          ).format(
                            joinedDate,
                          ),
                        ),
                        _buildStatRow(
                          'TOTAL SORTIES',
                          '${stats['totalMatches']}',
                        ),
                        _buildStatRow(
                          'WIN RATE',
                          '${stats['winRate']}%',
                        ),

                        const SizedBox(
                          height: 32,
                        ),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent.withValues(
                                alpha: 0.8,
                              ),
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(
                              Icons.logout,
                            ),
                            label: const Text(
                              'LOG OUT',
                            ),
                            onPressed: onLogout,
                          ),
                        ),
                      ],
                    ),
                  );
                },
          ),
    );
  }

  Widget _buildStatRow(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
