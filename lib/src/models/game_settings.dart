import 'package:asteroid_racers/src/models/player.dart';

class GameSettings {
  final int boardSizeId;
  final int gameSpeedId;
  final int aiDifficultyId; // Added for the new Master AI tier
  final int themeId;
  final int volumeId;
  final Player player1;

  GameSettings({
    required this.boardSizeId,
    required this.gameSpeedId,
    required this.aiDifficultyId,
    required this.themeId,
    required this.volumeId,
    required this.player1,
  });
}
