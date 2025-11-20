import 'package:flutter/material.dart';
import 'package:asteroid_racers/src/models/enums.dart';
import 'package:asteroid_racers/src/models/game_settings.dart';
import 'package:asteroid_racers/src/models/game_speed.dart'; // Import GameSpeed utility
import 'package:asteroid_racers/src/models/game_theme.dart'; // Import GameTheme model
import 'package:asteroid_racers/src/screens/game_page.dart';
import 'package:asteroid_racers/src/models/player.dart';

class SettingsScreen
    extends
        StatefulWidget {
  // We accept the players from the LaunchScreen
  final Player player1;
  final Player? player2; // Optional, usually created dynamically here based on settings

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
  // --- Game Configuration State ---
  BoardSize _selectedBoardSize = BoardSize.regular;
  GameSpeedLevel _selectedGameSpeed = GameSpeedLevel.normal;

  // --- Audio & Visual State ---
  bool _soundOn = true;
  double _volumeLevel = 80.0;
  ThemeOption _selectedTheme = ThemeOption.classic;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Asteroid Racers: Setup',
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(
            20.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(
                'BOARD SIZE',
              ),
              _buildBoardSizeControls(),

              _buildTitle(
                'GAME SPEED',
              ),
              _buildGameSpeedControls(),

              const Divider(
                height: 40,
                thickness: 2,
              ),

              _buildTitle(
                'AUDIO SETTINGS',
              ),
              _buildSoundControls(),

              _buildTitle(
                'VISUAL THEME',
              ),
              _buildThemeControls(),

              const SizedBox(
                height: 40,
              ),
              _buildStartButton(
                context,
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Builders ---

  Widget _buildTitle(
    String title,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 20,
        bottom: 10,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  Widget _buildBoardSizeControls() {
    return Row(
      children: BoardSize.values.map(
        (
          size,
        ) {
          final isSelected =
              size ==
              _selectedBoardSize;
          final color = _getColorForBoardSize(
            size,
          );

          return Expanded(
            child:
                RadioMenuButton<
                  BoardSize
                >(
                  value: size,
                  groupValue: _selectedBoardSize,
                  onChanged:
                      (
                        BoardSize? value,
                      ) {
                        if (value !=
                            null) {
                          setState(
                            () => _selectedBoardSize = value,
                          );
                        }
                      },
                  child: Text(
                    size.name.toUpperCase(),
                    style: TextStyle(
                      color: isSelected
                          ? color
                          : Colors.white70,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
          );
        },
      ).toList(),
    );
  }

  Widget _buildGameSpeedControls() {
    final double sliderValue = _selectedGameSpeed.index.toDouble();
    final String description = GameSpeed.getDescription(
      _selectedGameSpeed,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Very Slow',
              style: TextStyle(
                fontSize: 12,
              ),
            ),
            Text(
              'Very Fast',
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
        Slider(
          value: sliderValue,
          min: 0.0,
          max:
              (GameSpeedLevel.values.length -
                      1)
                  .toDouble(),
          divisions:
              GameSpeedLevel.values.length -
              1,
          label: _selectedGameSpeed.name.toUpperCase(),
          onChanged:
              (
                double newValue,
              ) {
                setState(
                  () {
                    _selectedGameSpeed = GameSpeedLevel.values[newValue.round()];
                  },
                );
              },
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
          ),
          child: Text(
            description,
            style: const TextStyle(
              color: Colors.white54,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSoundControls() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text(
            'Sound Effects',
          ),
          value: _soundOn,
          onChanged:
              (
                bool value,
              ) {
                setState(
                  () => _soundOn = value,
                );
              },
          secondary: Icon(
            _soundOn
                ? Icons.volume_up
                : Icons.volume_off,
          ),
        ),
        if (_soundOn)
          Slider(
            value: _volumeLevel,
            min: 0,
            max: 100,
            divisions: 10,
            label: '${_volumeLevel.round()}%',
            onChanged:
                (
                  double value,
                ) {
                  setState(
                    () => _volumeLevel = value,
                  );
                },
          ),
      ],
    );
  }

  Widget _buildThemeControls() {
    // CHANGE: Use Row for horizontal layout
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: ThemeOption.values.map(
        (
          option,
        ) {
          final themeData = GameTheme.themeData[option]!;
          final isSelected =
              _selectedTheme ==
              option;

          // WRAP: Use Expanded to ensure equal width distribution
          return Expanded(
            child:
                RadioMenuButton<
                  ThemeOption
                >(
                  value: option,
                  groupValue: _selectedTheme,
                  onChanged:
                      (
                        value,
                      ) {
                        if (value !=
                            null) {
                          setState(
                            () => _selectedTheme = value,
                          );
                        }
                      },
                  child: Text(
                    // Use the theme description or a short name for space
                    themeData.option.name.toUpperCase(),
                    style: TextStyle(
                      color: isSelected
                          ? Colors.blueAccent
                          : Colors.white70,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
          );
        },
      ).toList(),
    );
  }

  Widget _buildStartButton(
    BuildContext context,
  ) {
    return Center(
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(
            Icons.play_arrow,
          ),
          label: const Text(
            'START GAME',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          onPressed: () {
            // 1. Gather ONLY environment settings
            final settings = GameSettings(
              boardSize: _selectedBoardSize,
              gameSpeed: _selectedGameSpeed,
              soundOn: _soundOn,
              volumeLevel: _volumeLevel.round(),
              themeOption: _selectedTheme,
            );

            // 2. Navigate
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

  // --- Color Helpers ---

  Color _getColorForBoardSize(
    BoardSize size,
  ) {
    switch (size) {
      case BoardSize.extraLarge:
        return Colors.red.shade700;
      case BoardSize.large:
        return Colors.orange.shade600;
      case BoardSize.regular:
        return Colors.blue.shade300;
      case BoardSize.small:
        return Colors.green.shade400;
    }
  }
}
