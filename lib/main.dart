// In lib/main.dart

import 'package:flutter/material.dart';
import 'package:asteroid_racers/src/screens/settings_screen.dart'; // <-- NEW IMPORT

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
      home: const SettingsScreen(), // <-- START HERE!
    );
  }
}
