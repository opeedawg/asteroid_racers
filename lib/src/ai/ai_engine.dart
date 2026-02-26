import 'package:asteroid_racers/src/models/alien.dart';
import 'package:asteroid_racers/src/models/enums.dart';
import 'package:asteroid_racers/src/models/game_state.dart';
import 'package:asteroid_racers/src/controllers/game_controller.dart';
import 'package:asteroid_racers/src/models/player.dart';
import 'dart:math';

/// Represents a single, legal move option (column and direction).
class Move {
  final int column;
  final MoveDirection direction;

  const Move(
    this.column,
    this.direction,
  );

  @override
  String toString() => 'Move(col: $column, dir: $direction)';
}

class AIEngine {
  final AIDifficulty difficulty;

  AIEngine(
    this.difficulty,
  );

  // --- CORE PUBLIC METHOD ---

  /// Calculates the best possible move for the current player using Minimax.
  Move findBestMove(
    GameState gameState,
  ) {
    final int searchDepth = _getSearchDepth();

    // Alpha (initial lowest possible score) and Beta (initial highest possible score)
    const double initialAlpha = double.negativeInfinity;
    const double initialBeta = double.infinity;

    // The main call to the recursive function
    final MoveScore bestResult = _minimax(
      gameState,
      searchDepth,
      initialAlpha,
      initialBeta,
      isMaximizingPlayer: true, // The AI is always maximizing at the root node
    );

    // Ensure a move was found (should always happen if getPossibleMoves > 0)
    return bestResult.move ??
        getPossibleMoves(
          gameState,
        ).first;
  }

  /// Recursively searches the game tree to find the optimal score.
  MoveScore _minimax(
    GameState gameState,
    int depth,
    double alpha,
    double beta, {
    required bool isMaximizingPlayer,
  }) {
    // Determine current player for this search depth (for scoring)
    final Player maximizingPlayer = gameState.player2; // AI is always P2

    // --- BASE CASE 1: Depth reached ---
    if (depth ==
        0) {
      // Return the score of the current board state (Heuristic evaluation)
      return MoveScore(
        null,
        getBoardScore(
          gameState,
          maximizingPlayer,
        ),
      );
    }

    // --- BASE CASE 2: Game Over (Victory/Draw) ---
    // If all pieces for one side are scored, the game is over.
    // Score should be overwhelmingly large/small.
    // (Skipping this complex check for now, focusing on depth limit)

    final List<
      Move
    >
    possibleMoves = getPossibleMoves(
      gameState,
    );

    // If no moves are possible (a potential game-over state)
    if (possibleMoves.isEmpty) {
      return MoveScore(
        null,
        getBoardScore(
          gameState,
          maximizingPlayer,
        ),
      );
    }

    Move? bestMove;

    if (isMaximizingPlayer) {
      // --- MAXIMIZING PLAYER (AI / RED) ---
      double maxEval = double.negativeInfinity;

      for (final move in possibleMoves) {
        // 1. Clone the state
        final GameState nextState = gameState.clone();

        // 2. Simulate the move
        _simulateMove(
          nextState,
          move,
        );

        // 3. Recurse
        final MoveScore eval = _minimax(
          nextState,
          depth -
              1,
          alpha,
          beta,
          isMaximizingPlayer: false,
        );

        // Update maxEval and bestMove
        if (eval.score >
            maxEval) {
          maxEval = eval.score;
          bestMove = move;
        }
        alpha = max(
          alpha,
          maxEval,
        ); // <-- Using max() from dart:math

        // Alpha-Beta Pruning
        if (beta <=
            alpha) {
          break;
        }
      }
      return MoveScore(
        bestMove,
        maxEval,
      );
    } else {
      // --- MINIMIZING PLAYER (HUMAN / BLUE) ---
      double minEval = double.infinity;

      for (final move in possibleMoves) {
        final GameState nextState = gameState.clone();
        _simulateMove(
          nextState,
          move,
        );

        // Recurse
        final MoveScore eval = _minimax(
          nextState,
          depth -
              1,
          alpha,
          beta,
          isMaximizingPlayer: true,
        );

        // Update minEval and beta
        if (eval.score <
            minEval) {
          minEval = eval.score;
        }
        beta = min(
          beta,
          minEval,
        ); // <-- Using min() from dart:math

        // Alpha-Beta Pruning
        if (beta <=
            alpha) {
          break;
        }
      }
      return MoveScore(
        bestMove,
        minEval,
      );
    }
  }

