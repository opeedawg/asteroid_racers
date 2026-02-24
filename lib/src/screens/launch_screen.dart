import 'package:asteroid_racers/src/models/player.dart';
import 'package:flutter/material.dart';
import 'package:asteroid_racers/src/models/enums.dart';
import 'package:asteroid_racers/src/screens/settings_screen.dart';

class PilotRegistrationScreen
    extends
        StatefulWidget {
  const PilotRegistrationScreen({
    super.key,
  });

  @override
  State<
    PilotRegistrationScreen
  >
  createState() => _PilotRegistrationScreenState();
}

class _PilotRegistrationScreenState
    extends
        State<
          PilotRegistrationScreen
        > {
  // Player 1 States
  final TextEditingController _p1TagController = TextEditingController(
    text: 'Player 1',
  );
  final TextEditingController _p1PasswordController = TextEditingController();
  bool _isP1Anonymous = true;

  // Player 2 States
  PlayerType _p2ConfigMode = PlayerType.ai;
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. THE BACKGROUND (Pattern matched to Splash)
          Positioned.fill(
            child: Image.asset(
              'assets/images/asteroidRacersSettingsFrame2.jpg',
              fit: BoxFit.cover, // Fills the window edge-to-edge
            ),
          ),

          // 2. THE UI LAYER
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 450,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'PILOT REGISTRATION',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),

                      // Player 1 Card
                      _buildInputCard(
                        title: 'PLAYER 1 (Blue)',
                        color: Colors.blueAccent,
                        child: _buildPlayerIdentity(
                          isP1: true,
                          isAnon: _isP1Anonymous,
                          tagController: _p1TagController,
                          passController: _p1PasswordController,
                          onAnonChanged:
                              (
                                val,
                              ) => setState(
                                () => _isP1Anonymous = val!,
                              ),
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      // Player 2 Card
                      _buildInputCard(
                        title: 'PLAYER 2 (Red)',
                        color: Colors.redAccent,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildOpponentTypeSelector(),
                            const SizedBox(
                              height: 15,
                            ),
                            _p2ConfigMode ==
                                    PlayerType.ai
                                ? _buildAIDifficultySelector()
                                : _buildPlayerIdentity(
                                    isP1: false,
                                    isAnon: _isP2Anonymous,
                                    tagController: _p2TagController,
                                    passController: _p2PasswordController,
                                    onAnonChanged:
                                        (
                                          val,
                                        ) => setState(
                                          () => _isP2Anonymous = val!,
                                        ),
                                  ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 40,
                      ),
                      _buildStartButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- COMPONENT BUILDERS ---

  Widget _buildInputCard({
    required String title,
    required Color color,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(
          0.8,
        ),
        borderRadius: BorderRadius.circular(
          15,
        ),
        border: Border.all(
          color: color.withOpacity(
            0.5,
          ),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const Divider(
            color: Colors.white10,
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildPlayerIdentity({
    required bool isP1,
    required bool isAnon,
    required TextEditingController tagController,
    required TextEditingController passController,
    required Function(
      bool?,
    )
    onAnonChanged,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CheckboxListTile(
          title: const Text(
            'Play Anonymously?',
            style: TextStyle(
              fontSize: 14,
            ),
          ),
          value: isAnon,
          onChanged: onAnonChanged,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
        TextField(
          controller: tagController,
          style: const TextStyle(
            color: Colors.white,
          ),
          decoration: const InputDecoration(
            labelText: 'Pilot Tag',
            labelStyle: TextStyle(
              color: Colors.white54,
            ),
          ),
        ),
        // Password field only shows if NOT anonymous
        if (!isAnon) ...[
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: passController,
            obscureText: true,
            style: const TextStyle(
              color: Colors.white,
            ),
            decoration: const InputDecoration(
              labelText: 'Pilot Password',
              labelStyle: TextStyle(
                color: Colors.white54,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOpponentTypeSelector() {
    return Row(
      children:
          [
            PlayerType.authenticated,
            PlayerType.ai,
          ].map(
            (
              type,
            ) {
              bool isSelected =
                  _p2ConfigMode ==
                  type;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                  ),
                  child: ChoiceChip(
                    label: Text(
                      type ==
                              PlayerType.ai
                          ? 'A.I. BOT'
                          : 'HUMAN',
                    ),
                    selected: isSelected,
                    onSelected:
                        (
                          bool val,
                        ) {
                          if (val)
                            setState(
                              () => _p2ConfigMode = type,
                            );
                        },
                  ),
                ),
              );
            },
          ).toList(),
    );
  }

  Widget _buildAIDifficultySelector() {
    return Column(
      children: [
        const Text(
          'A.I. LEVEL',
          style: TextStyle(
            fontSize: 10,
            color: Colors.white54,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: AIDifficulty.values.map(
            (
              d,
            ) {
              bool isSelected =
                  _aiDifficulty ==
                  d;
              return ChoiceChip(
                label: Text(
                  d.name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                  ),
                ),
                selected: isSelected,
                onSelected:
                    (
                      bool val,
                    ) {
                      if (val)
                        setState(
                          () => _aiDifficulty = d,
                        );
                    },
              );
            },
          ).toList(),
        ),
      ],
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              30,
            ),
          ),
        ),
        onPressed: _launchSettings,
        child: const Text(
          'CONTINUE TO SETTINGS',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _launchSettings() {
    // Logic to build player objects and navigate

    final Player player1 = Player.human(
      namerTag: _p1TagController.text,
      type: _isP1Anonymous
          ? PlayerType.anonymous
          : PlayerType.authenticated,
    );

    // FIX: Passing the correct arguments to SettingsScreen
    final Player player2 =
        _p2ConfigMode ==
            PlayerType.ai
        ? Player.ai(
            difficulty: _aiDifficulty,
          )
        : Player.human(
            namerTag: _p2TagController.text,
            type: _isP2Anonymous
                ? PlayerType.anonymous
                : PlayerType.authenticated,
          );

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
