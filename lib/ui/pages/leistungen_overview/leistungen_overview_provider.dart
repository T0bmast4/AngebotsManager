import 'dart:async';
import 'package:angebote_manager/database/leistungen_database.dart';
import 'package:angebote_manager/models/leistung.dart';
import 'package:flutter/cupertino.dart';

class LeistungenOverviewProvider extends ChangeNotifier {
  late StreamController<List<Leistung>> _leistungStreamController;
  late Stream<List<Leistung>> leistungStream;

  LeistungenOverviewProvider() {
    _leistungStreamController = StreamController<List<Leistung>>.broadcast();
    leistungStream = _leistungStreamController.stream;
    loadLeistungen();
  }

  Stream<List<Leistung>> get leistungen => leistungStream;

  Future<void> loadLeistungen() async {
    try {
      List<Leistung> leistungen = await LeistungenDatabase.leistungen();
      _leistungStreamController.add(leistungen);
      notifyListeners();
    } catch (e) {
      print("Error loading Leistungen: $e");
      _leistungStreamController.add([]);
    }
  }

  Future<void> reloadLeistungen() async {
    await loadLeistungen();
  }

  @override
  void dispose() {
    _leistungStreamController.close();
    super.dispose();
  }
}