  /// Synchronously applies the move and runs the physics cycle on the cloned state.
  void _simulateMove(
    GameState gameState,
    Move move,
  ) {
    // This must replicate GameController's makeMove and _runPhysicsCycle but synchronously.

    // 1. Shift Column (Synchronous version of GameController._shiftColumn)
    _simulateShiftColumn(
      gameState,
      move.column,
      move.direction,
    );

    // 2. Run Physics Cycle (Synchronous version of GameController._runPhysicsCycle)
    _simulatePhysicsCycle(
      gameState,
    );

    // 3. Update Turn State (Required for the next depth level)
    gameState.lastMovedColumn = move.column;
    gameState.currentPlayer =
        (gameState.currentPlayer ==
            gameState.player1)
        ? gameState.player2
        : gameState.player1;
  }

  /// Synchronously shifts a single column (board tiles and aliens) up or down,
  /// wrapping around in a "teleport".
  void _simulateShiftColumn(
    GameState gameState,
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
            height;
      } else {
        // Direction is Up
        alien.y =
            (alien.y -
            1);
        if (alien.y <
            0) {
          alien.y =
              height -
              1;
        }
      }
    }
  }

  /// Synchronously runs the physics loop until the board is stable.
  void _simulatePhysicsCycle(
    GameState gameState,
  ) {
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
      if (_simulateApplyGravity(
        gameState,
      )) {
        actionWasTaken = true;
      }

      // 2. MOVER PASS
      if (_simulateMoveAliens(
        gameState,
        mover,
      )) {
        actionWasTaken = true;
      }

      // 3. OPPONENT PASS
      if (_simulateMoveAliens(
        gameState,
        otherPlayer,
      )) {
        actionWasTaken = true;
      }
    } while (actionWasTaken);

    // 4. SCORE (Simulated)
    _simulateCheckAndScoreAliens(
      gameState,
    );
  }

  /// Synchronous version of _applyGravity (Returns bool)
  bool _simulateApplyGravity(
    GameState gameState,
  ) {
    bool anAlienFell = false;
    do {
      bool thisPassFell = false;
      final sortedAliens =
          List<
            Alien
          >.from(
            gameState.aliens,
          );
      // Note: The sort order is crucial for falling stacks
      sortedAliens.sort(
        (
          a,
          b,
        ) => b.y.compareTo(
          a.y,
        ),
      );

      for (final alien in sortedAliens) {
        if (_simulateCanAlienFall(
          gameState,
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

  /// Synchronous version of _moveAliens (Returns bool)
  bool _simulateMoveAliens(
    GameState gameState,
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

    // Note: The sort order is crucial for running chains
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
      );
    } else {
      // P2 (moving left)
      playerAliens.sort(
        (
          a,
          b,
        ) => a.x.compareTo(
          b.x,
        ),
      );
    }

    for (final alien in playerAliens) {
      if (_simulateCanAlienMove(
        gameState,
        alien,
        direction,
      )) {
        alien.x += direction;
        anyAlienMoved = true;
      }
    }
    return anyAlienMoved;
  }

  /// Synchronous version of _checkAndScoreAliens
  void _simulateCheckAndScoreAliens(
    GameState gameState,
  ) {
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

    // Update the cloned score map
    gameState.scores[gameState.player1.id] =
        (gameState.scores[gameState.player1.id] ??
            0) +
        scoredP1.length;
    gameState.scores[gameState.player2.id] =
        (gameState.scores[gameState.player2.id] ??
            0) +
        scoredP2.length;

    // Remove them from the active game list (in the clone)
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

  // --- Final Boolean Checkers (Unchanged Logic) ---

  bool _simulateCanAlienFall(
    GameState gameState,
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

  bool _simulateCanAlienMove(
    GameState gameState,
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

  // ----------------------------------------------------
  // --- CORE MINIMAX HELPER FUNCTIONS ---
  // ----------------------------------------------------

  /// [STUB] Recursively searches the game tree to find the optimal score.
  /// This will implement the Minimax algorithm with Alpha-Beta Pruning.
  // MoveScore _minimax(GameState gameState, int depth) {
  //   // Return a placeholder score for now
  //   return MoveScore(null, 0.0);
  // }

  /// Evaluates the strategic value of a board state for the Maximizing Player.
  double getBoardScore(
    GameState gameState,
    Player maximizingPlayer,
  ) {
    // Use a negative multiplier for the minimizing player
    final Player minimizingPlayer =
        (maximizingPlayer ==
            gameState.player1)
        ? gameState.player2
        : gameState.player1;

    double totalScore = 0.0;

    final int maxPossiblePieceScore =
        gameState.width *
        10;
    final double piecesRemainingWeight =
        maxPossiblePieceScore *
        2.0;

    // --- 1. Score Maximizing Player (Positive) ---
    final List<
      Alien
    >
    maxPlayerAliens = gameState.aliens
        .where(
          (
            a,
          ) =>
              a.player ==
              maximizingPlayer,
        )
        .toList();

    for (final alien in maxPlayerAliens) {
      totalScore += _getPieceScore(
        gameState,
        alien,
      );
    }

    // --- 2. Score Minimizing Player (Negative) ---
    final List<
      Alien
    >
    minPlayerAliens = gameState.aliens
        .where(
          (
            a,
          ) =>
              a.player ==
              minimizingPlayer,
        )
        .toList();

    for (final alien in minPlayerAliens) {
      // Subtract the minimizing player's score
      totalScore -= _getPieceScore(
        gameState,
        alien,
      );
    }

    // --- B. PIECES REMAINING (Negative for Min Player, Positive for Max Player) ---
    // Fewer pieces is better (they are scored in the scoring map, but we add a penalty here)

    // This logic must be done based on the total remaining aliens on the board.
    // The goal is actually to have fewer aliens left *on the board* because they are in the goal.

    // The score calculation for "Pieces Remaining" should be:
    // (Total starting aliens - Current aliens) * Weight.

    // Since we don't track who is in the goal here, let's use the agreed upon weight
    // as a strong penalty for having pieces still on the board.

    totalScore -=
        maxPlayerAliens.length *
        piecesRemainingWeight;
    totalScore +=
        minPlayerAliens.length *
        piecesRemainingWeight; // Minimizing player is penalized for having pieces left

    return totalScore;
  }

  // Add this helper method inside the AIEngine class:
  double _getPieceScore(
    GameState gameState,
    Alien alien,
  ) {
    final int W = gameState.width;
    final int H = gameState.height;

    // --- A. GOAL DISTANCE (Primary Score) ---
    // If player 1 (moving right): score increases as X increases.
    // If player 2 (moving left): score increases as X decreases.

    // Max X value is W-1. Max score = 10 * W.
    // Player 1 Goal Column Index: W - 1
    // Player 2 Goal Column Index: 0

    final int goalColumn =
        (alien.player ==
            gameState.player1)
        ? W -
              1
        : 0;
    final int distanceToGoal =
        (goalColumn -
                alien.x)
            .abs();

    // Example: W=19. Max Score = 190. Furthest alien (x=0) is 18 columns away from goal (18).
    // Furthest score is (W-1) * 10. Closest score is 1 * 10.

    final double goalScore =
        (W -
            distanceToGoal) *
        10.0;

    // --- C. VERTICAL HEIGHT BONUS ---
    // Bonus granted for vertical height, where the bottom is best (H-1).
    // Vertical Score: 1 point per row from the bottom.
    // A perfect score requires being at the bottom row (H-1).
    // The bottom-most row is y = H-1.
    final double verticalScore =
        (H -
            1 -
            alien.y) *
        1.0;

    // --- D. STACK BONUS ---
    // Calculate if any other alien is directly above this one.
    // We'll give the stack bonus only to the alien *below* the piece(s).
    final bool hasPieceAbove = gameState.aliens.any(
      (
        other,
      ) =>
          other !=
              alien &&
          other.x ==
              alien.x &&
          other.y ==
              alien.y -
                  1,
    );
    final double stackBonus = hasPieceAbove
        ? 50.0
        : 0.0; // Fixed small bonus

    return goalScore +
        verticalScore +
        stackBonus;
  }

  // --- UTILITY FUNCTIONS ---

  /// Calculates all currently legal moves for the given gameState.
  List<
    Move
  >
  getPossibleMoves(
    GameState gameState,
  ) {
    final List<
      Move
    >
    legalMoves = [];
    final int width = gameState.width;

    for (
      int column = 0;
      column <
          width;
      column++
    ) {
      final LeverState state = GameController.getLeverState(
        column,
        gameState,
      );

      if (state ==
          LeverState.available) {
        // Add both UP and DOWN moves for this column
        legalMoves.add(
          Move(
            column,
            MoveDirection.up,
          ),
        );
        legalMoves.add(
          Move(
            column,
            MoveDirection.down,
          ),
        );
      }
    }
    return legalMoves;
  }

  /// Returns the score difference (Max Player's score - Min Player's score).
  /// This is a public method primarily for UI debugging.
  double getCurrentScoreDifference(
    GameState gameState,
  ) {
    // We use Player 1 as the default maximizing player for display purposes
    final Player player1 = gameState.player1;
    final Player player2 = gameState.player2;

    // Call the core heuristic function
    final double p1Score = getBoardScore(
      gameState,
      player1,
    );
    final double p2Score = getBoardScore(
      gameState,
      player2,
    );

    return p1Score -
        p2Score;
  }

  /// Maps AIDifficulty enum to a search depth integer.
  int _getSearchDepth() {
    switch (difficulty) {
      case AIDifficulty.master:
        return 7; // Deepest, slowest, strongest
      case AIDifficulty.veteran:
        return 5;
      case AIDifficulty.normal:
        return 3;
      case AIDifficulty.easy:
        return 1; // Shallowest, fastest, weakest
    }
  }
}

// --- Placeholder for Minimax Return Type ---
class MoveScore {
  final Move? move;
  final double score;

  MoveScore(
    this.move,
    this.score,
  );
}
