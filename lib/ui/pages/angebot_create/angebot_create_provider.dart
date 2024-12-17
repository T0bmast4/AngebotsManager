import 'package:angebote_manager/database/leistungen_database.dart';
import 'package:angebote_manager/models/leistung.dart';
import 'package:angebote_manager/models/unterleistung.dart';
import 'package:flutter/cupertino.dart';

class AngebotCreateProvider extends ChangeNotifier {
  Future<Stream<List<Leistung>>> get leistungen async {
    return Stream.value(await LeistungenDatabase.leistungen());
  }
}