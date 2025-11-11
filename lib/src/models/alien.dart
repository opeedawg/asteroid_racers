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
}
