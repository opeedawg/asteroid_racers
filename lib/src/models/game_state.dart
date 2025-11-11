import 'dart:math'; // Import for Random
import 'package:asteroid_racers/src/models/alien.dart';
import 'package:asteroid_racers/src/models/enums.dart';
import 'package:asteroid_racers/src/models/player.dart';

class GameState {
  // --- Existing Properties ---
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

  // --- Add a Random instance ---
  final _random = Random();

  // --- Constructor ---
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

  // --- UPDATED BOARD GENERATION ---
  void _generateBoard() {
    // 1. Initialize an empty board
    board = List.generate(
      height,
      (
        _,
      ) => List.filled(
        width,
        TileType.empty,
      ),
    );

    // 2. Find the center column
    final int centerColumn =
        (width /
                2)
            .floor();

    // 3. Loop through every column (x)
    for (
      int x = 0;
      x <
          width;
      x++
    ) {
      // 4. Handle all fixed-pattern columns

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
        continue; // Go to the next column
      }

      // Center-Adjacent AND Outer Columns: 1-2-1-2 pattern (E, A, A, E, A, A, ...)
      if (x ==
              centerColumn -
                  1 ||
          x ==
              centerColumn +
                  1 ||
          x ==
              0 || // <-- FIX: First column
          x ==
              width -
                  1) {
        // <-- FIX: Last column
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
        continue; // Go to the next column
      }

      // 5. Handle the random columns
      int currentGap = 0;
      int currentAsteroidRun = 0; // <-- FIX: Max density check
      const int maxGap = 6; // Max empty spaces in a row
      const int maxAsteroidRun = 8; // <-- FIX: Max asteroids in a row

      for (
        int y = 0;
        y <
            height;
        y++
      ) {
        bool placeAsteroid = false;

        // Rule: Max gap of 6
        if (currentGap >=
            maxGap) {
          placeAsteroid = true;
        }
        // Rule: Max run of 8 asteroids
        else if (currentAsteroidRun >=
            maxAsteroidRun) {
          placeAsteroid = false;
        }
        // Otherwise, use our probability
        else {
          placeAsteroid =
              _random.nextDouble() <
              0.6;
        }

        if (placeAsteroid) {
          board[y][x] = TileType.asteroid;
          currentGap = 0;
          currentAsteroidRun++; // Increment asteroid run
        } else {
          board[y][x] = TileType.empty;
          currentGap++;
          currentAsteroidRun = 0; // Reset asteroid run
        }
      }
    }
  }

  void _placeAliens(
    int alienCount,
  ) {
    // 1. Initialize the list
    aliens = [];

    // 2. Define territories
    final int centerColumn =
        (width /
                2)
            .floor();

    // Player 1's territory (e.g., 0 to 8)
    int p1AliensPlaced = 0;
    while (p1AliensPlaced <
        alienCount) {
      // Find a random spot in the entire left-half
      final int x = _random.nextInt(
        centerColumn,
      ); // 0 to center-1
      final int y = _random.nextInt(
        height,
      );

      // Check if spot is empty
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

    // Player 2's territory (e.g., 10 to 18)
    int p2AliensPlaced = 0;
    final int p2ZoneStartX =
        centerColumn +
        1;
    final int p2ZoneWidth =
        width -
        p2ZoneStartX;

    while (p2AliensPlaced <
        alienCount) {
      // Find a random spot in the entire right-half
      final int x =
          p2ZoneStartX +
          _random.nextInt(
            p2ZoneWidth,
          );
      final int y = _random.nextInt(
        height,
      );

      // Check if spot is empty
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

  // --- Static Helper Methods (unchanged) ---
  static int _getAlienCountSize(
    BoardSize size,
  ) {
    switch (size) {
      case BoardSize.small:
        return 8;
      case BoardSize.regular:
        return 12; // The classic Mice Men size
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
        return 13; // Must be odd
      case BoardSize.regular:
        return 19; // The classic Mice Men size
      case BoardSize.large:
        return 25; // Must be odd
      case BoardSize.extraLarge:
        return 35; // Must be odd
    }
  }

  static int _getHeightForSize(
    BoardSize size,
  ) {
    switch (size) {
      case BoardSize.small:
        return 9;
      case BoardSize.regular:
        return 13; // The classic Mice Men size
      case BoardSize.large:
        return 15;
      case BoardSize.extraLarge:
        return 25;
    }
  }
}
