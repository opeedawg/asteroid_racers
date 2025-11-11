import 'package:flutter/material.dart';
// Import our new screen
import 'package:asteroid_racers/src/screens/game_page.dart';

void
main() {
  runApp(
    const MyApp(),
  );
}

class MyApp
    extends
        StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return MaterialApp(
      title: 'Asteroid Racers',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        fontFamily: 'Courier', // Use a monospaced font by default
      ),
      home: const GamePage(), // Start with our clean game page
    );
  }
}
