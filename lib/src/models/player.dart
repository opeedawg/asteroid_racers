import 'package:asteroid_racers/src/models/enums.dart'; // Keep for AIDifficulty
import 'package:uuid/uuid.dart';

class Player {
  final String id;
  String namerTag;
  final AIDifficulty? difficulty;
  final String? passwordHash;

  // --- Primary Constructor ---
  Player._internal({
    required this.namerTag,
    this.difficulty,
    this.passwordHash,
  }) : id = const Uuid().v4();

  // --- Helper Constructor for Human Players ---
  Player.human({
    required String namerTag,
    String? passwordHash,
  }) : this._internal(
         namerTag: namerTag,
         passwordHash: passwordHash,
         difficulty: null,
       );

  // --- Helper Constructor for AI opponent ---
  Player.ai({
    required this.difficulty,
  }) : id = const Uuid().v4(),
       namerTag = 'A.I. (${difficulty!.name.toUpperCase()})',
       passwordHash = null;

  // --- NEW: Smart Getters to replace PlayerType ---

  /// Returns true if this player is controlled by the AI Engine.
  bool get isAI =>
      difficulty !=
      null;

  /// Returns the display name for the UI.
  String get displayName {
    // Since all humans are now authenticated pilots, we just return their tag.
    // The AI constructor already formats its own namerTag!
    return namerTag;
  }
}
