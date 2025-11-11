import 'package:asteroid_racers/src/models/enums.dart';

/// A data class to hold a feedback message
class GameFeedback {
  final FeedbackType type;
  final String message;

  GameFeedback({
    required this.type,
    required this.message,
  });
}
