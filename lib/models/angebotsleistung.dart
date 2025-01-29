import 'package:angebote_manager/models/leistung.dart';

class AngebotsLeistung {
  final Leistung leistung;
  final double amount;
  final double singlePrice;
  final String unit;
  final int? days;

  AngebotsLeistung({
    required this.leistung,
    required this.amount,
    required this.singlePrice,
    required this.unit,
    this.days,
  });

  String formatNumber(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    String integerPart = parts[0];
    String decimalPart = parts[1];

    final buffer = StringBuffer();
    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(integerPart[i]);
    }

    return '${buffer.toString()},$decimalPart';
  }

  String get totalPrice {
    return formatNumber(amount * singlePrice);
  }

  String get amountString {
    return formatNumber(amount);
  }

  String get singlePriceString {
    return formatNumber(singlePrice);
  }

  double get totalPriceAsDouble {
    return amount * singlePrice;
  }

  Map<String, Object?> toMap(int angebotId, int leistungId) {
    return {
      'FK_AngebotID': angebotId,
      'FK_LeistungID': leistungId,
      'amount': amount,
      'singlePrice': singlePrice,
      'unit': unit,
    };
  }
}
