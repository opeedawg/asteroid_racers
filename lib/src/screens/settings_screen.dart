import 'package:flutter/material.dart';
import 'package:asteroid_racers/src/models/enums.dart';
import 'package:asteroid_racers/src/models/game_settings.dart';
import 'package:asteroid_racers/src/models/game_speed.dart';
import 'package:asteroid_racers/src/models/game_theme.dart';
import 'package:asteroid_racers/src/screens/game_page.dart';
import 'package:asteroid_racers/src/models/player.dart';
import 'package:asteroid_racers/src/widgets/space_background.dart';

class SettingsScreen
    extends
        StatefulWidget {
  final Player player1;
  final Player? player2;

  const SettingsScreen({
    required this.player1,
    this.player2,
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
  BoardSize _selectedBoardSize = BoardSize.regular;
  GameSpeedLevel _selectedGameSpeed = GameSpeedLevel.normal;
  bool _soundOn = true;
  double _volumeLevel = 80.0;
  ThemeOption _selectedTheme = ThemeOption.classic;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SpaceBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              const SliverAppBar(
                title: Text(
                  'GAME SETUP',
                  style: TextStyle(
                    letterSpacing: 3,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                floating: true,
                centerTitle: true,
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 12.0,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      _buildSectionCard(
                        title: 'BOARD SIZE',
                        child: _buildUniversalSlider(
                          value: _selectedBoardSize.index.toDouble(),
                          max:
                              (BoardSize.values.length -
                                      1)
                                  .toDouble(),
                          onChanged:
                              (
                                val,
                              ) => setState(
                                () => _selectedBoardSize = BoardSize.values[val.round()],
                              ),
                          currentLabel: _selectedBoardSize.name.toUpperCase(),
                          description: _getBoardSizeDescription(
                            _selectedBoardSize,
                          ),
                          leftLabel: 'Small',
                          rightLabel: 'Huge',
                        ),
                      ),
                      _buildSectionCard(
                        title: 'GAME SPEED',
                        child: _buildUniversalSlider(
                          value: _selectedGameSpeed.index.toDouble(),
                          max:
                              (GameSpeedLevel.values.length -
                                      1)
                                  .toDouble(),
                          onChanged:
                              (
                                val,
                              ) => setState(
                                () => _selectedGameSpeed = GameSpeedLevel.values[val.round()],
                              ),
                          currentLabel: _selectedGameSpeed.name.toUpperCase(),
                          description: GameSpeed.getDescription(
                            _selectedGameSpeed,
                          ),
                          leftLabel: 'Very Slow',
                          rightLabel: 'Very Fast',
                        ),
                      ),
                      _buildSectionCard(
                        title: 'AUDIO',
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: const Text(
                                'Sound Effects',
                              ),
                              value: _soundOn,
                              onChanged:
                                  (
                                    v,
                                  ) => setState(
                                    () => _soundOn = v,
                                  ),
                              secondary: Icon(
                                _soundOn
                                    ? Icons.volume_up
                                    : Icons.volume_off,
                              ),
                            ),
                            if (_soundOn)
                              _buildUniversalSlider(
                                value: _volumeLevel,
                                max: 100,
                                onChanged:
                                    (
                                      val,
                                    ) => setState(
                                      () => _volumeLevel = val,
                                    ),
                                currentLabel: '${_volumeLevel.round()}%',
                                description: 'Master game volume level.',
                                leftLabel: 'Quiet',
                                rightLabel: 'Loud',
                              ),
                          ],
                        ),
                      ),
                      _buildSectionCard(
                        title: 'VISUAL THEME',
                        child: _buildUniversalSlider(
                          value: _selectedTheme.index.toDouble(),
                          max:
                              (ThemeOption.values.length -
                                      1)
                                  .toDouble(),
                          onChanged:
                              (
                                val,
                              ) => setState(
                                () => _selectedTheme = ThemeOption.values[val.round()],
                              ),
                          currentLabel: _selectedTheme.name.toUpperCase(),
                          description: GameTheme.themeData[_selectedTheme]!.description,
                          leftLabel: 'Classic',
                          rightLabel: 'Retro',
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      _buildStartButton(
                        context,
                      ),
                      const SizedBox(
                        height: 40,
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

  // --- UI Helpers ---

  Widget _buildSectionCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 20,
      ),
      padding: const EdgeInsets.all(
        20,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(
          0.7,
        ), // Darker for better contrast
        borderRadius: BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color: Colors.blueAccent.withOpacity(
            0.4,
          ), // Sharper, sexier border
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(
              0.1,
            ),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
              letterSpacing: 2,
            ),
          ),
          const Divider(
            height: 24,
            color: Colors.white10,
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildUniversalSlider({
    required double value,
    required double max,
    required ValueChanged<
      double
    >
    onChanged,
    required String currentLabel,
    required String description,
    required String leftLabel,
    required String rightLabel,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              leftLabel,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white38,
              ),
            ),
            Text(
              currentLabel,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            Text(
              rightLabel,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white38,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: 0,
          max: max,
          divisions: max.toInt(),
          onChanged: onChanged,
        ),
        Text(
          description,
          style: const TextStyle(
            color: Colors.white54,
            fontStyle: FontStyle.italic,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getBoardSizeDescription(
    BoardSize size,
  ) {
    switch (size) {
      case BoardSize.small:
        return "A tight, high-intensity dogfight space.";
      case BoardSize.regular:
        return "The standard racing arena.";
      case BoardSize.large:
        return "Expansive space for complex maneuvers.";
      case BoardSize.extraLarge:
        return "Only for the most legendary pilots.";
    }
  }

  Widget _buildStartButton(
    BuildContext context,
  ) {
    return Center(
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
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
            'START GAME',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          onPressed: () {
            final settings = GameSettings(
              boardSize: _selectedBoardSize,
              gameSpeed: _selectedGameSpeed,
              soundOn: _soundOn,
              volumeLevel: _volumeLevel.round(),
              themeOption: _selectedTheme,
            );
            Navigator.of(
              context,
            ).push(
              MaterialPageRoute(
                builder:
                    (
                      context,
                    ) => GamePage(
                      settings: settings,
                    ),
              ),
            );
          },
        ),
      ),
    );
  }
}
