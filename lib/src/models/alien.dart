import 'package:asteroid_racers/src/models/player.dart';

class Alien {
  // We need to know who this alien belongs to.
  final Player player;

  // And its current position on the board.
  int x;
  int y;

  Alien({
    required this.player,
    required this.x,
    required this.y,
  });

  // Helper constructor to simplify the clone process
  Alien._clone({
    required this.player,
    required this.x,
    required this.y,
  });

  /// Returns a deep copy of the Alien object.
  Alien clone() {
    // We can safely reference the Player object, as player identity/properties
    // do not change during the game.
    return Alien._clone(
      player: player,
      x: x,
      y: y,
    );
  }
}
