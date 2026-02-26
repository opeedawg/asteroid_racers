import 'package:asteroid_racers/src/models/game_settings.dart';
import 'package:asteroid_racers/src/models/player.dart';
import 'package:asteroid_racers/src/screens/authentication_screen.dart';
import 'package:asteroid_racers/src/screens/game_page.dart';
import 'package:asteroid_racers/src/widgets/game_header.dart';
import 'package:asteroid_racers/src/widgets/pilot_profile_dialog.dart';
import 'package:flutter/material.dart';
import 'package:asteroid_racers/src/models/lookup_item.dart';
import 'package:asteroid_racers/src/widgets/space_background.dart';
import 'package:asteroid_racers/src/widgets/universal_lookup_slider.dart';
import 'package:asteroid_racers/src/services/data_access.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Required for signOut

class SettingsScreen
    extends
        StatefulWidget {
  const SettingsScreen({
    super.key,
  });

  @override
  State<
    SettingsScreen
  >
  createState() => _SettingsScreenState();
}

class _SettingsScreenState
    extends
        State<
          SettingsScreen
        > {
  bool _isLoading = true;
  String? _pilotTag;
  final DataAccess _db = DataAccess();

  // Categories
  List<
    LookupItem
  >
  _boardSizes = [];
  List<
    LookupItem
  >
  _gameSpeeds = [];
  List<
    LookupItem
  >
  _aiDifficulties = [];
  List<
    LookupItem
  >
  _themes = [];
  List<
    LookupItem
  >
  _volumes = [];

  // Selection Indices
  int _boardSizeIdx = 0;
  int _gameSpeedIdx = 0;
  int _aiDifficultyIdx = 0;
  int _themeIdx = 0;
  int _volumeIdx = 0;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  Future<
    void
  >
  _initializeSettings() async {
    try {
      await _db.initializeSession();
      _pilotTag = _db.getPilotTag();
      final allLookups = await _db.getLookups();

      _boardSizes = allLookups
          .where(
            (
              e,
            ) =>
                e.key ==
                'BoardSize',
          )
          .toList();
      _gameSpeeds = allLookups
          .where(
            (
              e,
            ) =>
                e.key ==
                'GameSpeed',
          )
          .toList();
      _aiDifficulties = allLookups
          .where(
            (
              e,
            ) =>
                e.key ==
                'AIDifficulty',
          )
          .toList();
      _themes = allLookups
          .where(
            (
              e,
            ) =>
                e.key ==
                'Theme',
          )
          .toList();
      _volumes = allLookups
          .where(
            (
              e,
            ) =>
                e.key ==
                'Volume',
          )
          .toList();

      final lastPlayed = _db.getLastPlayedSettings();

      setState(
        () {
          _boardSizeIdx = _findIdx(
            _boardSizes,
            lastPlayed['board_size_id'],
            defaultIdx: 1,
          );
          _gameSpeedIdx = _findIdx(
            _gameSpeeds,
            lastPlayed['game_speed_id'],
            defaultIdx: 2,
          );
          _aiDifficultyIdx = _findIdx(
            _aiDifficulties,
            lastPlayed['ai_difficulty_id'],
            defaultIdx: 1,
          );
          _themeIdx = _findIdx(
            _themes,
            lastPlayed['theme_id'],
            defaultIdx: 0,
          );
          _volumeIdx = _findIdx(
            _volumes,
            lastPlayed['volume_id'],
            defaultIdx: 2,
          );
          _isLoading = false;
        },
      );
    } catch (
      e
    ) {
      debugPrint(
        'Failed to load settings: $e',
      );
    }
  }

  int _findIdx(
    List<
      LookupItem
    >
    list,
    int? id, {
    int defaultIdx = 0,
  }) {
    if (id ==
        null) {
      return defaultIdx;
    }
    final found = list.indexWhere(
      (
        item,
      ) =>
          item.id ==
          id,
    );
    return (found !=
            -1)
        ? found
        : defaultIdx;
  }

  void _startGame() async {
    // 1. Grab the current selected IDs
    final selectedBoardSizeId = _boardSizes[_boardSizeIdx].id;
    final selectedGameSpeedId = _gameSpeeds[_gameSpeedIdx].id;
    final selectedAiDifficultyId = _aiDifficulties[_aiDifficultyIdx].id;
    final selectedThemeId = _themes[_themeIdx].id;
    final selectedVolumeId = _volumes[_volumeIdx].id;

    // 2. Save to database
    final settingsMap = {
      'board_size_id': selectedBoardSizeId,
      'game_speed_id': selectedGameSpeedId,
      'ai_difficulty_id': selectedAiDifficultyId,
      'theme_id': selectedThemeId,
      'volume_id': selectedVolumeId,
    };
    await _db.updateLastPlayed(
      settingsMap,
    );
    debugPrint(
      'Launching match with saved settings...',
    );

    // 3. Build the GameSettings object for the engine
    final matchSettings = GameSettings(
      boardSizeId: selectedBoardSizeId,
      gameSpeedId: selectedGameSpeedId,
      aiDifficultyId: selectedAiDifficultyId,
      themeId: selectedThemeId,
      volumeId: selectedVolumeId,
      player1: Player.human(
        namerTag:
            _pilotTag ??
            'Unknown Pilot',
      ),
    );

    // 4. Navigate to the actual game!
    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(
        MaterialPageRoute(
          builder:
              (
                context,
              ) => GamePage(
                settings: matchSettings,
              ),
        ),
      );
    }
  }

  void _showPilotProfile(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder:
          (
            context,
          ) => PilotProfileDialog(
            pilotTag:
                _pilotTag ??
                'Unknown',
            onLogout: () async {
              await Supabase.instance.client.auth.signOut();

              if (context.mounted) {
                // 1. Close the dialog popup
                Navigator.of(
                  context,
                ).pop();

                // 2. Wipe the navigation stack and go to Auth Screen
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
                  ) => false, // This false means "destroy all previous routes"
                );
              }
            },
          ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SpaceBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.green,
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    GameHeader(
                      title: 'Game Setup',
                      pilotTag: _pilotTag,
                      onProfilePressed: () => _showPilotProfile(
                        context,
                      ),
                      onLeaderboardPressed: () {
                        /* Navigate to Leaderboard */
                      },
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 8.0,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            // 1. The Dynamic Premium Upsell Banner
                            if (!_db.isPremium()) _buildPremiumBanner(),

                            // 2. The Data-Driven Sliders
                            UniversalLookupSlider(
                              title: 'BOARD SIZE',
                              items: _boardSizes,
                              hiddenCount: _db.getHiddenCount(
                                'BoardSize',
                              ),
                              selectedIndex: _boardSizeIdx,
                              onChanged:
                                  (
                                    val,
                                  ) => setState(
                                    () => _boardSizeIdx = val,
                                  ),
                            ),
                            UniversalLookupSlider(
                              title: 'GAME SPEED',
                              items: _gameSpeeds,
                              hiddenCount: _db.getHiddenCount(
                                'GameSpeed',
                              ),
                              selectedIndex: _gameSpeedIdx,
                              onChanged:
                                  (
                                    val,
                                  ) => setState(
                                    () => _gameSpeedIdx = val,
                                  ),
                            ),
                            UniversalLookupSlider(
                              title: 'AI DIFFICULTY',
                              items: _aiDifficulties,
                              hiddenCount: _db.getHiddenCount(
                                'AIDifficulty',
                              ),
                              selectedIndex: _aiDifficultyIdx,
                              onChanged:
                                  (
                                    val,
                                  ) => setState(
                                    () => _aiDifficultyIdx = val,
                                  ),
                            ),
                            UniversalLookupSlider(
                              title: 'AUDIO VOLUME',
                              items: _volumes,
                              selectedIndex: _volumeIdx,
                              onChanged:
                                  (
                                    val,
                                  ) => setState(
                                    () => _volumeIdx = val,
                                  ),
                            ),
                            UniversalLookupSlider(
                              title: 'VISUAL THEME',
                              items: _themes,
                              hiddenCount: _db.getHiddenCount(
                                'Theme',
                              ),
                              selectedIndex: _themeIdx,
                              onChanged:
                                  (
                                    val,
                                  ) => setState(
                                    () => _themeIdx = val,
                                  ),
                            ),

                            const SizedBox(
                              height: 32,
                            ),

                            // 3. The New Primary Action Button (Restored to the body)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: 40.0,
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                height: 60,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade700,
                                    foregroundColor: Colors.white,
                                    elevation: 8,
                                    shadowColor: Colors.greenAccent.withValues(
                                      alpha: 0.4,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        30,
                                      ),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.rocket_launch,
                                  ),
                                  label: const Text(
                                    'START MATCH',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  onPressed: _startGame,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildPremiumBanner() {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      padding: const EdgeInsets.all(
        12,
      ),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(
          alpha: 0.1,
        ),
        borderRadius: BorderRadius.circular(
          8,
        ),
        border: Border.all(
          color: Colors.amber.withValues(
            alpha: 0.5,
          ),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.stars,
            color: Colors.amber,
            size: 20,
          ),
          SizedBox(
            width: 12,
          ),
          Expanded(
            child: Text(
              'FREE TIER: Upgrade for XL Boards, Master AI, and Nebula Themes!',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper widget outside the State class
class _StatTile
    extends
        StatelessWidget {
  final String label;
  final String value;
  const _StatTile({
    required this.label,
    required this.value,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white38,
          ),
        ),
      ],
    );
  }
}
