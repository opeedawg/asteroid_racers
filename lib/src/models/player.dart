// In lib/src/models/player.dart

import 'package:asteroid_racers/src/models/enums.dart';
import 'package:uuid/uuid.dart';

class Player {
  final String id;
  String namerTag;

  final PlayerType type;
  final AIDifficulty? difficulty;

  final String? passwordHash;

  // --- Primary Constructor ---
  Player._internal({
    // Use private internal constructor
    required this.namerTag,
    required this.type,
    this.difficulty,
    this.passwordHash,
  }) : id = const Uuid().v4();

  // --- NEW: Helper Constructor for Human Players ---
  Player.human({
    required String namerTag,
    String? passwordHash,
    // The caller (LaunchScreen) determines the type
    required PlayerType type,
  }) : this._internal(
         namerTag: namerTag,
         type: type,
         passwordHash: passwordHash,
         difficulty: null,
       );
  // --- Helper Constructor for AI opponent ---
  Player.ai({
    required this.difficulty,
  }) : id = const Uuid().v4(),
       type = PlayerType.ai,
       namerTag = 'A.I. (${difficulty!.name.toUpperCase()})',
       passwordHash = null;

  // Helper function to create the display name for the UI
  String get displayName {
    if (type ==
        PlayerType.ai) {
      return namerTag;
    }
    // Append (Guest) if anonymous
    return type ==
            PlayerType.anonymous
        ? '$namerTag (Guest)'
        : namerTag;
  }
}
