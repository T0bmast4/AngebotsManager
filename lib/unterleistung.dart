class Unterleistung {
  final String name;
  final String? description;

  Unterleistung({
    required this.name,
    this.description,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Unterleistung &&
        other.name == name;
  }

  @override
  int get hashCode => Object.hash(name, description);
}