import 'dart:async';
import 'package:angebote_manager/database/leistungen_database.dart';
import 'package:angebote_manager/models/leistung.dart';
import 'package:flutter/cupertino.dart';

class LeistungenOverviewProvider extends ChangeNotifier {
  late StreamController<List<Leistung>> _leistungStreamController;
  late Stream<List<Leistung>> leistungStream;
  List<Leistung> leistungenList = [];

  bool isEmptyLeistungAdded = false;

  final ScrollController scrollController = ScrollController();

  LeistungenOverviewProvider() {
    _leistungStreamController = StreamController<List<Leistung>>.broadcast();
    leistungStream = _leistungStreamController.stream;
    loadLeistungen();
  }

  Stream<List<Leistung>> get leistungen => leistungStream;

  Future<void> loadLeistungen() async {
    try {
      List<Leistung> leistungen = await LeistungenDatabase.leistungen();
      leistungenList = leistungen;
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

  Future<void> addEmptyLeistung() async {
    if(isEmptyLeistungAdded == false) {
      leistungenList.add(Leistung(id: leistungenList.length+1, name: "", description: "", units: []));
      _leistungStreamController.add(leistungenList);
      notifyListeners();
      _scrollToBottomOfList();
      isEmptyLeistungAdded = true;
    }
  }

  Future<void> removeLeistung(int index) async {
    leistungenList.removeAt(index);
    _leistungStreamController.add(leistungenList);
    notifyListeners();
    isEmptyLeistungAdded = false;
  }

  void _scrollToBottomOfList() {
    Future.delayed(Duration(milliseconds: 20), () {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
      );
      },
    );
  }

  @override
  void dispose() {
    _leistungStreamController.close();
    super.dispose();
  }
}
