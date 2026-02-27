import 'package:flutter/material.dart';

class PilotProfileDialog
    extends
        StatelessWidget {
  final String pilotTag;
  final VoidCallback onLogout;

  const PilotProfileDialog({
    super.key,
    required this.pilotTag,
    required this.onLogout,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 24,
      ),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(
          24,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withValues(
            alpha: 0.9,
          ),
          borderRadius: BorderRadius.circular(
            24,
          ),
          border: Border.all(
            color: Colors.blueAccent.withValues(
              alpha: 0.4,
            ),
            width: 2,
          ),
          image: const DecorationImage(
            image: AssetImage(
              'assets/images/ProfileBackground.png',
            ),
            fit: BoxFit.cover,
            opacity: 0.15,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.account_circle,
              size: 64,
              color: Colors.blueAccent,
            ),
            const SizedBox(
              height: 16,
            ),
            const Text(
              'PILOT DOSSIER',
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 2,
              ),
              textAlign: TextAlign.center,
            ),
            Divider(
              color: Colors.white.withValues(
                alpha: 0.1,
              ),
              height: 32,
              thickness: 1,
            ),
            Text(
              pilotTag.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(
              height: 32,
            ),

            // --- Unified Action Buttons ---
            Column(
              children: [
                // 1. The Danger/Logout Action
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withValues(
                        alpha: 0.1,
                      ),
                      foregroundColor: Colors.redAccent,
                      side: BorderSide(
                        color: Colors.redAccent.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                    ),
                    icon: const Icon(
                      Icons.logout,
                      size: 18,
                    ),
                    label: const Text(
                      'LOGOUT',
                      style: TextStyle(
                        letterSpacing: 1.5,
                      ),
                    ),
                    onPressed: onLogout,
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),

                // 2. The Safe/Dismiss Action
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent.withValues(
                        alpha: 0.1,
                      ),
                      foregroundColor: Colors.cyanAccent,
                      side: BorderSide(
                        color: Colors.cyanAccent.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                    ),
                    icon: const Icon(
                      Icons.close,
                      size: 18,
                    ),
                    label: const Text(
                      'DISMISS',
                      style: TextStyle(
                        letterSpacing: 1.5,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pop();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
