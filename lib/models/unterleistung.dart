class Unterleistung {
  final int id;
  final int? orderIndex;
  final String name;
  final String? description;

  Unterleistung({
    required this.id,
    this.orderIndex,
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

  Map<String, Object?> toMap(int leistungId) {
    return {
      'FK_LeistungID': leistungId,
      'name': name,
      'description': description,
      'orderIndex': orderIndex ?? 0,
    };
  }
}