import 'package:flutter/material.dart';
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
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isAnonymous = true;

  @override
  Widget build(
    BuildContext context,
  ) {
    // ... (UI logic to be provided next)
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Welcome to Asteroid Racers',
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(
            32.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isAnonymous
                    ? 'Play Anonymously'
                    : 'Login / Register',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SwitchListTile(
                title: const Text(
                  'Play Anonymously?',
                ),
                value: _isAnonymous,
                onChanged:
                    (
                      bool value,
                    ) {
                      setState(
                        () {
                          _isAnonymous = value;
                        },
                      );
                    },
              ),
              TextField(
                controller: _tagController,
                decoration: const InputDecoration(
                  labelText: 'NamerTag',
                  hintText: 'Enter your name or login tag',
                ),
              ),
              if (!_isAnonymous)
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                onPressed: _launchSettings,
                child: const Text(
                  'CONTINUE TO SETTINGS',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchSettings() {
    if (_tagController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a NamerTag.',
          ),
        ),
      );
      return;
    }

    // --- Create the Player Object ---
    final Player player = Player(
      namerTag: _tagController.text,
      isAuthenticated: !_isAnonymous,
      // Placeholder: In a real app, we'd hash the password here.
      passwordHash: _isAnonymous
          ? null
          : _passwordController.text,
    );

    // Pass the player object to the SettingsScreen
    Navigator.of(
      context,
    ).push(
      MaterialPageRoute(
        builder:
            (
              context,
            ) => SettingsScreen(),
      ),
    );
  }
}
