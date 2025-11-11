import 'package:uuid/uuid.dart'; // We'll need to add this package

class Player {
  final String id;
  String name;
  // We can add more stats here later
  // int wins;
  // int losses;
  // String country;

  Player({
    required this.name,
  }) : id = Uuid().v4(); // Auto-generate a unique ID
}
