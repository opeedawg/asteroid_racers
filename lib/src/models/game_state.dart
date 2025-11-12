import 'dart:math'; // Import for Random
import 'package:asteroid_racers/src/models/alien.dart';
import 'package:asteroid_racers/src/models/enums.dart';
import 'package:asteroid_racers/src/models/player.dart';

class GameState {
  // --- Properties ---
  int width;
  int height;
  int alienCount;
  final BoardSize boardSize;
  late List<
    List<
      TileType
    >
  >
  board;
  late List<
    Alien
  >
  aliens;
  final Player player1;
  final Player player2;
  late Player currentPlayer;
  late Map<
    String,
    int
  >
  scores;
  late int lastMovedColumn;

  // --- Random Instance ---
  final _random = Random();

  // --- Named Constructor ---
  GameState.newGame({
    required this.boardSize,
    required this.player1,
    required this.player2,
    Player? startingPlayer,
  }) : width = _getWidthForSize(
         boardSize,
       ),
       height = _getHeightForSize(
         boardSize,
       ),
       alienCount = _getAlienCountSize(
         boardSize,
       ) {
    scores = {
      player1.id: 0,
      player2.id: 0,
    };

    currentPlayer =
        startingPlayer ??
        player1;
    lastMovedColumn = -1;

    _generateBoard();
    _placeAliens(
      alienCount,
    );
  }

  // --- Board Generation Logic ---
  void _generateBoard() {
    board = List.generate(
      height,
      (
        _,
      ) => List.filled(
        width,
        TileType.empty,
      ),
    );

    final int centerColumn =
        (width /
                2)
            .floor();

    for (
      int x = 0;
      x <
          width;
      x++
    ) {
      // 1. Handle all fixed-pattern columns

      // Center: 2-1-2-1 pattern (A, A, E, A, A, E, ...)
      if (x ==
          centerColumn) {
        for (
          int y = 0;
          y <
              height;
          y++
        ) {
          board[y][x] =
              (y %
                      3 ==
                  0)
              ? TileType.empty
              : TileType.asteroid;
        }
        continue;
      }

      // Center-Adjacent AND Outer Columns: 1-2-1-2 pattern (E, A, A, E, A, A, ...)
      if (x ==
              centerColumn -
                  1 ||
          x ==
              centerColumn +
                  1 ||
          x ==
              0 ||
          x ==
              width -
                  1) {
        for (
          int y = 0;
          y <
              height;
          y++
        ) {
          board[y][x] =
              (y %
                      3 ==
                  0)
              ? TileType.asteroid
              : TileType.empty;
        }
        continue;
      }

      // 2. Handle the random columns
      int currentGap = 0;
      int currentAsteroidRun = 0;
      const int maxGap = 6;
      const int maxAsteroidRun = 8;

      for (
        int y = 0;
        y <
            height;
        y++
      ) {
        bool placeAsteroid = false;

        if (currentGap >=
            maxGap) {
          placeAsteroid = true;
        } else if (currentAsteroidRun >=
            maxAsteroidRun) {
          placeAsteroid = false;
        } else {
          placeAsteroid =
              _random.nextDouble() <
              0.6;
        }

        if (placeAsteroid) {
          board[y][x] = TileType.asteroid;
          currentGap = 0;
          currentAsteroidRun++;
        } else {
          board[y][x] = TileType.empty;
          currentGap++;
          currentAsteroidRun = 0;
        }
      }
    }
  }

  // --- Alien Placement Logic (Spread Out) ---
  void _placeAliens(
    int alienCount,
  ) {
    aliens = [];

    final int centerColumn =
        (width /
                2)
            .floor();

    // Player 1's territory (0 to center-1)
    int p1AliensPlaced = 0;
    while (p1AliensPlaced <
        alienCount) {
      final int x = _random.nextInt(
        centerColumn,
      );
      final int y = _random.nextInt(
        height,
      );

      final bool isOccupied =
          board[y][x] ==
              TileType.asteroid ||
          aliens.any(
            (
              a,
            ) =>
                a.x ==
                    x &&
                a.y ==
                    y,
          );

      if (!isOccupied) {
        aliens.add(
          Alien(
            player: player1,
            x: x,
            y: y,
          ),
        );
        p1AliensPlaced++;
      }
    }

    // Player 2's territory (center+1 to width-1)
    int p2AliensPlaced = 0;
    final int p2ZoneStartX =
        centerColumn +
        1;
    final int p2ZoneWidth =
        width -
        p2ZoneStartX;

    while (p2AliensPlaced <
        alienCount) {
      final int x =
          p2ZoneStartX +
          _random.nextInt(
            p2ZoneWidth,
          );
      final int y = _random.nextInt(
        height,
      );

      final bool isOccupied =
          board[y][x] ==
              TileType.asteroid ||
          aliens.any(
            (
              a,
            ) =>
                a.x ==
                    x &&
                a.y ==
                    y,
          );

      if (!isOccupied) {
        aliens.add(
          Alien(
            player: player2,
            x: x,
            y: y,
          ),
        );
        p2AliensPlaced++;
      }
    }
  }

  // --- Static Helper Methods ---
  static int _getAlienCountSize(
    BoardSize size,
  ) {
    switch (size) {
      case BoardSize.small:
        return 8;
      case BoardSize.regular:
        return 12;
      case BoardSize.large:
        return 16;
      case BoardSize.extraLarge:
        return 22;
    }
  }

  static int _getWidthForSize(
    BoardSize size,
  ) {
    switch (size) {
      case BoardSize.small:
        return 13;
      case BoardSize.regular:
        return 19;
      case BoardSize.large:
        return 25;
      case BoardSize.extraLarge:
        return 35;
    }
  }

  static int _getHeightForSize(
    BoardSize size,
  ) {
    switch (size) {
      case BoardSize.small:
        return 9;
      case BoardSize.regular:
        return 13;
      case BoardSize.large:
        return 15;
      case BoardSize.extraLarge:
        return 25;
    }
  }
}
