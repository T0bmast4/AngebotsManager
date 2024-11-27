import 'package:angebote_manager/leistung.dart';
import 'package:flutter/cupertino.dart';

class AngebotCreateProvider extends ChangeNotifier {
  Stream<List<Leistung>> get leistungen {
    return Stream.value(
      [
        Leistung(name: "Baustellengemeinkosten", description: "Sämtliche ...", amount: 1.00, unit: "PA", singlePrice: 0.00, totalPrice: 0.00),
        Leistung(name: "Entfernung der Altbeschichtung", description: "Die zu beschichtenden ...", amount: 1.00, unit: "PA", singlePrice: 300.00, totalPrice: 300.00),
      ]
    );
  }
}