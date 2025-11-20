import 'package:flutter/material.dart';
import 'package:asteroid_racers/src/models/enums.dart';
import 'package:asteroid_racers/src/models/player.dart';
import 'package:asteroid_racers/src/screens/settings_screen.dart';

class LaunchScreen
    extends
        StatefulWidget {
  const LaunchScreen({
    super.key,
  });

  @override
  State<
    LaunchScreen
  >
  createState() => _LaunchScreenState();
}

class _LaunchScreenState
    extends
        State<
          LaunchScreen
        > {
  // --- Player 1 State (Mover) ---
  final TextEditingController _p1TagController = TextEditingController(
    text: 'Player 1',
  );
  final TextEditingController _p1PasswordController = TextEditingController();
  bool _isP1Anonymous = true;

  // --- Player 2 State (Opponent) ---
  PlayerType _p2ConfigMode = PlayerType.ai; // AI or Human (anonymous/authenticated)
  final TextEditingController _p2TagController = TextEditingController(
    text: 'Player 2',
  );
  final TextEditingController _p2PasswordController = TextEditingController();
  bool _isP2Anonymous = true;
  AIDifficulty _aiDifficulty = AIDifficulty.normal;

  @override
  void dispose() {
    _p1TagController.dispose();
    _p1PasswordController.dispose();
    _p2TagController.dispose();
    _p2PasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    // If P1 is anonymous, the tag field is enabled for manual entry
    final p1TagEnabled = _isP1Anonymous;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Asteroid Racers: Define Players',
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(
            20.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                // Main Row for Side-by-Side Layout
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- COLUMN 1: PLAYER 1 (Left Side) ---
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPlayerSectionTitle(
                          'PLAYER 1 (Blue)',
                          Colors.blueAccent,
                        ),
                        _buildPlayer1Identity(
                          p1TagEnabled,
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    width: 20,
                  ), // Spacer
                  // --- COLUMN 2: PLAYER 2 (Right Side) ---
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPlayerSectionTitle(
                          'PLAYER 2 (Red - Opponent)',
                          Colors.redAccent,
                        ),
                        _buildOpponentTypeSelector(), // Switch between Human/AI
                        const SizedBox(
                          height: 15,
                        ),

                        // Conditional Display based on P2 Type
                        if (_p2ConfigMode ==
                            PlayerType.ai)
                          _buildAIDifficultySelector()
                        else
                          _buildPlayer2Identity(),
                      ],
                    ),
                  ),
                ],
              ),

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

  // --- UI BUILDER METHODS ---

  Widget _buildPlayerSectionTitle(
    String title,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8.0,
        top: 10.0,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildPlayer1Identity(
    bool tagEnabled,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text(
            'Play Anonymously?',
          ),
          value: _isP1Anonymous,
          onChanged:
              (
                bool value,
              ) {
                setState(
                  () {
                    _isP1Anonymous = value;
                    // Default tag logic
                    if (value) _p1TagController.text = 'Player 1';
                  },
                );
              },
          dense: true,
        ),
        TextField(
          controller: _p1TagController,
          enabled: tagEnabled, // Enabled only if Anonymous
          decoration: const InputDecoration(
            labelText: 'NamerTag (Blue Player)',
            hintText: 'Enter tag',
          ),
        ),
        if (!_isP1Anonymous)
          TextField(
            controller: _p1PasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password (for Login)',
            ),
          ),
      ],
    );
  }

  Widget _buildOpponentTypeSelector() {
    // Only two configuration modes are presented: AI (PlayerType.ai) or Human (PlayerType.anonymous)
    return Row(
      children:
          [
            PlayerType.anonymous,
            PlayerType.ai,
          ].map(
            (
              type,
            ) {
              bool isSelected =
                  _p2ConfigMode ==
                  type;
              return Expanded(
                child:
                    RadioMenuButton<
                      PlayerType
                    >(
                      value: type,
                      groupValue: _p2ConfigMode,
                      onChanged:
                          (
                            value,
                          ) {
                            if (value !=
                                null)
                              setState(
                                () => _p2ConfigMode = value,
                              );
                          },
                      child: Text(
                        type ==
                                PlayerType.ai
                            ? 'A.I. Opponent'
                            : 'Human Opponent',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.redAccent
                              : Colors.white70,
                        ),
                      ),
                    ),
              );
            },
          ).toList(),
    );
  }

  Widget _buildAIDifficultySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(
            top: 15.0,
            bottom: 5.0,
          ),
          child: Text(
            'A.I. LEVEL',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: AIDifficulty.values.map(
            (
              difficulty,
            ) {
              final isSelected =
                  difficulty ==
                  _aiDifficulty;
              final color = _getColorForDifficulty(
                difficulty,
              );

              return Expanded(
                child: TextButton(
                  onPressed: () => setState(
                    () => _aiDifficulty = difficulty,
                  ),
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
        ),
      ],
    );
  }

  Widget _buildPlayer2Identity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text(
            'P2 Play Anonymously?',
          ),
          value: _isP2Anonymous,
          onChanged:
              (
                bool value,
              ) {
                setState(
                  () {
                    _isP2Anonymous = value;
                    if (value) _p2TagController.text = 'Player 2';
                  },
                );
              },
          dense: true,
        ),
        TextField(
          controller: _p2TagController,
          enabled: _isP2Anonymous,
          decoration: const InputDecoration(
            labelText: 'P2 NamerTag',
          ),
        ),
        if (!_isP2Anonymous)
          TextField(
            controller: _p2PasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'P2 Password (for Login)',
            ),
          ),
        const SizedBox(
          height: 15,
        ),
      ],
    );
  }

  Color _getColorForDifficulty(
    AIDifficulty difficulty,
  ) {
    switch (difficulty) {
      case AIDifficulty.god:
        return Colors.red.shade700;
      case AIDifficulty.hard:
        return Colors.orange.shade700;
      case AIDifficulty.normal:
        return Colors.blue.shade300;
      case AIDifficulty.easy:
        return Colors.green.shade400;
    }
  }

  Widget _buildStartButton(
    BuildContext context,
  ) {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(
          Icons.settings,
        ),
        label: const Text(
          'CONTINUE TO SETTINGS',
        ),
        onPressed: () => _launchSettings(
          context,
        ),
      ),
    );
  }

  // --- NAVIGATION LOGIC ---
  void _launchSettings(
    BuildContext context,
  ) {
    // --- VALIDATION ---
    if (_p1TagController.text.isEmpty ||
        (_p2ConfigMode ==
                PlayerType.anonymous &&
            _p2TagController.text.isEmpty)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Please ensure all NamerTags are entered.',
          ),
        ),
      );
      return;
    }

    final p1Type = _isP1Anonymous
        ? PlayerType.anonymous
        : PlayerType.authenticated;

    // --- CREATE PLAYER 1 (Mover) ---
    final Player player1 = Player.human(
      namerTag: _p1TagController.text,
      type: p1Type, // Pass the pre-determined type
      passwordHash: _isP1Anonymous
          ? null
          : _p1PasswordController.text,
    );

    // --- CREATE PLAYER 2 (Opponent) ---
    final Player player2;
    if (_p2ConfigMode ==
        PlayerType.ai) {
      player2 = Player.ai(
        difficulty: _aiDifficulty,
      );
    } else {
      // P2 is Human (Authenticated or Anonymous)
      final p2Type = _isP2Anonymous
          ? PlayerType.anonymous
          : PlayerType.authenticated;

      player2 = Player.human(
        namerTag: _p2TagController.text,
        type: p2Type, // Pass the pre-determined type
        passwordHash: _p2PasswordController.text.isNotEmpty
            ? _p2PasswordController.text
            : null,
      );
    }

    // Navigate and pass both players
    Navigator.of(
      context,
    ).push(
      MaterialPageRoute(
        builder:
            (
              context,
            ) => SettingsScreen(
              player1: player1,
              player2: player2,
            ),
      ),
    );
  }
}
