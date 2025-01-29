import 'dart:convert';

import 'package:angebote_manager/database/database_helper.dart';
import 'package:angebote_manager/models/angebot.dart';
import 'package:angebote_manager/models/angebotsleistung.dart';
import 'package:angebote_manager/models/leistung.dart';

class AngebotDatabase {

  static Future<void> createAngebot(Angebot angebot) async {
    final db = await DatabaseHelper.db();
    if(db == null) {
      throw Exception("Database Error");
    }

    final angebotId = await db.insert('Angebot', angebot.toMap());

    for(int i = 0; i < angebot.leistungen.length; i++) {
      final angebotsleistungId = await db.insert('Angebotsleistung', angebot.leistungen[i].toMap(angebotId, angebot.leistungen[i].leistung.id));
      await db.insert("Angebot_Angebotsleistung", {'FK_AngebotID': angebotId, 'FK_AngebotsleistungID': angebotsleistungId});
    }
  }

  static Future<List<Angebot>> angebote() async {
    final db = await DatabaseHelper.db();
    if(db == null) {
      throw Exception("Database Error");
    }

    final List<Map<String, dynamic>> angebotMaps = await db.query("Angebot");

    final List<Angebot> angebote = [];

    for(final angebot in angebotMaps) {
      int id = angebot["PK_AngebotID"];
      String name = angebot["Name"];
      String zH = angebot["zH"];
      String address = angebot["Address"];
      String city = angebot["City"];
      String project = angebot["Project"];
      String anschrift = angebot["Anschrift"];
      String date = angebot["Date"];

      List<AngebotsLeistung> angebotsLeistungen = await getAngebotsLeistungenForAngebot(id);

      if(zH.isNotEmpty) {
        angebote.add(
            Angebot(name: name, address: address, zH: zH, city: city, project: project, anschrift: anschrift, date: date, leistungen: angebotsLeistungen)
        );
      }else{
        angebote.add(
            Angebot(name: name, address: address, city: city, project: project, anschrift: anschrift, date: date, leistungen: angebotsLeistungen)
        );
      }
    }

    return angebote;
  }

  static Future<List<AngebotsLeistung>> getAngebotsLeistungenForAngebot(int id) async {
    final db = await DatabaseHelper.db();
    if (db == null) {
      throw Exception("Database Error");
    }

    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT 
      AL.PK_AngebotsleistungID,
      AL.FK_AngebotID,
      AL.FK_LeistungID,
      AL.Amount,
      AL.SinglePrice,
      AL.Unit,
      L.Name AS LeistungName,
      L.Description AS LeistungDescription,
      L.Units AS LeistungUnits,
      L.fixCost AS LeistungFixCost
    FROM Angebotsleistung AL
    INNER JOIN Angebot_Angebotsleistung AAL ON AL.PK_AngebotsleistungID = AAL.FK_AngebotsleistungID
    INNER JOIN Leistungen L ON AL.FK_LeistungID = L.PK_LeistungID
    WHERE AAL.FK_AngebotID = ?
  ''', [id]);

    List<AngebotsLeistung> angebotsLeistungen = result.map((row) {
      return AngebotsLeistung(
        leistung: Leistung(
          id: row['FK_LeistungID'],
          name: row['LeistungName'],
          description: row['LeistungDescription'],
          units: row['LeistungUnits'].split(","),
          fixCost: row['LeistungFixCost'],
        ),
        amount: row['Amount'],
        singlePrice: row['SinglePrice'],
        unit: row['Unit'],
      );
    }).toList();

    return angebotsLeistungen;
  }


  static Future<void> updateAngebot(Angebot angebot, int id) async {
    final db = await DatabaseHelper.db();
    if (db == null) {
      throw Exception("Database Error");
    }

    await db.update(
      'Angebot',
      angebot.toMap(),
      where: 'PK_AngebotID = ?',
      whereArgs: [id],
    );

    await db.delete(
      'Angebot_Angebotsleistung',
      where: 'FK_AngebotID = ?',
      whereArgs: [id],
    );

    await db.delete(
       'Angebotsleistung',
       where: 'FK_AngebotID = ?',
       whereArgs: [id],
    );

    for (int i = 0; i < angebot.leistungen.length; i++) {
      final angebotsleistung = angebot.leistungen[i];
      final angebotsleistungId = await db.insert(
        'Angebotsleistung',
        angebotsleistung.toMap(id, angebotsleistung.leistung.id),
      );

      await db.insert(
        'Angebot_Angebotsleistung',
        {
          'FK_AngebotID': id,
          'FK_AngebotsleistungID': angebotsleistungId,
        },
      );
    }
  }
}