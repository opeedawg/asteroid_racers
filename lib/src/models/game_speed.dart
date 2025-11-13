import 'package:asteroid_racers/src/models/enums.dart';

class GameSpeed {
  static const Map<
    GameSpeedLevel,
    int
  >
  speedMap = {
    GameSpeedLevel.verySlow: 500, // 500ms delay per step
    GameSpeedLevel.slow: 250, // 250ms
    GameSpeedLevel.normal: 100, // 100ms (Current Default)
    GameSpeedLevel.fast: 50, // 50ms
    GameSpeedLevel.veryFast: 10, // 10ms
  };

  static const Map<
    GameSpeedLevel,
    String
  >
  speedDescriptionMap = {
    GameSpeedLevel.verySlow: "For a lazy Sunday afternoon",
    GameSpeedLevel.slow: "Time to spare",
    GameSpeedLevel.normal: "Normal speed (Default)",
    GameSpeedLevel.fast: "On a lunch break",
    GameSpeedLevel.veryFast: "What just happened?",
  };

  // Method to get the delay from the level
  static int
  getDelay(
    GameSpeedLevel level,
  ) =>
      speedMap[level] ??
      speedMap[GameSpeedLevel.normal]!;

  static String
  getDescription(
    GameSpeedLevel level,
  ) =>
      speedDescriptionMap[level] ??
      speedDescriptionMap[GameSpeedLevel.normal]!;
}
