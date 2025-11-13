import 'package:uuid/uuid.dart'; // We'll need to add this package

class Player {
  final String id;
  String namerTag;

  // Placeholder fields for future backend use
  final bool isAuthenticated;
  final String? passwordHash;

  Player({
    required this.namerTag,
    this.isAuthenticated = false,
    this.passwordHash = "",
  }) : id = const Uuid().v4();
}
