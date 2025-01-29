import 'dart:io';

import 'package:angebote_manager/database/database_helper.dart';
import 'package:angebote_manager/models/leistung.dart';
import 'package:angebote_manager/models/unterleistung.dart';
class LeistungenDatabase {

  static Future<void> createLeistung(Leistung leistung) async {
    final db = await DatabaseHelper.db();
    if(db == null) {
      throw Exception("Database Error");
    }

    final leistungId = db.insert('Leistungen', leistung.toMap());

    leistung.unterleistungen?.map((unterleistung) async {
      await db.insert('Unterleistungen', unterleistung.toMap(leistungId as int));
    });
  }

  static Future<List<Leistung>> leistungen() async {
    final db = await DatabaseHelper.db();
    if(db == null) {
      throw Exception("Database Error");
    }

    final List<Map<String, dynamic>> leistungMaps = await db.query("Leistungen");

    List<Map<String, dynamic>> leistungMapsCopy = List.from(leistungMaps);

    leistungMapsCopy.sort((a, b) => a["orderIndex"].compareTo(b["orderIndex"]));


    final List<Leistung> leistungen = [];

    for(final leistung in leistungMapsCopy) {
      int id = leistung["PK_LeistungID"];
      String name = leistung["Name"];
      String description = leistung["Description"];
      String units = leistung["Units"];
      double fixCost = leistung["fixCost"];

      List<Unterleistung> unterleistungen = await getUnterleistungenForLeistung(id);

      leistungen.add(Leistung(id: id, name: name, description: description, unterleistungen: unterleistungen, units: units.split(","), fixCost: fixCost));
    }

    return leistungen;
  }

  static Future<List<Unterleistung>> getUnterleistungenForLeistung(int id) async {
    final db = await DatabaseHelper.db();
    if(db == null) {
      throw Exception("Database Error");
    }

    final List<Map<String, dynamic>> unterleistungMaps = await db.query("Unterleistungen", where: "FK_LeistungID = ?", whereArgs: [id]);

    List<Map<String, dynamic>> unterleistungMapsCopy = List.from(unterleistungMaps);
    unterleistungMapsCopy.sort((a, b) => a["orderIndex"].compareTo(b["orderIndex"]));

    return [
      for(final {
        "PK_UnterleistungID": id as int,
        "Name": name as String,
        "Description": description as String?,
      } in unterleistungMapsCopy)
          Unterleistung(id: id, name: name, description: description)
    ];
  }

  static Future<void> updateLeistungOrder(int leistungId, int orderIndex) async {
    final db = await DatabaseHelper.db();
    if(db == null) {
      throw Exception("Database Error");
    }

    await db.update(
      'Leistungen',
      {'orderIndex': orderIndex},
      where: 'PK_LeistungID = ?',
      whereArgs: [leistungId],
    );
  }

  static Future<void> updateLeistungSinglePrice(int leistungId, double singlePrice) async {
    final db = await DatabaseHelper.db();
    if(db == null) {
      throw Exception("Database Error");
    }

    await db.update(
      'Leistungen',
      {'fixCost': singlePrice},
      where: 'PK_LeistungID = ?',
      whereArgs: [leistungId],
    );
  }

  static Future<void> updateUnterleistungOrder(int unterleistungId, int orderIndex) async {
    final db = await DatabaseHelper.db();
    if(db == null) {
      throw Exception("Database Error");
    }

    await db.update(
      'Unterleistungen',
      {'orderIndex': orderIndex},
      where: 'PK_UnterleistungID = ?',
      whereArgs: [unterleistungId],
    );
  }

  static Future<void> updateLeistung(int leistungId, String name, String description) async {
    final db = await DatabaseHelper.db();
    if(db == null) {
      throw Exception("Database Error");
    }

    await db.update(
      'Leistungen',
      {'Name': name, 'Description': description},
      where: 'PK_LeistungID = ?',
      whereArgs: [leistungId],
    );
  }

  static Future<void> updateUnterleistung(int unterleistungId, String name, String description) async {
    final db = await DatabaseHelper.db();
    if(db == null) {
      throw Exception("Database Error");
    }

    await db.update(
      'Unterleistungen',
      {'Name': name, 'Description': description},
      where: 'PK_UnterleistungID = ?',
      whereArgs: [unterleistungId],
    );
  }

  static Future<void> deleteLeistung(int leistungId) async {
    final db = await DatabaseHelper.db();
    if(db == null) {
      throw Exception("Database Error");
    }

    await db.delete(
      'Leistungen',
      where: 'PK_LeistungID = ?',
      whereArgs: [leistungId],
    );
  }
}