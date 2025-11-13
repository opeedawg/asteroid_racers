import 'package:asteroid_racers/src/models/game_speed.dart';
import 'package:flutter/foundation.dart';
import 'package:asteroid_racers/src/controllers/feedback_controller.dart';
import 'package:asteroid_racers/src/models/alien.dart';
import 'package:asteroid_racers/src/models/game_state.dart';
import 'package:asteroid_racers/src/models/enums.dart';
import 'package:asteroid_racers/src/models/player.dart';

class GameController
    with
        ChangeNotifier {
  GameState gameState;
  final FeedbackController feedback;
  // Flag to prevent double-tapping while physics is running
  bool _isProcessingMove = false;
  bool get isProcessingMove => _isProcessingMove;
  final GameSpeedLevel gameSpeed;

  GameController({
    required this.gameState,
    required this.feedback,
    required this.gameSpeed,
  });

  /// Runs the physics engine once to "settle" the board.
  Future<
    void
  >
  settleBoard() async {
    // <--- ADD async and Future<void>
    await _runPhysicsCycle(); // <--- ADD await
    notifyListeners();
  }

  /// Attempts to make a move for the currently active player.
  /// This method is now asynchronous.
  Future<
    bool
  >
  makeMove(
    int column,
    MoveDirection direction,
  ) async {
    // 1. Check Move Legality & Global Lock
    if (_isProcessingMove) return false;

    final LeverState state = getLeverState(
      column,
      gameState,
    );

    if (state ==
        LeverState.unavailable) {
      feedback.add(
        FeedbackType.failure,
        "Player has no alien in that column.",
      );
      return false;
    }
    if (state ==
        LeverState.locked) {
      feedback.add(
        FeedbackType.failure,
        "Cannot move the same column twice.",
      );
      return false;
    }

    _isProcessingMove = true; // Lock the controls
    feedback.add(
      FeedbackType.success,
      "Move accepted.",
    );

    // --- Physics Step 1: Shift Column ---
    _shiftColumn(
      column,
      direction,
    );
    notifyListeners(); // Render the column shift immediately
    await Future.delayed(
      Duration(
        milliseconds: GameSpeed.getDelay(
          gameSpeed,
        ),
      ),
    );

    // --- Physics Step 2: Run the full settle logic ---
    await _runPhysicsCycle();

    // 3. --- UPDATE GAME STATE FOR NEXT TURN ---
    gameState.lastMovedColumn = column;
    gameState.currentPlayer =
        (gameState.currentPlayer ==
            gameState.player1)
        ? gameState.player2
        : gameState.player1;

    _isProcessingMove = false; // Unlock controls
    notifyListeners(); // Final render and turn update
    return true;
  }

  /// Runs the 4-step physics/settle process until the board is completely stable.
  Future<
    void
  >
  _runPhysicsCycle() async {
    final Player mover = gameState.currentPlayer;
    final Player otherPlayer =
        (mover ==
            gameState.player1)
        ? gameState.player2
        : gameState.player1;

    bool actionWasTaken;
    do {
      actionWasTaken = false;

      // 1. GRAVITY PASS
      if (_applyGravity()) {
        actionWasTaken = true;
      }

      // 2. MOVER PASS
      if (_moveAliens(
        mover,
      )) {
        actionWasTaken = true;
      }

      // 3. OPPONENT PASS
      if (_moveAliens(
        otherPlayer,
      )) {
        actionWasTaken = true;
      }

      // If any action was taken, render the new state and wait.
      if (actionWasTaken) {
        notifyListeners();
        await Future.delayed(
          Duration(
            milliseconds: GameSpeed.getDelay(
              gameSpeed,
            ),
          ),
        );
      }
    } while (actionWasTaken);

    // 4. SCORE
    _checkAndScoreAliens();
  }
  // --- Private Helper Methods (The "Physics") ---

  /// 1. SHIFT COLUMN (Returns void)
  void _shiftColumn(
    int column,
    MoveDirection direction,
  ) {
    final int height = gameState.height;

    // --- Shift the Board (Asteroids) ---
    if (direction ==
        MoveDirection.down) {
      final TileType bottomTile =
          gameState.board[height -
              1][column];
      for (
        int y =
            height -
            1;
        y >
            0;
        y--
      ) {
        gameState.board[y][column] =
            gameState.board[y -
                1][column];
      }
      gameState.board[0][column] = bottomTile;
    } else {
      // Direction is Up
      final TileType topTile = gameState.board[0][column];
      for (
        int y = 0;
        y <
            height -
                1;
        y++
      ) {
        gameState.board[y][column] =
            gameState.board[y +
                1][column];
      }
      gameState.board[height -
              1][column] =
          topTile;
    }

    // --- Shift Aliens in that Column ---
    final aliensInColumn = gameState.aliens.where(
      (
        a,
      ) =>
          a.x ==
          column,
    );
    for (final alien in aliensInColumn) {
      if (direction ==
          MoveDirection.down) {
        alien.y =
            (alien.y +
                1) %
            height; // Modulo handles the wrap
      } else {
        // Direction is Up
        alien.y =
            (alien.y -
            1);
        if (alien.y <
            0) {
          alien.y =
              height -
              1; // Handle the wrap manually
        }
      }
    }
  }

  /// 2. APPLY GRAVITY (Returns bool)
  /// Returns 'true' if any alien fell.
  bool _applyGravity() {
    bool anAlienFell = false;
    do {
      bool thisPassFell = false;
      final sortedAliens =
          List<
            Alien
          >.from(
            gameState.aliens,
          );
      sortedAliens.sort(
        (
          a,
          b,
        ) => b.y.compareTo(
          a.y,
        ),
      ); // Sort bottom-up

      for (final alien in sortedAliens) {
        if (_canAlienFall(
          alien,
        )) {
          alien.y++;
          thisPassFell = true;
          anAlienFell = true;
        }
      }
      if (!thisPassFell) break;
    } while (true);

    return anAlienFell;
  }

  /// Helper for gravity.
  bool _canAlienFall(
    Alien alien,
  ) {
    final int targetY =
        alien.y +
        1;
    if (targetY >=
        gameState.height) {
      return false;
    }
    if (gameState.board[targetY][alien.x] ==
        TileType.asteroid) {
      return false;
    }
    final isBlockedByAlien = gameState.aliens.any(
      (
        other,
      ) =>
          other !=
              alien &&
          other.x ==
              alien.x &&
          other.y ==
              targetY,
    );
    if (isBlockedByAlien) return false;
    return true;
  }

  /// 3. MOVE ALIENS (Returns bool)
  /// Returns 'true' if any alien moved one space.
  bool _moveAliens(
    Player player,
  ) {
    final int direction =
        (player ==
            gameState.player1)
        ? 1
        : -1;
    bool anyAlienMoved = false;

    final playerAliens = gameState.aliens
        .where(
          (
            a,
          ) =>
              a.player ==
              player,
        )
        .toList();

    if (direction ==
        1) {
      // P1 (moving right)
      playerAliens.sort(
        (
          a,
          b,
        ) => b.x.compareTo(
          a.x,
        ),
      ); // Right-most first
    } else {
      // P2 (moving left)
      playerAliens.sort(
        (
          a,
          b,
        ) => a.x.compareTo(
          b.x,
        ),
      ); // Left-most first
    }

    for (final alien in playerAliens) {
      if (_canAlienMove(
        alien,
        direction,
      )) {
        alien.x += direction;
        anyAlienMoved = true;
      }
    }

    return anyAlienMoved;
  }

  /// Helper for movement.
  bool _canAlienMove(
    Alien alien,
    int direction,
  ) {
    final int targetX =
        alien.x +
        direction;
    final int targetY = alien.y;
    if (alien.x <
            0 ||
        alien.x >=
            gameState.width) {
      return false;
    }
    if (targetX <
            0 ||
        targetX >=
            gameState.width) {
      return true;
    }
    if (gameState.board[targetY][targetX] ==
        TileType.asteroid) {
      return false;
    }
    final isBlockedByAlien = gameState.aliens.any(
      (
        other,
      ) =>
          other !=
              alien &&
          other.x ==
              targetX &&
          other.y ==
              targetY,
    );
    if (isBlockedByAlien) return false;
    return true;
  }

  /// 4. CHECK AND SCORE ALIENS (Returns void)
  void _checkAndScoreAliens() {
    final List<
      Alien
    >
    scoredP1 = gameState.aliens
        .where(
          (
            a,
          ) =>
              a.player ==
                  gameState.player1 &&
              a.x >=
                  gameState.width,
        )
        .toList();
    final List<
      Alien
    >
    scoredP2 = gameState.aliens
        .where(
          (
            a,
          ) =>
              a.player ==
                  gameState.player2 &&
              a.x <
                  0,
        )
        .toList();

    gameState.scores[gameState.player1.id] =
        (gameState.scores[gameState.player1.id] ??
            0) +
        scoredP1.length;
    gameState.scores[gameState.player2.id] =
        (gameState.scores[gameState.player2.id] ??
            0) +
        scoredP2.length;

    if (scoredP1.isNotEmpty) {
      feedback.add(
        FeedbackType.info,
        "Player 1 scored ${scoredP1.length} aliens!",
      );
    }
    if (scoredP2.isNotEmpty) {
      feedback.add(
        FeedbackType.info,
        "Player 2 scored ${scoredP2.length} aliens!",
      );
    }
    gameState.aliens.removeWhere(
      (
        a,
      ) =>
          a.x >=
              gameState.width ||
          a.x <
              0,
    );
  }

  // --- STATIC HELPER FOR THE UI ---
  static LeverState getLeverState(
    int column,
    GameState gameState,
  ) {
    final bool hasAlienInColumn = gameState.aliens.any(
      (
        a,
      ) =>
          a.player ==
              gameState.currentPlayer &&
          a.x ==
              column,
    );
    if (!hasAlienInColumn) return LeverState.unavailable;

    if (column !=
        gameState.lastMovedColumn) {
      return LeverState.available;
    }

    final allOperableColumns = gameState.aliens
        .where(
          (
            a,
          ) =>
              a.player ==
              gameState.currentPlayer,
        )
        .map(
          (
            a,
          ) => a.x,
        )
        .toSet();

    if (allOperableColumns.length ==
        1) {
      return LeverState.available; // Exception
    } else {
      return LeverState.locked;
    }
  }
}
