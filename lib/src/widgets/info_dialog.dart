import 'package:flutter/material.dart';

class InfoDialog
    extends
        StatelessWidget {
  final String title;
  final Widget content;

  const InfoDialog({
    super.key,
    required this.title,
    required this.content,
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
        width: 450, // Forces a large, wide modal
        constraints: const BoxConstraints(
          maxHeight: 650,
        ),
        padding: const EdgeInsets.all(
          24,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withValues(
            alpha: 0.9,
          ), // Linter compliant!
          borderRadius: BorderRadius.circular(
            24,
          ),
          border: Border.all(
            color: Colors.cyanAccent.withValues(
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
            Text(
              title,
              style: const TextStyle(
                color: Colors.cyanAccent,
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
            // The Flexible + ScrollView ensures large text blocks don't overflow the screen
            Flexible(
              child: SingleChildScrollView(
                child: content,
              ),
            ),
            const SizedBox(
              height: 24,
            ),
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
      ),
    );
  }
}
