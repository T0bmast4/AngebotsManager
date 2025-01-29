import 'package:angebote_manager/database/predefined_leistungen.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {

  static Future<Database> db() async {
    final appDocumentsDir = await getApplicationSupportDirectory();
    return openDatabase(
      join(appDocumentsDir.path, 'offers_database.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE Leistungen(PK_LeistungID INTEGER PRIMARY KEY AUTOINCREMENT, orderIndex INTEGER, Name TEXT, Description TEXT, Units TEXT, fixCost DOUBLE)',
        );

        await db.execute(
          'CREATE TABLE Unterleistungen(PK_UnterleistungID INTEGER PRIMARY KEY AUTOINCREMENT, orderIndex INTEGER, FK_LeistungID INT, Name TEXT, Description TEXT, FOREIGN KEY(FK_LeistungID) REFERENCES Leistungen(PK_LeistungID))',
        );

        await db.execute(
          'CREATE TABLE Angebotsleistung(PK_AngebotsleistungID INTEGER PRIMARY KEY AUTOINCREMENT, FK_AngebotID INTEGER, FK_LeistungID INTEGER, Amount DOUBLE, SinglePrice DOUBLE, Unit TEXT, FOREIGN KEY (FK_AngebotID) REFERENCES Angebot(PK_AngebotID), FOREIGN KEY (FK_LeistungID) REFERENCES Leistung(PK_LeistungID))',
        );

        await db.execute(
          'CREATE TABLE Angebot(PK_AngebotID INTEGER PRIMARY KEY AUTOINCREMENT, Name TEXT, zH TEXT, Address TEXT, City TEXT, Project TEXT, Anschrift TEXT, Date TEXT)',
        );

        await db.execute(
          'CREATE TABLE Angebot_Angebotsleistung(PK_Angebot_AngebotsleistungID INTEGER PRIMARY KEY AUTOINCREMENT, FK_AngebotID INTEGER, FK_AngebotsleistungID INTEGER, FOREIGN KEY (FK_AngebotID) REFERENCES Angebot(PK_AngebotID), FOREIGN KEY (FK_AngebotsleistungID) REFERENCES Angebotsleistung(PK_AngebotsleistungID))',
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
    );
  }
}