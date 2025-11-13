// Represents the content of a single tile on the board.
enum TileType {
  empty,
  asteroid,
}

enum BoardSize {
  small,
  regular,
  large,
  extraLarge,
}

enum MoveDirection {
  up,
  down,
}

enum FeedbackType {
  success, // A move was successful
  failure, // A move was illegal
  info, // General info (like scoring)
}

/// Defines the UI state for a column's lever
enum LeverState {
  unavailable, // Player has no alien here. Don't draw.
  available, // Player has an alien, move is legal. Draw active.
  locked, // Player has an alien, but it's the last-moved column. Draw disabled.
}

/// Defines the difficulty level for the Minimax AI.
enum Difficulty {
  easy,
  normal,
  hard,
  god,
}

/// Defines game speed levels.
enum GameSpeedLevel {
  verySlow,
  slow,
  normal,
  fast,
  veryFast,
}
