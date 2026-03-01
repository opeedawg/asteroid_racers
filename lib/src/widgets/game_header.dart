import 'package:asteroid_racers/src/screens/authentication_screen.dart';
import 'package:asteroid_racers/src/services/subscription_service.dart';
import 'package:asteroid_racers/src/widgets/about_game_dialog.dart';
import 'package:asteroid_racers/src/widgets/help_dialog.dart';
import 'package:asteroid_racers/src/widgets/leader_board_dialog.dart';
import 'package:asteroid_racers/src/widgets/pilot_profile_dialog.dart';
import 'package:asteroid_racers/src/services/data_access.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GameHeader
    extends
        StatelessWidget {
  final String title;

  const GameHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final String currentPilotTag = DataAccess().getPilotTag();
    final bool isUserPremium = DataAccess().isPremium();

    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      centerTitle: true,
      expandedHeight: isUserPremium
          ? 40.0
          : 80.0,

      // 1. The Dynamic Title Area
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          Text(
            'PILOT: ${currentPilotTag.toUpperCase()}',
            style: TextStyle(
              color: Colors.cyanAccent.withValues(
                alpha: 0.8,
              ),
              fontSize: 12,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),

      // 2. The Universal Icon Actions
      actions: [
        IconButton(
          icon: const Icon(
            Icons.info_outline,
            color: Colors.amberAccent,
          ),
          tooltip: 'About & Lore',
          onPressed: () {
            showDialog(
              context: context,
              builder:
                  (
                    context,
                  ) => const AboutGameDialog(),
            );
          },
        ),
        IconButton(
          icon: const Icon(
            Icons.help_outline,
            color: Colors.greenAccent,
          ),
          tooltip: 'How to Play',
          onPressed: () {
            showDialog(
              context: context,
              builder:
                  (
                    context,
                  ) => const HelpDialog(),
            );
          },
        ),
        IconButton(
          icon: const Icon(
            Icons.stars_outlined,
            color: Colors.pink,
          ),
          tooltip: 'Global Leaderboard',
          onPressed: () {
            showDialog(
              context: context,
              builder:
                  (
                    context,
                  ) => const LeaderboardDialog(),
            );
          },
        ),
        IconButton(
          icon: const Icon(
            Icons.account_circle_outlined,
            color: Colors.blueAccent,
          ),
          tooltip: 'Pilot Profile',
          onPressed: () {
            showDialog(
              context: context,
              builder:
                  (
                    context,
                  ) => PilotProfileDialog(
                    pilotTag: currentPilotTag,
                    onLogout: () async {
                      await Supabase.instance.client.auth.signOut();

                      if (context.mounted) {
                        Navigator.of(
                          context,
                        ).pop();
                        Navigator.of(
                          context,
                        ).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder:
                                (
                                  context,
                                ) => const AuthenticationScreen(),
                          ),
                          (
                            route,
                          ) => false,
                        );
                      }
                    },
                  ),
            );
          },
        ),
        const SizedBox(
          width: 8,
        ),
      ],

      // 3. The Premium Banner
      bottom: isUserPremium
          ? null
          : PreferredSize(
              preferredSize: const Size.fromHeight(
                40,
              ),
              child: GestureDetector(
                onTap: () async {
                  await SubscriptionService().fetchOffers(
                    context,
                  );
                },
                child: Container(
                  width: double.infinity,
                  color: Colors.amber.withValues(
                    alpha: 0.2,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        'UPGRADE TO PREMIUM',
                        style: TextStyle(
                          color: Colors.amber.shade200,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
