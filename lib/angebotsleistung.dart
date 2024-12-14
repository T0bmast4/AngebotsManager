import 'package:angebote_manager/leistung.dart';

class AngebotsLeistung {
  final Leistung leistung;
  final double amount;
  final double singlePrice;
  final String unit;

  AngebotsLeistung({
    required this.leistung,
    required this.amount,
    required this.singlePrice,
    required this.unit,
  });

  String get totalPrice {
    String totalPrice = (amount * singlePrice).toStringAsFixed(2);
    totalPrice = totalPrice.toString().replaceAll(".", ",");
    return totalPrice;
  }

  String get amountString {
    return amount.toStringAsFixed(2).replaceAll(".", ",");
  }
  
  String get singlePriceString {
    return singlePrice.toStringAsFixed(2).replaceAll(".", ",");
  }
  
  double get totalPriceAsDouble {
    double totalPrice = amount * singlePrice;
    return totalPrice;
  }
}