import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:asteroid_racers/src/ai/ai_engine.dart';
import 'package:asteroid_racers/src/controllers/feedback_controller.dart';
import 'package:asteroid_racers/src/controllers/game_controller.dart';
import 'package:asteroid_racers/src/models/enums.dart';
import 'package:asteroid_racers/src/models/game_state.dart';
import 'package:asteroid_racers/src/models/player.dart';
import 'package:asteroid_racers/src/models/alien.dart';
import 'package:asteroid_racers/src/models/game_feedback.dart';
import 'package:asteroid_racers/src/models/game_settings.dart';
import 'package:asteroid_racers/src/services/data_access.dart';
import 'package:asteroid_racers/src/widgets/game_header.dart';

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

  String _themeImagePath = 'assets/images/ThemeClassic.png';
  late Player _aiPlayer;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _focusNode.requestFocus();
  }

  void _initializeGame() async {
    final player1 = widget.settings.player1;
    final lookups = await DataAccess().getLookups(
      forceRefresh: false,
    );

    final boardSizeItem = lookups.firstWhere(
      (
        l,
      ) =>
          l.id ==
          widget.settings.boardSizeId,
    );
    final themeItem = lookups.firstWhere(
      (
        l,
      ) =>
          l.id ==
          widget.settings.themeId,
    );

    _themeImagePath = 'assets/images/Theme${themeItem.name}.png';

    _aiPlayer = Player.ai(
      difficulty: AIDifficulty.normal,
    );

    final gameState = GameState.newGame(
      boardSizeName: boardSizeItem.name,
      player1: player1,
      player2: _aiPlayer,
    );

    _aiEngine = AIEngine(
      AIDifficulty.normal,
    );
    _feedback = FeedbackController();

    final speedItem = lookups.firstWhere(
      (
        l,
      ) =>
          l.id ==
          widget.settings.gameSpeedId,
    );

    int calculateDelayMs(
      String speedName,
    ) {
      switch (speedName) {
        case 'Slow':
          return 800;
        case 'Fast':
          return 250;
        case 'Ludicrous':
          return 100;
        case 'Normal':
        default:
          return 500;
      }
    }

    final int engineDelay = calculateDelayMs(
      speedItem.name,
    );

    _controller = GameController(
      gameState: gameState,
      feedback: _feedback,
      stepDelayMs: engineDelay,
      aiEngine: _aiEngine,
    );

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

    WidgetsBinding.instance.addPostFrameCallback(
      (
        _,
      ) async {
        if (mounted) {
          setState(
            () {
              _isInitializing = false;
            },
          );

          await Future.delayed(
            const Duration(
              milliseconds: 1000,
            ),
          );
          await _controller.settleBoard();
          _findNextAvailableLever(
            1,
          );
        }
      },
    );
  }

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

  double _getCellWidth() {
    return MediaQuery.of(
              context,
            ).size.height <
            600
        ? 16.0
        : 24.0;
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.6,
                child: Image.asset(
                  _themeImagePath,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
            ),
            CustomScrollView(
              slivers: [
                const GameHeader(
                  title: "MATCH ENGAGED",
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 20,
                    ), // Leave room at the bottom
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isInitializing)
                          const CircularProgressIndicator(
                            color: Colors.cyanAccent,
                          ),
                        if (!_isInitializing) ...[
                          // --- GESTURE DETECTOR WRAPPER ---
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onVerticalDragEnd:
                                (
                                  details,
                                ) {
                                  if (_controller.isProcessingMove) return;
                                  // Swipe velocity < 0 means swiped UP
                                  if (details.primaryVelocity! <
                                      0) {
                                    _controller.makeMove(
                                      _selectedColumn,
                                      MoveDirection.up,
                                    );
                                  } else {
                                    _controller.makeMove(
                                      _selectedColumn,
                                      MoveDirection.down,
                                    );
                                  }
                                },
                            onHorizontalDragEnd:
                                (
                                  details,
                                ) {
                                  if (_controller.isProcessingMove) return;
                                  // Swipe velocity < 0 means swiped LEFT
                                  if (details.primaryVelocity! <
                                      0) {
                                    _findNextAvailableLever(
                                      -1,
                                    );
                                  } else {
                                    _findNextAvailableLever(
                                      1,
                                    );
                                  }
                                },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(
                                  alpha: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(
                                  16,
                                ),
                                border: Border.all(
                                  color: Colors.cyanAccent.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Column(
                                children: [
                                  ..._buildBoardWidgets(),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  _buildLeverRow(),
                                  _buildSelectorRow(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<
    Widget
  >
  _buildBoardWidgets() {
    final List<
      Widget
    >
    columnWidgets = [];
    final board = _controller.gameState.board;
    final aliens = _controller.gameState.aliens;
    final width = _controller.gameState.width;
    final height = _controller.gameState.height;

    final double cellWidth = _getCellWidth();
    final Player p2 = _aiPlayer;
    final dummyPlayer = Player.human(
      namerTag: 'empty_tile',
    );

    // Loop through COLUMNS first (x) instead of rows (y)
    for (
      int x = 0;
      x <
          width;
      x++
    ) {
      final List<
        Widget
      >
      columnCells = [];

      for (
        int y = 0;
        y <
            height;
        y++
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
            player: dummyPlayer,
            x: -1,
            y: -1,
          ),
        );

        Widget cellContent = const SizedBox.shrink();

        if (alien.x !=
            -1) {
          cellContent = Image.asset(
            alien.player.id ==
                    p2.id
                ? 'assets/images/AlienRed.png'
                : 'assets/images/AlienBlue.png',
            fit: BoxFit.contain,
          );
        } else if (board[y][x] ==
            TileType.asteroid) {
          String theme =
              _themeImagePath.contains(
                'Nebula',
              )
              ? 'Nebula'
              : _themeImagePath.contains(
                  'Retro',
                )
              ? 'Retro'
              : 'Classic';
          String variation =
              ((x +
                          y) %
                      2 ==
                  0)
              ? '1'
              : '2';
          cellContent = Image.asset(
            'assets/images/Crater$theme$variation.png',
            fit: BoxFit.contain,
          );
        }

        columnCells.add(
          Container(
            width: cellWidth,
            height: cellWidth,
            alignment: Alignment.center,
            child: cellContent,
          ),
        );
      }

      // --- NEW: Individual Column Gesture Zone ---
      columnWidgets.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            // Selecting the column on tap/click
            final state = GameController.getLeverState(
              x,
              _controller.gameState,
            );
            if (state ==
                LeverState.available) {
              setState(
                () => _selectedColumn = x,
              );
            }
          },
          onVerticalDragEnd:
              (
                details,
              ) {
                if (_controller.isProcessingMove) return;

                // Immediately select this column if they start dragging it
                setState(
                  () => _selectedColumn = x,
                );

                if (details.primaryVelocity! <
                    0) {
                  _controller.makeMove(
                    x,
                    MoveDirection.up,
                  );
                } else if (details.primaryVelocity! >
                    0) {
                  _controller.makeMove(
                    x,
                    MoveDirection.down,
                  );
                }
              },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: columnCells,
          ),
        ),
      );
    }

    // Return the columns wrapped in a Row so they stand side-by-side
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: columnWidgets,
      ),
    ];
  }

  Widget _buildLeverRow() {
    final List<
      Widget
    >
    levers = [];
    final width = _controller.gameState.width;
    final gameState = _controller.gameState;
    final double cellWidth = _getCellWidth();

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

  Widget _buildSelectorRow() {
    final List<
      Widget
    >
    selectors = [];
    final width = _controller.gameState.width;
    final double cellWidth = _getCellWidth();

    for (
      int x = 0;
      x <
          width;
      x++
    ) {
      String content = " ";
      if (x ==
          _selectedColumn) {
        content = "^";
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
              color: Colors.cyanAccent,
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
