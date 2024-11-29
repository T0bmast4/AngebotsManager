import 'dart:io';

import 'package:angebote_manager/angebotsleistung.dart';
import 'package:angebote_manager/leistung.dart';
import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';

class Angebot {
  final String name;
  final String? zH;
  final String address;
  final String plz;
  final String city;
  final String project;
  final Set<Leistung> leistungen;

  Angebot({
    required this.name,
    this.zH,
    required this.address,
    required this.plz,
    required this.city,
    required this.project,
    required this.leistungen,
  });

  void createDocument() async {
    try {
      var data = await rootBundle.load('documents/Vorlage.docx');

      final bytes = data.buffer.asUint8List();

      var archive = ZipDecoder().decodeBytes(bytes);

      ArchiveFile? documentXmlFile = archive.firstWhere(
            (file) => file.name == 'word/document.xml',
      );

      if (documentXmlFile != null) {
        print('Found document.xml!');

        String documentXmlContent = String.fromCharCodes(documentXmlFile.content);
        var now = DateTime.now();
        var formatter = DateFormat('dd.MM.yyyy');
        String formattedDate = formatter.format(now);

        if(zH != null) {
          documentXmlContent = documentXmlContent
              .replaceAll('~Â³Â§n', name)
              .replaceAll('~Â³Â§a', address)
              .replaceAll('~Â³Â§p', "A- $plz $city")
              .replaceAll('~Â³Â§z', zH!)
              .replaceAll("f32-sd3", project)
              .replaceAll("d42s", formattedDate);
        }else{
          documentXmlContent = documentXmlContent
              .replaceAll('~Â³Â§n', "")
              .replaceAll('~Â³Â§a', address)
              .replaceAll('~Â³Â§p', "A- $plz $city")
              .replaceAll('~Â³Â§z', name)
              .replaceAll("f32-sd3", project)
              .replaceAll("d42s", formattedDate);
        }
        print(documentXmlContent);

        final updatedDocument = XmlDocument.parse(documentXmlContent);

        if(leistungen.isNotEmpty) {

          final tableElements = updatedDocument.findAllElements('w:tbl').toList();
          final tableElement = tableElements[1];

          tableElement.children.removeWhere((row) {
            if (row is XmlElement && row.name.local == 'w:tr') {
              String rowName = row.findElements('w:t').first.text;
              return !leistungen.any((leistung) => leistung.name == rowName);
            }
            return false;
          });

          for (var leistung in leistungen) {
            final rowElement = XmlElement(XmlName('w:tr'));
            rowElement.children.add(createCell(leistung.name, false));
            rowElement.children.add(createCell(leistung.amount.toString(), true));
            rowElement.children.add(createCell(leistung.unit, true));
            rowElement.children.add(createCell(leistung.singlePrice.toString(), true));
            rowElement.children.add(createCell(leistung.totalPrice.toString(), true));
            tableElement.children.insert(3, rowElement);
          }
        }

        documentXmlContent = updatedDocument.toString();
        documentXmlContent = documentXmlContent
                              .replaceAll("&#x9F;", "")
                              .replaceAll("&#x82;", "");

        var newArchive = Archive();

        for (var file in archive) {
          if (file.name != 'word/document.xml') {
            newArchive.addFile(ArchiveFile(file.name, file.size, file.content));
          }
        }


        newArchive.addFile(ArchiveFile('word/document.xml', documentXmlContent.length, documentXmlContent.codeUnits));

        var encoder = ZipEncoder();
        var updatedDocx = encoder.encode(newArchive);

        final directory = await getApplicationCacheDirectory();
        final outputFilePath = '${directory.path}/filled_template.docx';

        var outputFile = File(outputFilePath);
        await outputFile.writeAsBytes(updatedDocx!);

        print("Die neue .docx-Datei wurde erfolgreich erstellt: ${outputFile.absolute.path}");
        OpenFile.open(outputFile.absolute.path);
      } else {
        print('document.xml nicht gefunden');
      }
    } catch (e, stack) {
      print('Fehler: $e, $stack');
    }
  }

  XmlElement createCell(String text, bool alignRight) {
    if(!alignRight) {
      return XmlElement(
          XmlName('w:tc'),
          [],
          [
            XmlElement(XmlName('w:p'), [], [
              XmlElement(XmlName('w:pPr'), [], [
                XmlElement(
                    XmlName('w:jc'),
                    [XmlAttribute(XmlName('w:val'), 'left')],
                    []
                ),
              ]),
              XmlElement(XmlName('w:r'), [], [
                XmlElement(XmlName('w:rPr'), [], [
                  XmlElement(
                      XmlName('w:rFonts'),
                      [
                        XmlAttribute(XmlName('w:ascii'), 'Arial'),
                        XmlAttribute(XmlName('w:hAnsi'), 'Arial'),
                        XmlAttribute(XmlName('w:cs'), 'Arial'),
                      ],
                      []
                  ),
                  XmlElement(
                      XmlName('w:sz'),
                      [XmlAttribute(XmlName('w:val'), '20')],
                      []
                  ),
                ]),
                XmlElement(XmlName('w:t'), [], [XmlText(text)]),
              ]),
            ]),
          ]
      );
    }else{
      return XmlElement(
          XmlName('w:tc'),
          [],
          [
            XmlElement(XmlName('w:p'), [], [
              XmlElement(XmlName('w:pPr'), [], [
                XmlElement(
                    XmlName('w:jc'),
                    [XmlAttribute(XmlName('w:val'), 'right')],
                    []
                ),
              ]),
              XmlElement(XmlName('w:r'), [], [
                XmlElement(XmlName('w:rPr'), [], [
                  XmlElement(
                      XmlName('w:rFonts'),
                      [
                        XmlAttribute(XmlName('w:ascii'), 'Arial'),
                        XmlAttribute(XmlName('w:hAnsi'), 'Arial'),
                        XmlAttribute(XmlName('w:cs'), 'Arial'),
                      ],
                      []
                  ),
                  XmlElement(
                      XmlName('w:sz'),
                      [XmlAttribute(XmlName('w:val'), '20')],
                      []
                  ),
                ]),
                XmlElement(XmlName('w:t'), [], [XmlText(text)]),
              ]),
            ]),
          ]
      );
    }
  }
}