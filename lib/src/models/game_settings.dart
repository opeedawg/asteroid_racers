// In lib/src/models/game_settings.dart

import 'package:asteroid_racers/src/models/enums.dart';
import 'package:asteroid_racers/src/models/player.dart';

class GameSettings {
  final BoardSize boardSize;

  final GameSpeedLevel gameSpeed;
  final bool soundOn;
  final int volumeLevel;
  final ThemeOption themeOption;
  final Player player1;
  final Player player2;

  GameSettings({
    Player? player1, // Allow nulls for defaults
    Player? player2, // Allow nulls for defaults
    this.boardSize = BoardSize.regular,
    this.gameSpeed = GameSpeedLevel.normal,
    this.soundOn = true,
    this.volumeLevel = 80,
    this.themeOption = ThemeOption.classic,
  }) : player1 =
           player1 ??
           Player.human(
             namerTag: 'Player 1',
             type: PlayerType.anonymous,
           ),
       player2 =
           player2 ??
           Player.ai(
             difficulty: AIDifficulty.normal,
           );
}
