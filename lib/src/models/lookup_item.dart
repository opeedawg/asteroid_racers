class LookupItem {
  final int id;
  final String key;
  final String name;
  final String description;

  LookupItem({
    required this.id,
    required this.key,
    required this.name,
    required this.description,
  });

  factory LookupItem.fromJson(
    Map<
      String,
      dynamic
    >
    json,
  ) {
    return LookupItem(
      id: json['id'],
      key: json['lookup_key'],
      name: json['name'],
      description: json['description'],
    );
  }
}
