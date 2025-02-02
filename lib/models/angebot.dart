import 'dart:convert';
import 'dart:io';

import 'package:angebote_manager/models/angebotsleistung.dart';
import 'package:angebote_manager/models/unterleistung.dart';
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
  final String city;
  final String project;
  final String anschrift;
  final String date;
  List<AngebotsLeistung> leistungen;

  Angebot({
    required this.name,
    this.zH,
    required this.address,
    required this.city,
    required this.project,
    required this.anschrift,
    required this.date,
    required this.leistungen,
  });

  Future<bool> createDocument() async {
    var data = await rootBundle.load('documents/Vorlage.docx');

    final bytes = data.buffer.asUint8List();

    var archive = ZipDecoder().decodeBytes(bytes);

    ArchiveFile? documentXmlFile = archive.firstWhere(
          (file) => file.name == 'word/document.xml',
    );

    if (documentXmlFile != null) {
      print('Found document.xml!');

      String documentXmlContent = String.fromCharCodes(documentXmlFile.content);

      //
      // ** Angebot **
      //

      documentXmlContent = documentXmlContent
          .replaceAll('#address#', encodeForWord(address))
          .replaceAll('#city#', "A- ${encodeForWord(city)}")
          .replaceAll("#project#", encodeForWord(project.split("\n")[0]))
          .replaceAll("#date#", date);

      if(project.split("\n").length > 1) {
        documentXmlContent = documentXmlContent.replaceAll("#project2#", encodeForWord(project.split("\n")[1]));
      }else{
        documentXmlContent = documentXmlContent.replaceAll("#project2#", "");
      }

      if(zH != null) {
        documentXmlContent = documentXmlContent
            .replaceAll('#name#', encodeForWord(name))
            .replaceAll('#zH#', encodeForWord(zH!));
      }else{
        documentXmlContent = documentXmlContent
            .replaceAll('#name#', "")
            .replaceAll('#zH#', encodeForWord(name));
      }

      // Anschrift
      List<String> nameParts;
      if(zH != null) {
        nameParts = zH!.split(" ");
      }else{
        nameParts = name.split(" ");
      }

      if(anschrift == "Damen und Herren") {
        documentXmlContent = documentXmlContent.replaceAll("#anschrift#", "Sehr geehrte Damen und Herren");
      } else if(anschrift == "Frau") {
        documentXmlContent = documentXmlContent.replaceAll("#anschrift#", "Sehr geehrte Frau ${encodeForWord(nameParts.last)}");
      } else if(anschrift == "Herr") {
        documentXmlContent = documentXmlContent.replaceAll("#anschrift#", "Sehr geehrter Herr ${encodeForWord(nameParts.last)}");
      } else if(anschrift == "Familie") {
        documentXmlContent = documentXmlContent.replaceAll("#anschrift#", "Sehr geehrte Familie ${encodeForWord(nameParts.last)}");
      }

      final updatedDocument = XmlDocument.parse(documentXmlContent);
      final lvPlaceholder = updatedDocument.findAllElements('w:p').where((element) => element.innerText == "#LV#");


      double finalNettoPrice = 0.0;
      if(leistungen.isNotEmpty) {
        final tableElements = updatedDocument.findAllElements('w:tbl').toList();
        final tableElement = tableElements[1];

        tableElement.children.removeWhere((row) {
          if (row is XmlElement && row.name.local == 'w:tr') {
            String rowName = row.findElements('w:t').first.text;
            return !leistungen.any((angebotsleistung) => angebotsleistung.leistung.name == rowName);
          }
          return false;
        });

        for (var angebotsLeistung in leistungen) {
          finalNettoPrice+=angebotsLeistung.totalPriceAsDouble;

          final rowElement = XmlElement(XmlName('w:tr'));
          rowElement.children.add(createCell(encodeForWord(angebotsLeistung.leistung.name), false));
          rowElement.children.add(createCell(encodeForWord(angebotsLeistung.amountString), true));
          rowElement.children.add(createCell(encodeForWord(angebotsLeistung.unit), true));
          rowElement.children.add(createCell(encodeForWord(angebotsLeistung.singlePriceString), true));
          rowElement.children.add(createCell(encodeForWord(angebotsLeistung.totalPrice), true));
          tableElement.children.insert(3, rowElement);
        }

        //
        // ** Leistungsverzeichnis **
        //

        for (int i = 0; i < leistungen.length; i++) {
          final newLvEntry = XmlDocumentFragment.parse(await lvEntry(leistungen[i])).root;

          try {
            final parent = lvPlaceholder.first.parent;

            if (parent != null) {
              final insertIndex = parent.children.indexOf(lvPlaceholder.first);
              parent.children.insert(insertIndex + 1, newLvEntry);
            }
          }catch(e) {
            throw("Platzhalter #LV# nicht gefunden");
          }
        }
      }

      documentXmlContent = updatedDocument.toString();

      // Price calculation
      var ust = (finalNettoPrice / 100) * 20;
      var finalBruttoPrice = finalNettoPrice + ust;

      var finalNettoPriceFormatted = finalNettoPrice.toStringAsFixed(2).replaceAll(".", ",");
      var ustFormatted = ust.toStringAsFixed(2).replaceAll(".", ",");
      var finalBruttoPriceFormatted = finalBruttoPrice.toStringAsFixed(2).replaceAll(".", ",");

      documentXmlContent = documentXmlContent
          .replaceAll("#netto#", formatNumber(finalNettoPriceFormatted))
          .replaceAll("#ust#", formatNumber(ustFormatted))
          .replaceAll("#inklUst#", formatNumber(finalBruttoPriceFormatted));

      documentXmlContent = documentXmlContent
          .replaceAll("&#x9F;", "")
          .replaceAll("&#x82;", "")
          .replaceAll("&#x84;", "")
          .replaceAll("&#x96;", "")
          .replaceAll("&#x9C;", "")
          .replaceAll("&#x80;", "")
          .replaceAll("&#x93;", "")
          .replaceAll("&#x9E;", "")
          .replaceAll("&#x9D;", "")
          .replaceAll("#LV#", " ");


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
      return true;
    } else {
      print('document.xml nicht gefunden');
      return false;
    }
  }

  String formatNumber(String value) {
    final parts = value.split(',');
    String integerPart = parts[0];
    String decimalPart = parts[1];

    final buffer = StringBuffer();
    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(integerPart[i]);
    }

    return '${buffer.toString()},$decimalPart';
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

  String encodeForWord(String text) {
    return text
        .replaceAll("ä", "Ã¤")
        .replaceAll("Ä", "Ã")
        .replaceAll("ö", "Ã¶")
        .replaceAll("Ö", "Ã")
        .replaceAll("ß", "Ã")
        .replaceAll("“", "â")
        .replaceAll("„", "â")
        .replaceAll("Ü", "Ã")
        .replaceAll("ü", "Ã¼")
        .replaceAll(" – ", " â ")
        .replaceAll("²", "Â²");
  }

  Future<String> getDocumentXmlContent(String file) async {
    var data = await rootBundle.load(file);

    final bytes = data.buffer.asUint8List();

    var archive = ZipDecoder().decodeBytes(bytes);

    ArchiveFile? documentXmlFile = archive.firstWhere(
          (file) => file.name == 'word/document.xml',
    );

    if (documentXmlFile != null) {
      String documentXmlContent = String.fromCharCodes(documentXmlFile.content);
      return documentXmlContent;
    }
    return "";
  }

  Future<String> lvEntry(AngebotsLeistung angebotsLeistung) async {
    String title = encodeForWord(angebotsLeistung.leistung.name);
    String description = encodeForWord(angebotsLeistung.leistung.description);
    String amount = angebotsLeistung.amountString;
    List<Unterleistung>? unterleistungen = angebotsLeistung.leistung.unterleistungen;
    String unit = encodeForWord(angebotsLeistung.unit);
    String singlePrice = angebotsLeistung.singlePriceString;
    String totalPrice = angebotsLeistung.totalPrice.toString();

    String documentXmlContent = await getDocumentXmlContent("documents/templates.docx");

    final updatedDocument = XmlDocument.parse(documentXmlContent);
    final lvPlaceholder = updatedDocument.findAllElements('w:p').where((element) => element.innerText == "#lvEntry#");

    var sibling = lvPlaceholder.first.nextSibling;
    bool pageBreakFound = false;
    StringBuffer result = StringBuffer();


    if(description.isEmpty) {
      final descriptionPlaceholder = updatedDocument.findAllElements('w:p').where((element) => element.innerText == "LeistungDescription");
      descriptionPlaceholder.first.nextSibling?.remove();
      descriptionPlaceholder.first.remove();
    }


    final unterleistungenPlaceholder = updatedDocument.findAllElements('w:p').where((element) => element.innerText == "#unterleistungen#");

    if(unterleistungen != null) {
      final unterLvEntries = XmlDocumentFragment.parse(await unterlvEntry(unterleistungen)).root;

      int? insertIndex = unterleistungenPlaceholder.first.parent?.children.indexOf(unterleistungenPlaceholder.first);

      if(insertIndex != null) {
        unterleistungenPlaceholder.first.parent?.children.insert(insertIndex+1, unterLvEntries);
      }
    }

    unterleistungenPlaceholder.first.remove();

    while(sibling != null) {
      XmlNode pageBreak = XmlElement(
          XmlName('w:r'),
          [],
          [
            XmlElement(
                XmlName('w:br'),
                [XmlAttribute(XmlName('w:type'), 'page')]
            ),
          ]
      );

      for(int i = 0; i < sibling.children.length; i++) {
        if(sibling.children[i].isEqualNode(pageBreak)) {
          pageBreakFound = true;
          break;
        }
      }

      if (pageBreakFound) {
        break;
      }

      // Aufzählungszeichen fixxen
      final numIdElements = updatedDocument.findAllElements('w:numId');

      for (var element in numIdElements) {
        final valAttribute = element.getAttributeNode('w:val');
        if (valAttribute != null && valAttribute.value == '1') {
          valAttribute.value = '16';
        } else if (valAttribute != null && valAttribute.value == '4') {
          valAttribute.value = '14';
        }
      }
      result.write(sibling.toString());
      sibling = sibling.nextSibling;
    }

    return result.toString()
        .replaceAll("#leistung#", title)
        .replaceAll("LeistungDescription", description)
        .replaceAll("#amount#", amount)
        .replaceAll("#unit#", unit)
        .replaceAll("#single#", singlePrice)
        .replaceAll("#total#", totalPrice);
  }

  Future<String> unterlvEntry(List<Unterleistung> unterleistungen) async {
    List<Future<String>> unterLvsFutures = unterleistungen.map((unterleistung) async {
      String name = encodeForWord(unterleistung.name);
      String? description;
      if (unterleistung.description != null) {
        description = encodeForWord(unterleistung.description!);
      }

      String documentXmlContent = await getDocumentXmlContent("documents/templates.docx");
      final updatedDocument = XmlDocument.parse(documentXmlContent);

      final unterLvPlaceholder = updatedDocument.findAllElements('w:p').where((element) => element.innerText == "#unterlvEntry#");

      var sibling = unterLvPlaceholder.first.nextSibling;
      bool pageBreakFound = false;
      StringBuffer result = StringBuffer();

      if (description == null) {
        final descriptionPlaceholder = updatedDocument.findAllElements('w:p').where((element) => element.innerText == "#unterleistungDescription#");
        if (descriptionPlaceholder.isNotEmpty) {
          descriptionPlaceholder.first.nextSibling?.remove();
          descriptionPlaceholder.first.remove();
        }
      }

      while (sibling != null) {
        XmlNode pageBreak = XmlElement(
          XmlName('w:r'),
          [],
          [
            XmlElement(
              XmlName('w:br'),
              [XmlAttribute(XmlName('w:type'), 'page')],
            ),
          ],
        );

        for (int i = 0; i < sibling.children.length; i++) {
          if (sibling.children[i].isEqualNode(pageBreak)) {
            pageBreakFound = true;
            break;
          }
        }

        if (pageBreakFound) {
          break;
        }

        result.write(sibling.toXmlString(pretty: true));
        sibling = sibling.nextSibling;
      }

      if (description != null) {
        return result.toString()
            .replaceAll("#unterleistung#", name)
            .replaceAll("#unterleistungDescription#", description);
      }
      return result.toString().replaceAll("#unterleistung#", name);
    }).toList();

    List<String> unterLvs = await Future.wait(unterLvsFutures);
    return unterLvs.join("\n");
  }

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'zH': zH ?? "",
      'address': address,
      'city': city,
      'project': project,
      'anschrift': anschrift,
      'date': date,
    };
  }
}