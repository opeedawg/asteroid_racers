import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io'; // To check the platform (Windows, Android, etc.)

class LoggerService {
  static final _supabase = Supabase.instance.client;

  static Future<
    void
  >
  logError({
    required String message,
    String? stackTrace,
  }) async {
    try {
      // Grab the current pilot's ID if they are logged in
      final userId = _supabase.auth.currentUser?.id;

      // Figure out what device they are playing on
      final platform = Platform.operatingSystem;

      await _supabase
          .from(
            'error_log',
          )
          .insert(
            {
              'pilot_id': userId,
              'error_message': message,
              'stack_trace': stackTrace,
              'platform_details': platform,
            },
          );

      print(
        "Error securely logged to Supabase.",
      );
    } catch (
      e
    ) {
      // If the logger itself fails, just print it locally so it doesn't crash the app
      print(
        "CRITICAL: Failed to write to error_log: $e",
      );
    }
  }
}
