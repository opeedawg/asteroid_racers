import 'package:flutter/material.dart';

class GameHeader
    extends
        StatelessWidget {
  final String title;
  final String? pilotTag;
  final VoidCallback onProfilePressed;
  final VoidCallback? onLeaderboardPressed;
  final List<
    Widget
  >?
  extraActions;

  const GameHeader({
    super.key,
    required this.title,
    this.pilotTag,
    required this.onProfilePressed,
    this.onLeaderboardPressed,
    this.extraActions,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return SliverAppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              letterSpacing: 3,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          if (pilotTag !=
              null)
            Text(
              'PILOT: ${pilotTag!.toUpperCase()}',
              style: const TextStyle(
                fontSize: 10,
                color: Colors.blueAccent,
                letterSpacing: 1.5,
              ),
            ),
        ],
      ),
      backgroundColor: Colors.transparent,
      centerTitle: false,
      toolbarHeight: 80,
      floating: true,
      pinned: false, // Set to true if you want it to stay visible while scrolling
      actions: [
        if (onLeaderboardPressed !=
            null)
          IconButton(
            icon: const Icon(
              Icons.leaderboard_rounded,
              color: Colors.amberAccent, // Gold for ranking/competition
              size: 28,
            ),
            tooltip: 'Rankings',
            onPressed: onLeaderboardPressed,
          ),
        IconButton(
          icon: const Icon(
            Icons.account_circle_outlined,
            color: Colors.blueAccent, // Matches your "Pilot Tag" color scheme
            size: 28,
          ),
          tooltip: 'Pilot Profile',
          onPressed: onProfilePressed,
        ),
        if (extraActions !=
            null)
          ...extraActions!,
        const SizedBox(
          width: 8,
        ),
      ],
    );
  }
}
