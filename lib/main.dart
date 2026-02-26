import 'dart:io'
    show
        Platform;
import 'package:flutter/foundation.dart'
    show
        kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_manager/window_manager.dart';
import 'package:asteroid_racers/src/screens/splash_screen.dart';

void
main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  await Supabase.initialize(
    url: 'http://127.0.0.1:54321', // Your local API URL
    anonKey: 'sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH', // Your local Public Key
  );

  WindowOptions windowOptions = const WindowOptions(
    size: Size(
      650,
      800,
    ), // Standardized vertical size
    minimumSize: Size(
      600,
      700,
    ), // Prevents shrinking into overflow territory
    center: true,
    title: "Asteroid Racers",
  );

  windowManager.waitUntilReadyToShow(
    windowOptions,
    () async {
      await windowManager.show();
      await windowManager.setResizable(
        true,
      ); // Allow some resizing, but restricted
    },
  );

  // 2. Mobile Orientation Logic
  if (!kIsWeb &&
      (Platform.isAndroid ||
          Platform.isIOS)) {
    await SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
      ],
    );
  }

  // Ensure this name matches the class name below!
  runApp(
    const AsteroidRacersApp(),
  );
}

// Ensure this class name is exactly what you called in runApp()
class AsteroidRacersApp
    extends
        StatelessWidget {
  const AsteroidRacersApp({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Asteroid Racers',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const SplashScreen(),
    );
  }
}
