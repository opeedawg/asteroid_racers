import 'package:asteroid_racers/src/screens/launch_screen.dart';
import 'package:flutter/material.dart';

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
        fontFamily: 'Courier',
      ),
      home: const LaunchScreen(),
    );
  }
}
