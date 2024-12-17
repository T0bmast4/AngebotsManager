import 'dart:io';

import 'package:angebote_manager/database/predefined_leistungen.dart';
import 'package:angebote_manager/models/leistung.dart';
import 'package:angebote_manager/models/unterleistung.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class LeistungenDatabase {
  Database? database;



  static Future<void> createLeistung(Leistung leistung) async {
    final db = await LeistungenDatabase.db();
    if(db == null) {
      throw Exception("Database Error");
    }

    final leistungId = db.insert('Leistungen', leistung.toMap());

    leistung.unterleistungen?.map((unterleistung) async {
      await db.insert('Unterleistungen', unterleistung.toMap(leistungId as int));
    });
  }static Future<Database> db() async {
    return openDatabase(
      join(await getDatabasesPath(), 'services_database.db'),
      onCreate: (db, version) async {

        await db.execute(
          'CREATE TABLE Leistungen(PK_LeistungID INTEGER PRIMARY KEY AUTOINCREMENT, Name TEXT, Description TEXT, Units TEXT)',
        );

        await db.execute(
          'CREATE TABLE Unterleistungen(PK_UnterleistungID INTEGER PRIMARY KEY AUTOINCREMENT, FK_LeistungID INT, Name TEXT, Description TEXT, FOREIGN KEY(FK_LeistungID) REFERENCES Leistungen(PK_LeistungID))',
        );
        for (var leistung in PredefinedLeistungen().predefined_leistungen) {
          final leistungId = await db.insert('Leistungen', leistung.toMap());

          if(leistung.unterleistungen != null) {
            for(var unterleistung in leistung.unterleistungen!) {
              await db.insert('Unterleistungen', unterleistung.toMap(leistungId));
            }
          }
        }
      },
      version: 1,
    );
  }

  static Future<List<Leistung>> leistungen() async {
    final db = await LeistungenDatabase.db();
    if(db == null) {
      throw Exception("Database Error");
    }

    final List<Map<String, dynamic>> leistungMaps = await db.query("Leistungen");

    final List<Leistung> leistungen = [];

    for(final leistung in leistungMaps) {
      int id = leistung["PK_LeistungID"];
      String name = leistung["Name"];
      String description = leistung["Description"];
      String units = leistung["Units"];

      List<Unterleistung> unterleistungen = await getUnterleistungenForLeistung(id);

      leistungen.add(Leistung(id: id, name: name, description: description, unterleistungen: unterleistungen, units: units.split(",")));
    }

    return leistungen;
  }

  static Future<List<Unterleistung>> getUnterleistungenForLeistung(int id) async{
    final db = await LeistungenDatabase.db();
    if(db == null) {
      throw Exception("Database Error");
    }

    final List<Map<String, dynamic>> unterleistungMaps = await db.query("Unterleistungen", where: "FK_LeistungID = ?", whereArgs: [id]);

    return [
      for(final {
        "Name": name as String,
        "Description": description as String?,
      } in unterleistungMaps)
          Unterleistung(name: name, description: description)
    ];
  }
}