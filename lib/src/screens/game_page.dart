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
import 'package:asteroid_racers/src/widgets/game_header.dart'; // Ensure this path is correct

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

  // Dynamic Background and AI State
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

    // 1. Map DB IDs back to their Lookup String Names
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

    // 2. Set the dynamic background image path
    _themeImagePath = 'assets/images/Theme${themeItem.name}.png';

    // 3. Create the AI Opponent
    _aiPlayer = Player.ai(
      difficulty: AIDifficulty.normal,
    ); // You can map the aiDifficultyId here later

    // 4. Initialize the new GameState
    final gameState = GameState.newGame(
      boardSizeName: boardSizeItem.name,
      player1: player1,
      player2: _aiPlayer,
    );

    // AI Engine Initialization
    _aiEngine = AIEngine(
      AIDifficulty.normal,
    );

    // Controller Initialization
    _feedback = FeedbackController();
    // 1. Fetch the string name from the DB
    final speedItem = lookups.firstWhere(
      (
        l,
      ) =>
          l.id ==
          widget.settings.gameSpeedId,
    );

    // 2. Map it to raw milliseconds for the engine
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

    // 3. Inject it!
    _controller = GameController(
      gameState: gameState,
      feedback: _feedback,
      stepDelayMs: engineDelay, // Passed as a pure integer!
      aiEngine: _aiEngine,
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
          if (_controller.gameState.currentPlayer.isAI) {
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
            is! KeyDownEvent) {
      return;
    }

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

  @override
  Widget build(
    BuildContext context,
  ) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: Colors.black,
        // Using a Stack to place the UI over the dynamic background image
        body: Stack(
          children: [
            // 1. The Dynamic Theme Background
            Positioned.fill(
              child: Opacity(
                opacity: 0.6, // Darken slightly so the text/board remains readable
                child: Image.asset(
                  _themeImagePath,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
            ),

            // 2. The Game UI with the Shared Header
            CustomScrollView(
              slivers: [
                GameHeader(
                  title: "MATCH ENGAGED",
                  pilotTag: widget.settings.player1.namerTag,
                  // Disable profile/leaderboard popups during an active game, or wire them up to pause the game
                  onProfilePressed: () => debugPrint(
                    'Profile pressed in-game',
                  ),
                  onLeaderboardPressed: () => debugPrint(
                    'Leaderboard pressed in-game',
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isInitializing)
                          const Padding(
                            padding: EdgeInsets.all(
                              32.0,
                            ),
                            child: CircularProgressIndicator(
                              color: Colors.cyanAccent,
                            ),
                          ),
                        if (!_isInitializing) ...[
                          _buildScoreDebugPanel(),
                          // Adding a slight background behind the board for readability
                          Container(
                            padding: const EdgeInsets.all(
                              16,
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
                                  height: 20,
                                ),
                                _buildLeverRow(),
                                _buildSelectorRow(),
                              ],
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

  // --- Board Renderer ---
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

    // Slightly increase cell width if you want the art to be bigger
    const double cellWidth = 24.0;

    final Player p2 = _aiPlayer;

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
            // Use the .ai constructor instead of manually setting PlayerType
            player: Player.ai(
              difficulty: AIDifficulty.easy,
            ),
            x: -1,
            y: -1,
          ),
        );

        Widget cellContent = const SizedBox.shrink(); // Empty space by default

        if (alien.x !=
            -1) {
          if (alien.player.id ==
              p2.id) {
            // AI Opponent (Facing Left)
            // Ensure filename matches your assets list exactly!
            cellContent = Image.asset(
              'assets/images/AlientRed.png',
              fit: BoxFit.contain,
            );
          } else {
            // Pilot (Facing Right)
            cellContent = Image.asset(
              'assets/images/AlientBlue.png',
              fit: BoxFit.contain,
            );
          }
        } else if (board[y][x] ==
            TileType.asteroid) {
          // Alternate between Crater 1 and 2 for visual variety
          String craterVariation =
              ((x +
                          y) %
                      2 ==
                  0)
              ? '1'
              : '2';

          // Fallback variable in case _themeName isn't set yet
          // In _initializeGame(), make sure you added: _themeName = themeItem.name;
          String themeToUse =
              _themeImagePath.contains(
                'Nebula',
              )
              ? 'Nebula'
              : _themeImagePath.contains(
                  'Retro',
                )
              ? 'Retro'
              : 'Classic';

          cellContent = Image.asset(
            'assets/images/Crater$themeToUse$craterVariation.png',
            fit: BoxFit.contain,
          );
        }

        cells.add(
          Container(
            width: cellWidth,
            height: cellWidth, // Force a square aspect ratio for the art
            alignment: Alignment.center,
            child: cellContent,
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

  // --- Score Debug Panel ---
  Widget _buildScoreDebugPanel() {
    final Player p1 = widget.settings.player1;
    final Player p2 = _aiPlayer;

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
      winningPlayer = 'AI Opponent';
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'PILOT: $p1Score',
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(
                width: 40,
              ),
              Text(
                'AI: $p2Score',
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Center(
            child: Text(
              'Advantage: $winningPlayer',
              style: TextStyle(
                color: winningColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
