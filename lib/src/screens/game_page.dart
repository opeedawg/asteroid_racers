import 'package:asteroid_racers/src/ai/ai_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:asteroid_racers/src/controllers/feedback_controller.dart';
import 'package:asteroid_racers/src/controllers/game_controller.dart';
import 'package:asteroid_racers/src/models/enums.dart';
import 'package:asteroid_racers/src/models/game_state.dart';
import 'package:asteroid_racers/src/models/player.dart';
import 'package:asteroid_racers/src/models/alien.dart';
import 'package:asteroid_racers/src/models/game_feedback.dart';
import 'package:asteroid_racers/src/models/game_settings.dart';

class GamePage
    extends
        StatefulWidget {
  final GameSettings settings;

  const GamePage({
    required this.settings,
    super.key,
  });

  @override
  State<
    GamePage
  >
  createState() => _GamePageState();
}

class _GamePageState
    extends
        State<
          GamePage
        > {
  late GameController _controller;
  late FeedbackController _feedback;
  late AIEngine _aiEngine;
  bool _isInitializing = true;

  int _selectedColumn = 0;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _focusNode.requestFocus();
  }

  void _initializeGame() async {
    // Use the Player objects already passed to the widget.
    final Player player1 = widget.settings.player1;
    final Player player2 = widget.settings.player2;

    final gameState = GameState.newGame(
      boardSize: widget.settings.boardSize,
      player1: player1,
      player2: player2,
    );

    // AI Engine Initialization
    final AIDifficulty difficulty =
        player2.type ==
            PlayerType.ai
        ? player2.difficulty!
        : AIDifficulty.normal;

    _aiEngine = AIEngine(
      difficulty,
    );

    // Controller Initialization
    _feedback = FeedbackController();
    _controller = GameController(
      gameState: gameState,
      feedback: _feedback,
      gameSpeed: widget.settings.gameSpeed,
      aiEngine: _aiEngine, // Pass the AI Engine
    );

    // Set up listeners
    _controller.addListener(
      _onGameStateChanged,
    );
    _feedback.stream.listen(
      (
        feedback,
      ) => _onFeedback(
        feedback,
      ),
    );

    // Schedule settling *after* the first frame is built
    WidgetsBinding.instance.addPostFrameCallback(
      (
        _,
      ) async {
        if (mounted) {
          await _controller.settleBoard();
          _findNextAvailableLever(
            1,
          );

          setState(
            () {
              _isInitializing = false;
            },
          );

          // --- START AI TURN IF NEEDED ---
          if (_controller.gameState.currentPlayer.type ==
              PlayerType.ai) {
            _controller.handleAITurn();
          }
        }
      },
    );
  }

  // --- UI Logic Methods ---

  void _onGameStateChanged() {
    if (_isInitializing) return;
    setState(
      () {
        // The AI turn handling is now called within the GameController itself,
        // so this setState() is just for the UI rebuild.
      },
    );
  }

  void _onFeedback(
    GameFeedback feedback,
  ) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).hideCurrentSnackBar();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            feedback.message,
          ),
          backgroundColor:
              (feedback.type ==
                  FeedbackType.failure)
              ? Colors.redAccent
              : Colors.blueGrey,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.removeListener(
      _onGameStateChanged,
    );
    _feedback.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // --- Keyboard Event Handler ---
  void _handleKeyEvent(
    KeyEvent event,
  ) {
    if (_controller.isProcessingMove ||
        event
            is! KeyDownEvent)
      return;

    if (event.logicalKey ==
        LogicalKeyboardKey.arrowLeft) {
      _findNextAvailableLever(
        -1,
      );
    } else if (event.logicalKey ==
        LogicalKeyboardKey.arrowRight) {
      _findNextAvailableLever(
        1,
      );
    } else if (event.logicalKey ==
        LogicalKeyboardKey.arrowUp) {
      _controller.makeMove(
        _selectedColumn,
        MoveDirection.up,
      );
    } else if (event.logicalKey ==
        LogicalKeyboardKey.arrowDown) {
      _controller.makeMove(
        _selectedColumn,
        MoveDirection.down,
      );
    }
  }

  /// Finds the next available lever to the left or right.
  void _findNextAvailableLever(
    int direction,
  ) {
    final int width = _controller.gameState.width;
    int currentColumn = _selectedColumn;

    for (
      int i = 0;
      i <
          width;
      i++
    ) {
      currentColumn =
          (currentColumn +
              direction +
              width) %
          width;
      final LeverState state = GameController.getLeverState(
        currentColumn,
        _controller.gameState,
      );
      if (state ==
          LeverState.available) {
        setState(
          () {
            _selectedColumn = currentColumn;
          },
        );
        return;
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Asteroid Racers - Turn: ${_controller.gameState.currentPlayer.namerTag}",
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isInitializing)
                const Padding(
                  padding: EdgeInsets.all(
                    32.0,
                  ),
                  child: CircularProgressIndicator(),
                ),
              if (!_isInitializing) ...[
                _buildScoreDebugPanel(),
                ..._buildBoardWidgets(),
                const SizedBox(
                  height: 20,
                ),
                _buildLeverRow(),
                _buildSelectorRow(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // --- Board Renderer ---
  List<
    Widget
  >
  _buildBoardWidgets() {
    final List<
      Widget
    >
    rows = [];
    final board = _controller.gameState.board;
    final aliens = _controller.gameState.aliens;
    final width = _controller.gameState.width;
    final height = _controller.gameState.height;
    const double cellWidth = 24.0;

    final Player p1 = widget.settings.player1;
    final Player p2 = widget.settings.player2;

    for (
      int y = 0;
      y <
          height;
      y++
    ) {
      final List<
        Widget
      >
      cells = [];
      for (
        int x = 0;
        x <
            width;
        x++
      ) {
        final alien = aliens.firstWhere(
          (
            a,
          ) =>
              a.x ==
                  x &&
              a.y ==
                  y,
          orElse: () => Alien(
            player: Player.ai(
              difficulty: AIDifficulty.easy,
            ),
            x: -1,
            y: -1,
          ),
        );
        String cellContent = ".";
        Color cellColor = Colors.grey;
        if (alien.x !=
            -1) {
          cellContent = "B";
          cellColor = Colors.blueAccent;
          if (alien.player.id ==
              p2.id) {
            // Compare against P2's actual ID
            cellContent = "R";
            cellColor = Colors.redAccent;
          }
        } else if (board[y][x] ==
            TileType.asteroid) {
          cellContent = "A";
          cellColor = Colors.brown[400]!;
        }
        cells.add(
          Container(
            width: cellWidth,
            alignment: Alignment.center,
            child: Text(
              cellContent,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: cellColor,
              ),
            ),
          ),
        );
      }
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: cells,
        ),
      );
    }
    return rows;
  }

  // --- Lever Row Renderer ---
  Widget _buildLeverRow() {
    final List<
      Widget
    >
    levers = [];
    final width = _controller.gameState.width;
    final gameState = _controller.gameState;
    const double cellWidth = 24.0;

    for (
      int x = 0;
      x <
          width;
      x++
    ) {
      final state = GameController.getLeverState(
        x,
        gameState,
      );
      String leverContent = " ";
      Color leverColor = Colors.grey;
      if (state ==
          LeverState.available) {
        leverContent = "|";
        leverColor = Colors.greenAccent;
      } else if (state ==
          LeverState.locked) {
        leverContent = "|X|";
        leverColor = Colors.redAccent;
      }
      levers.add(
        Container(
          width: cellWidth,
          alignment: Alignment.center,
          child: Text(
            leverContent,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: leverColor,
            ),
          ),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: levers,
    );
  }

  // --- Selector Row Renderer ---
  Widget _buildSelectorRow() {
    final List<
      Widget
    >
    selectors = [];
    final width = _controller.gameState.width;
    const double cellWidth = 24.0;

    for (
      int x = 0;
      x <
          width;
      x++
    ) {
      String content = " ";
      if (x ==
          _selectedColumn) {
        content = "^"; // Our "hand" selector
      }
      selectors.add(
        Container(
          width: cellWidth,
          alignment: Alignment.center,
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: selectors,
    );
  }

  // --- Score Debug Panel ---
  Widget _buildScoreDebugPanel() {
    final Player p1 = widget.settings.player1;
    final Player p2 = widget.settings.player2;

    final double scoreDiff = _aiEngine.getCurrentScoreDifference(
      _controller.gameState,
    );

    String winningPlayer;
    Color winningColor;

    if (scoreDiff >
        0) {
      winningPlayer = p1.namerTag;
      winningColor = Colors.blueAccent;
    } else if (scoreDiff <
        0) {
      winningPlayer = p2.namerTag;
      winningColor = Colors.redAccent;
    } else {
      winningPlayer = 'TIE';
      winningColor = Colors.white;
    }

    final int p1Score =
        _controller.gameState.scores[p1.id] ??
        0;
    final int p2Score =
        _controller.gameState.scores[p2.id] ??
        0;

    return Padding(
      padding: const EdgeInsets.all(
        16.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Blue Score: $p1Score',
                style: const TextStyle(
                  color: Colors.blueAccent,
                ),
              ),
              Text(
                'Red Score: $p2Score',
                style: const TextStyle(
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            'Heuristic Winner: $winningPlayer',
            style: TextStyle(
              color: winningColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            'Raw Diff: ${scoreDiff.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
