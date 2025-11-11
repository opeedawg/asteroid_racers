import 'dart:async';
import 'package:asteroid_racers/src/models/enums.dart';
import 'package:asteroid_racers/src/models/game_feedback.dart';

/// Handles broadcasting feedback messages from the game
class FeedbackController {
  // Use a broadcast stream so multiple UI widgets can listen
  final _controller =
      StreamController<
        GameFeedback
      >.broadcast();

  // Public getter for the stream that the UI will listen to
  Stream<
    GameFeedback
  >
  get stream => _controller.stream;

  /// Adds a new feedback event to the stream
  void add(
    FeedbackType type,
    String message,
  ) {
    _controller.add(
      GameFeedback(
        type: type,
        message: message,
      ),
    );
  }

  // Call this when the controller is no longer needed
  // to prevent memory leaks.
  void dispose() {
    _controller.close();
  }
}
