import 'package:angebote_manager/unterleistung.dart';

class Leistung {
  final String name;
  final String description;
  final List<Unterleistung>? unterleistungen;
  final List<String> units;

  Leistung({
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
}