import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:asteroid_racers/src/widgets/space_background.dart';
import 'package:asteroid_racers/src/screens/settings_screen.dart';

class AuthenticationScreen
    extends
        StatefulWidget {
  const AuthenticationScreen({
    super.key,
  });

  @override
  State<
    AuthenticationScreen
  >
  createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState
    extends
        State<
          AuthenticationScreen
        > {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _tagController = TextEditingController(); // For Sign Up

  bool _isSignUp = false;
  bool _isLoading = false;

  Future<
    void
  >
  _handleAuth() async {
    setState(
      () => _isLoading = true,
    );
    try {
      if (_isSignUp) {
        // 1. Sign Up Logic
        await Supabase.instance.client.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          data: {
            'tag': _tagController.text.trim(),
          }, // This triggers your DB metadata!
        );
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            const SnackBar(
              content: Text(
                'Check your Inbucket for confirmation!',
              ),
            ),
          );
        }
      } else {
        // 2. Login Logic
        await Supabase.instance.client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (mounted) {
          // Success! Head to Settings
          Navigator.of(
            context,
          ).pushReplacement(
            MaterialPageRoute(
              builder:
                  (
                    context,
                  ) => const SettingsScreen(),
            ),
          );
        }
      }
    } catch (
      e
    ) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              'Auth Error: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(
          () => _isLoading = false,
        );
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SpaceBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(
              24.0,
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.rocket_launch,
                  size: 80,
                  color: Colors.cyanAccent,
                ),
                const SizedBox(
                  height: 16,
                ),
                const Text(
                  'PILOT AUTHENTICATION',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),

                Container(
                  constraints: const BoxConstraints(
                    maxWidth: 400,
                  ),
                  padding: const EdgeInsets.all(
                    32,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(
                      alpha: 0.6,
                    ),
                    borderRadius: BorderRadius.circular(
                      20,
                    ),
                    border: Border.all(
                      color: Colors.cyanAccent.withValues(
                        alpha: 0.3,
                      ),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _emailController,
                        label: 'PILOT EMAIL',
                        icon: Icons.email_outlined,
                        hint: 'Enter your email',
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      _buildTextField(
                        controller: _passwordController,
                        label: 'ACCESS KEY',
                        icon: Icons.vpn_key_outlined,
                        hint: 'Enter your password',
                        isObscure: true,
                      ),
                      if (_isSignUp) ...[
                        const SizedBox(
                          height: 20,
                        ),
                        _buildTextField(
                          controller: _tagController,
                          label: 'CALLSIGN (PILOT TAG)',
                          icon: Icons.badge_outlined,
                          hint: 'e.g. OPEEDAWG',
                        ),
                      ],
                      const SizedBox(
                        height: 32,
                      ),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                25,
                              ),
                            ),
                          ),
                          onPressed: _isLoading
                              ? null
                              : _handleAuth,
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  _isSignUp
                                      ? 'INITIALIZE PILOT'
                                      : 'ENGAGE THRUSTERS',
                                ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(
                          () => _isSignUp = !_isSignUp,
                        ),
                        child: Text(
                          _isSignUp
                              ? 'Already a pilot? Sign In'
                              : 'New pilot? Register Callsign',
                          style: const TextStyle(
                            color: Colors.cyanAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    bool isObscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.cyanAccent,
            fontSize: 10,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        TextField(
          controller: controller, // Essential to capture input!
          obscureText: isObscure,
          textInputAction: TextInputAction.done, // Tells the keyboard to show a "Done/Enter" button
          onSubmitted:
              (
                _,
              ) => _handleAuth(),
          style: const TextStyle(
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Colors.white24,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              icon,
              color: Colors.cyanAccent.withValues(
                alpha: 0.7,
              ),
              size: 20,
            ),
            filled: true,
            fillColor: Colors.white.withValues(
              alpha: 0.05,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                10,
              ),
              borderSide: BorderSide(
                color: Colors.white.withValues(
                  alpha: 0.1,
                ),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                10,
              ),
              borderSide: const BorderSide(
                color: Colors.cyanAccent,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
