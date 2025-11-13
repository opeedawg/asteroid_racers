import 'dart:async'; // Required for Future.delayed and async/await
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:asteroid_racers/src/controllers/feedback_controller.dart';
import 'package:asteroid_racers/src/controllers/game_controller.dart';
import 'package:asteroid_racers/src/models/enums.dart';
import 'package:asteroid_racers/src/models/game_state.dart';
import 'package:asteroid_racers/src/models/player.dart';
import 'package:asteroid_racers/src/models/alien.dart';
import 'package:asteroid_racers/src/models/game_feedback.dart';
import 'package:asteroid_racers/src/models/game_settings.dart'; // NEW/RETAINED

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
    // 1. Create Players and GameState
    final player1 = Player(
      namerTag: "Player 1", // Use namerTag
    );
    final player2 = Player(
      namerTag: "Player 2", // Use namerTag
    );

    final gameState = GameState.newGame(
      boardSize: widget.settings.boardSize,
      player1: player1,
      player2: player2,
    );

    // 2. Create the controllers
    _feedback = FeedbackController();

    // --- FIX: Pass gameSpeed from settings ---
    _controller = GameController(
      gameState: gameState,
      feedback: _feedback,
      gameSpeed: widget.settings.gameSpeed,
    );
    // ----------------------------------------

    // 3. Set up listeners
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

    // 4. Schedule settling *after* the first frame is built
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
        }
      },
    );
  }

  // --- UI Logic Methods ---

  void _onGameStateChanged() {
    if (_isInitializing) return;
    setState(
      () {},
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
      // Using RawKeyboardListener for wider OS compatibility
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            // Use namerTag here
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
            player: Player(
              namerTag: "temp",
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
          if (alien.player ==
              _controller.gameState.player2) {
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
}
