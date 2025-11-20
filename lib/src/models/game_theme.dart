import 'package:asteroid_racers/src/models/enums.dart';

class GameTheme {
  final ThemeOption option;
  final String description;
  final String backgroundImagePath; // Path or key for an asset

  const GameTheme({
    required this.option,
    required this.description,
    required this.backgroundImagePath,
  });

  // A simple static map to hold theme data
  static final Map<
    ThemeOption,
    GameTheme
  >
  themeData = {
    ThemeOption.classic: const GameTheme(
      option: ThemeOption.classic,
      description: "Default dark theme (A.I. mouse feel).",
      backgroundImagePath: "assets/images/bg_dark_space.png",
    ),
    ThemeOption.nebula: const GameTheme(
      option: ThemeOption.nebula,
      description: "Vibrant cosmic background.",
      backgroundImagePath: "assets/images/bg_nebula.png",
    ),
    ThemeOption.retro: const GameTheme(
      option: ThemeOption.retro,
      description: "8-bit green monochrome.",
      backgroundImagePath: "assets/images/bg_retro.png",
    ),
  };
}
