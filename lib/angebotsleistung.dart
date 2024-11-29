import 'package:angebote_manager/leistung.dart';

class AngebotsLeistung {
  final Leistung leistung;
  final String amount;
  final String singlePrice;

  AngebotsLeistung({
    required this.leistung,
    required this.amount,
    required this.singlePrice,
  });

  double get totalPrice => double.parse(amount) * double.parse(singlePrice);
}