import 'package:asteroid_racers/src/models/game_speed.dart';
import 'package:flutter/material.dart';
import 'package:asteroid_racers/src/models/enums.dart';
import 'package:asteroid_racers/src/models/game_settings.dart';
import 'package:asteroid_racers/src/screens/game_page.dart';

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
  // --- Current Selections (Defaulted) ---
  BoardSize _selectedBoardSize = BoardSize.regular;
  int _selectedPlayerCount = 1;
  Difficulty _selectedDifficulty = Difficulty.normal;
  GameSpeedLevel _selectedGameSpeed = GameSpeedLevel.normal;

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
                'NUMBER OF PLAYERS',
              ),
              _buildPlayerCountControls(),
              if (_selectedPlayerCount ==
                  1) ...[
                _buildTitle(
                  'AI DIFFICULTY',
                ),
                _buildDifficultyControls(),
              ],
              _buildTitle(
                'GAME SPEED',
              ),
              _buildGameSpeedControls(),
              const SizedBox(
                height: 40,
              ),
              _buildStartButton(
                context,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Utility Builder Methods ---

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
                  // --- Applying the color style to the text ---
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
                  // ---------------------------------------------
                ),
          );
        },
      ).toList(),
    );
  }

  Widget _buildPlayerCountControls() {
    return Row(
      children:
          [
            1,
            2,
          ].map(
            (
              count,
            ) {
              final isSelected =
                  count ==
                  _selectedPlayerCount;
              // Player 1 is Blue, Player 2 is Red
              final color =
                  count ==
                      1
                  ? Colors.blueAccent
                  : Colors.redAccent;

              return Expanded(
                child:
                    RadioMenuButton<
                      int
                    >(
                      value: count,
                      groupValue: _selectedPlayerCount,
                      onChanged:
                          (
                            int? value,
                          ) {
                            if (value !=
                                null) {
                              setState(
                                () => _selectedPlayerCount = value,
                              );
                            }
                          },
                      // Applying the color style to the text
                      child: Text(
                        '$count Player${count > 1 ? 's' : ''}',
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

  Widget _buildDifficultyControls() {
    // This Column stacks the buttons vertically
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Align to the left
      children: Difficulty.values.map(
        (
          difficulty,
        ) {
          final isSelected =
              difficulty ==
              _selectedDifficulty;
          final color = _getColorForDifficulty(
            difficulty,
          );

          // Return the RadioMenuButton directly, perhaps wrapped in Padding
          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 2.0,
            ),
            child:
                RadioMenuButton<
                  Difficulty
                >(
                  value: difficulty,
                  groupValue: _selectedDifficulty,
                  onChanged:
                      (
                        value,
                      ) {
                        if (value !=
                            null) {
                          setState(
                            () => _selectedDifficulty = value,
                          );
                        }
                      },
                  child: Text(
                    difficulty.name.toUpperCase(),
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
    // Calculate the index for the current level (0=VerySlow, 4=VeryFast)
    final double sliderValue = _selectedGameSpeed.index.toDouble();
    final String description = GameSpeed.getDescription(
      _selectedGameSpeed,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Very Slow',
            ),
            Text(
              'Very Fast',
            ),
          ],
        ),
        Slider(
          value: sliderValue,
          min: 0.0,
          max:
              (GameSpeedLevel.values.length -
                      1)
                  .toDouble(), // 4.0
          divisions:
              GameSpeedLevel.values.length -
              1, // 4 divisions
          label: _selectedGameSpeed.name.toUpperCase(),
          onChanged:
              (
                double newValue,
              ) {
                setState(
                  () {
                    // Map the double value back to the enum index
                    _selectedGameSpeed = GameSpeedLevel.values[newValue.round()];
                  },
                );
              },
        ),
        // Display the description below the slider
        Padding(
          padding: const EdgeInsets.only(
            top: 8.0,
          ),
          child: Text(
            description,
            style: TextStyle(
              color: Colors.white54, // Muted text
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton(
    BuildContext context,
  ) {
    return Center(
      child: ElevatedButton.icon(
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
          final settings = GameSettings(
            boardSize: _selectedBoardSize,
            playerCount: _selectedPlayerCount,
            difficulty: _selectedDifficulty,
            gameSpeed: _selectedGameSpeed,
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
    );
  }

  // Inside the _SettingsScreenState class

  Color _getColorForDifficulty(
    Difficulty difficulty,
  ) {
    switch (difficulty) {
      case Difficulty.god:
        return Colors.red.shade700; // Hardest: Red
      case Difficulty.hard:
        return Colors.orange.shade700; // Hard: Orange/Yellow
      case Difficulty.normal:
        return Colors.blue.shade300; // Normal: Blue
      case Difficulty.easy:
        return Colors.green.shade400; // Easiest: Green
    }
  }

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
