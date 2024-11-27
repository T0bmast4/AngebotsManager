class Leistung {
  final String name;
  final String description;
  final double amount;
  final String unit;
  final double singlePrice;
  final double totalPrice;

  Leistung({
    required this.name,
    required this.description,
    required this.amount,
    required this.unit,
    required this.singlePrice,
    required this.totalPrice,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Leistung &&
        other.name == name &&
        other.amount == amount &&
        other.unit == unit;
  }

  @override
  int get hashCode => Object.hash(name, amount, unit);
}