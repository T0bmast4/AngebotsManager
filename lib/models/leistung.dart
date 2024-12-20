import 'package:angebote_manager/models/unterleistung.dart';

class Leistung {
  final int? id;
  final int? orderIndex;
  final String name;
  final String description;
  final List<Unterleistung>? unterleistungen;
  final List<String> units;

  Leistung({
    this.id,
    this.orderIndex,
    required this.name,
    required this.description,
    this.unterleistungen,
    required this.units,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Leistung &&
        other.name == name;
  }

  @override
  int get hashCode => Object.hash(name, description);

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'description': description,
      'units': units.join(","),
      'orderIndex': orderIndex ?? id ?? 0,
    };
  }
}