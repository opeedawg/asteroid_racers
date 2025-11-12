import 'package:asteroid_racers/src/models/enums.dart';

/// Holds all configuration choices made on the settings screen.
class GameSettings {
  final BoardSize boardSize;
  final int playerCount; // 1 or 2
  final Difficulty difficulty;

  const GameSettings({
    this.boardSize = BoardSize.regular,
    this.playerCount = 1,
    this.difficulty = Difficulty.normal,
  });
}
