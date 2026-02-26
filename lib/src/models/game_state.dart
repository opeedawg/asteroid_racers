import 'dart:math'; // Import for Random
import 'package:asteroid_racers/src/models/alien.dart';
import 'package:asteroid_racers/src/models/enums.dart'; // Keep this for TileType!
import 'package:asteroid_racers/src/models/player.dart';

class GameState {
  // --- Properties ---
  int width;
  int height;
  int alienCount;
  final String boardSizeName; // Replaced BoardSize enum
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
  final Player player2; // Restored to represent the AI Opponent!
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
    required this.boardSizeName,
    required this.player1,
    required this.player2, // We will pass the AI player in from GamePage
    Player? startingPlayer,
  }) : width = _getWidthForSize(
         boardSizeName,
       ),
       height = _getHeightForSize(
         boardSizeName,
       ),
       alienCount = _getAlienCountSize(
         boardSizeName,
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

      // Center: 2-1-2-1 pattern
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

      // Center-Adjacent AND Outer Columns: 1-2-1-2 pattern
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
    String size,
  ) {
    switch (size) {
      case 'Small':
        return 8;
      case 'Regular':
        return 12;
      case 'Large':
        return 16;
      case 'Extra Large':
        return 22;
      default:
        return 12;
    }
  }

  static int _getWidthForSize(
    String size,
  ) {
    switch (size) {
      case 'Small':
        return 13;
      case 'Regular':
        return 19;
      case 'Large':
        return 25;
      case 'Extra Large':
        return 35;
      default:
        return 19;
    }
  }

  static int _getHeightForSize(
    String size,
  ) {
    switch (size) {
      case 'Small':
        return 9;
      case 'Regular':
        return 13;
      case 'Large':
        return 15;
      case 'Extra Large':
        return 25;
      default:
        return 13;
    }
  }

  // --- Cloning Logic ---
  GameState clone() {
    final newAliens = aliens
        .map(
          (
            a,
          ) => a.clone(),
        )
        .toList();
    final newBoard = board
        .map(
          (
            row,
          ) =>
              List<
                TileType
              >.from(
                row,
              ),
        )
        .toList();
    final newScores =
        Map<
          String,
          int
        >.from(
          scores,
        );

    return GameState._clone(
      this,
      newBoard,
      newAliens,
      newScores,
    );
  }

  GameState._clone(
    GameState source,
    List<
      List<
        TileType
      >
    >
    clonedBoard,
    List<
      Alien
    >
    clonedAliens,
    Map<
      String,
      int
    >
    clonedScores,
  ) : width = source.width,
      height = source.height,
      alienCount = source.alienCount,
      boardSizeName = source.boardSizeName,
      board = clonedBoard,
      aliens = clonedAliens,
      scores = clonedScores,
      currentPlayer = source.currentPlayer,
      lastMovedColumn = source.lastMovedColumn,
      player1 = source.player1,
      player2 = source.player2; // Successfully references the AI player property
}
