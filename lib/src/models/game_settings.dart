import 'package:asteroid_racers/src/models/enums.dart';

class GameSettings {
  final BoardSize boardSize;
  final int playerCount;
  final Difficulty difficulty;
  final GameSpeedLevel gameSpeed;

  const GameSettings({
    this.boardSize = BoardSize.regular,
    this.playerCount = 1,
    this.difficulty = Difficulty.normal,
    this.gameSpeed = GameSpeedLevel.normal,
  });
}
