import 'dart:io';

import 'package:angebote_manager/angebotsleistung.dart';
import 'package:angebote_manager/unterleistung.dart';
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
  List<AngebotsLeistung> leistungen;

  Angebot({
    required this.name,
    this.zH,
    required this.address,
    required this.city,
    required this.project,
    required this.anschrift,
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

      var now = DateTime.now();
      var formatter = DateFormat('dd.MM.yyyy');
      String formattedDate = formatter.format(now);
      
      if(zH != null) {
        documentXmlContent = documentXmlContent
            .replaceAll('#name#', encodeForWord(name))
            .replaceAll('#address#', encodeForWord(address))
            .replaceAll('#city#', "A- ${encodeForWord(city)}")
            .replaceAll('#zH#', encodeForWord(zH!))
            .replaceAll("#project#", encodeForWord(project))
            .replaceAll("#date#", formattedDate);

        List<String> nameParts = zH!.split(" ");
        if(anschrift == "Damen und Herren") {
          documentXmlContent = documentXmlContent.replaceAll("#anschrift#", "Sehr geehrte Damen und Herren");
        } else if(anschrift == "Frau") {
          documentXmlContent = documentXmlContent.replaceAll("#anschrift#", "Sehr geehrte Frau ${encodeForWord(nameParts.last)}");
        } else if(anschrift == "Herr") {
          documentXmlContent = documentXmlContent.replaceAll("#anschrift#", "Sehr geehrter Herr ${encodeForWord(nameParts.last)}");
        }
      }else{
        documentXmlContent = documentXmlContent
            .replaceAll('#name#', "")
            .replaceAll('#address#', encodeForWord(address))
            .replaceAll('#city#', "A- ${encodeForWord(city)}")
            .replaceAll('#zH#', encodeForWord(name))
            .replaceAll("#project#", encodeForWord(project))
            .replaceAll("#date#", formattedDate);

        // Anschrift

        List<String> nameParts = name.split(" ");
        
        if(anschrift == "Damen und Herren") {
          documentXmlContent = documentXmlContent.replaceAll("#anschrift#", "Sehr geehrte Damen und Herren");
        } else if(anschrift == "Frau") {
          documentXmlContent = documentXmlContent.replaceAll("#anschrift#", "Sehr geehrte Frau ${encodeForWord(nameParts.last)}");
        } else if(anschrift == "Herr") {
          documentXmlContent = documentXmlContent.replaceAll("#anschrift#", "Sehr geehrter Herr ${encodeForWord(nameParts.last)}");
        }
      }

      print("Ganz am Anfang: $documentXmlContent");

      final updatedDocument = XmlDocument.parse(documentXmlContent);
      final lvPlaceholder = updatedDocument.findAllElements('w:t').where((element) => element.text == "#LV#");

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
          final newLvEntry = XmlDocumentFragment.parse(lvEntry(leistungen[i])).root;

          try {
            final parent = lvPlaceholder.first.parent?.parent?.parent;

            if (parent != null) {
              parent.children.insert(50, newLvEntry);
            }
          }catch(e) {
            throw("Platzhalter ~23sF nicht gefunden");
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
                            .replaceAll("#netto#", finalNettoPriceFormatted)
                            .replaceAll("#ust#", ustFormatted)
                            .replaceAll("#inklUst#", finalBruttoPriceFormatted);

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

      print("$documentXmlContent");

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
        .replaceAll("²", "Â²")
        .replaceAll("~23sF", " ");
  }

  String lvEntry(AngebotsLeistung angebotsLeistung) {
    String title = encodeForWord(angebotsLeistung.leistung.name);
    String description = encodeForWord(angebotsLeistung.leistung.description);
    String amount = angebotsLeistung.amountString;
    List<Unterleistung>? unterleistungen = angebotsLeistung.leistung.unterleistungen;
    String unit = encodeForWord(angebotsLeistung.unit);
    String singlePrice = angebotsLeistung.singlePriceString;
    String totalPrice = angebotsLeistung.totalPrice.toString();

    return '''
         <w:p w14:paraId="2DB10B8C" w14:textId="77777777" w:rsidP="00DF092C" w:rsidR="00DF092C" w:rsidRDefault="00DF092C" w:rsidRPr="00B0488F">
            <w:pPr>
                <w:pStyle w:val="Listenabsatz" />
                <w:numPr>
                    <w:ilvl w:val="0" />
                    <w:numId w:val="16" />
                </w:numPr>
                <w:rPr>
                    <w:rFonts w:ascii="Gisha" w:cs="Gisha" w:hAnsi="Gisha" />
                    <w:iCs />
                    <w:color w:val="1C1C1C" />
                    <w:sz w:val="20" />
                    <w:szCs w:val="20" />
                </w:rPr>
            </w:pPr>
            <w:r>
                <w:rPr>
                    <w:rFonts w:ascii="Gisha" w:cs="Gisha" w:hAnsi="Gisha" />
                    <w:i />
                    <w:iCs />
                    <w:color w:val="1C1C1C" />
                    <w:sz w:val="26" />
                    <w:szCs w:val="26" />
                    <w:u w:val="single" />
                </w:rPr>
                <w:t>$title</w:t>
            </w:r>
        </w:p>
        ${description.isNotEmpty ? '''
        <w:p w14:paraId="7C14C7B5" w14:textId="77777777" w:rsidP="00DF092C" w:rsidR="00DF092C" w:rsidRDefault="00DF092C" w:rsidRPr="009E36B2">
            <w:pPr>
                <w:ind w:left="1416" />
                <w:rPr>
                    <w:rFonts w:ascii="Gisha" w:cs="Gisha" w:hAnsi="Gisha" />
                    <w:iCs />
                    <w:color w:val="1C1C1C" />
                    <w:sz w:val="20" />
                    <w:szCs w:val="20" />
                </w:rPr>
            </w:pPr>
        </w:p>
        <w:p w14:paraId="443E6064" w14:textId="77777777" w:rsidP="00DF092C" w:rsidR="00DF092C" w:rsidRDefault="00DF092C">
                <w:pPr>
                    <w:ind w:left="708" />
                    <w:rPr>
                        <w:rFonts w:ascii="Gisha" w:cs="Gisha" w:hAnsi="Gisha" />
                        <w:color w:val="1C1C1C" />
                        <w:sz w:val="20" />
                        <w:szCs w:val="20" />
                    </w:rPr>
                </w:pPr>
                
                <w:r>
                    <w:rPr>
                        <w:rFonts w:ascii="Gisha" w:cs="Gisha" w:hAnsi="Gisha" />
                        <w:color w:val="1C1C1C" />
                        <w:sz w:val="22" />
                        <w:szCs w:val="22" />
                    </w:rPr>
                    <w:t>$description</w:t>
                </w:r>
                
            </w:p>
            ''' : ''}
        <w:p w14:paraId="58D5D565" w14:textId="77777777" w:rsidP="00DF092C" w:rsidR="00DF092C"
            w:rsidRDefault="00DF092C" w:rsidRPr="00BC3FAA">
            <w:pPr>
                <w:rPr>
                    <w:rFonts w:ascii="Gisha" w:cs="Gisha" w:hAnsi="Gisha" />
                    <w:color w:val="1C1C1C" />
                    <w:sz w:val="20" />
                    <w:szCs w:val="20" />
                </w:rPr>
            </w:pPr>
        </w:p>
        ${unterleistungen != null ? unterlvEntry(unterleistungen) : ""}
        <w:p w14:paraId="1E686194" w14:textId="77777777" w:rsidP="00DF092C"
            w:rsidR="00DF092C" w:rsidRDefault="00DF092C">
            <w:pPr>
                <w:rPr>
                    <w:rFonts w:ascii="Gisha" w:cs="Gisha" w:hAnsi="Gisha" />
                    <w:color w:val="1C1C1C" />
                </w:rPr>
            </w:pPr>
            <w:r w:rsidRPr="002D168E">
                <w:rPr>
                    <w:rFonts w:ascii="Gisha" w:cs="Gisha" w:hAnsi="Gisha" />
                    <w:color w:val="1C1C1C" />
                </w:rPr>
                <w:tab />
            </w:r>
            <w:r w:rsidRPr="002D168E">
                <w:rPr>
                    <w:rFonts w:ascii="Gisha" w:cs="Gisha" w:hAnsi="Gisha" />
                    <w:color w:val="1C1C1C" />
                </w:rPr>
                <w:tab />
            </w:r>
            <w:r w:rsidRPr="002D168E">
                <w:rPr>
                    <w:rFonts w:ascii="Gisha" w:cs="Gisha" w:hAnsi="Gisha" />
                    <w:color w:val="1C1C1C" />
                </w:rPr>
                <w:tab />
            </w:r>
            <w:r w:rsidRPr="002D168E">
                <w:rPr>
                    <w:rFonts w:ascii="Gisha" w:cs="Gisha" w:hAnsi="Gisha" />
                    <w:color w:val="1C1C1C" />
                </w:rPr>
                <w:tab />
            </w:r>
            <w:r w:rsidRPr="002D168E">
                <w:rPr>
                    <w:rFonts w:ascii="Gisha" w:cs="Gisha" w:hAnsi="Gisha" />
                    <w:color w:val="1C1C1C" />
                </w:rPr>
                <w:tab />
            </w:r>
            <w:r w:rsidRPr="002D168E">
                <w:rPr>
                    <w:rFonts w:ascii="Gisha" w:cs="Gisha" w:hAnsi="Gisha" />
                    <w:color w:val="1C1C1C" />
                </w:rPr>
                <w:tab />
            </w:r>
            <w:r w:rsidRPr="002D168E">
                <w:rPr>
                    <w:rFonts w:ascii="Gisha" w:cs="Gisha" w:hAnsi="Gisha" />
                    <w:color w:val="1C1C1C" />
                </w:rPr>
                <w:tab />
            </w:r>
            <w:r w:rsidRPr="002D168E">
                <w:rPr>
                    <w:rFonts w:ascii="Arial" w:cs="Arial" w:hAnsi="Arial" />
                    <w:color w:val="1C1C1C" />
                    <w:sz w:val="16" />
                    <w:szCs w:val="16" />
                </w:rPr>
                <w:t xml:space="preserve">Menge          Einheit         </w:t>
            </w:r>
            <w:r>
                <w:rPr>
                    <w:rFonts w:ascii="Arial" w:cs="Arial" w:hAnsi="Arial" />
                    <w:color w:val="1C1C1C" />
                    <w:sz w:val="16" />
                    <w:szCs w:val="16" />
                </w:rPr>
                <w:t xml:space="preserve"> </w:t>
            </w:r>
            <w:r w:rsidRPr="002D168E">
                <w:rPr>
                    <w:rFonts w:ascii="Arial" w:cs="Arial" w:hAnsi="Arial" />
                    <w:color w:val="1C1C1C" />
                    <w:sz w:val="16" />
                    <w:szCs w:val="16" />
                </w:rPr>
                <w:t xml:space="preserve"> Einzelpreis         </w:t>
            </w:r>
            <w:r>
                <w:rPr>
                    <w:rFonts w:ascii="Arial" w:cs="Arial" w:hAnsi="Arial" />
                    <w:color w:val="1C1C1C" />
                    <w:sz w:val="16" />
                    <w:szCs w:val="16" />
                </w:rPr>
                <w:t xml:space="preserve">  </w:t>
            </w:r>
            <w:r w:rsidRPr="002D168E">
                <w:rPr>
                    <w:rFonts w:ascii="Arial" w:cs="Arial" w:hAnsi="Arial" />
                    <w:color w:val="1C1C1C" />
                    <w:sz w:val="16" />
                    <w:szCs w:val="16" />
                </w:rPr>
                <w:t xml:space="preserve"> </w:t>
            </w:r>
            <w:proofErr w:type="gramStart" />
            <w:r w:rsidRPr="002D168E">
                <w:rPr>
                    <w:rFonts w:ascii="Arial" w:cs="Arial" w:hAnsi="Arial" />
                    <w:color w:val="1C1C1C" />
                    <w:sz w:val="16" />
                    <w:szCs w:val="16" />
                </w:rPr>
                <w:t>Gesamt</w:t>
            </w:r>
            <w:proofErr w:type="gramEnd" />
        </w:p>
        <w:tbl>
            <w:tblPr>
                <w:tblStyle w:val="Tabellenraster" />
                <w:tblW w:type="auto" w:w="0" />
                <w:tblBorders>
                    <w:top w:color="auto" w:space="0" w:sz="6" w:val="single" />
                    <w:left w:color="auto" w:space="0" w:sz="0" w:val="none" />
                    <w:bottom w:color="auto" w:space="0" w:sz="6" w:val="single" />
                    <w:right w:color="auto" w:space="0" w:sz="0" w:val="none" />
                    <w:insideH w:color="auto" w:space="0" w:sz="0" w:val="none" />
                    <w:insideV w:color="auto" w:space="0" w:sz="0" w:val="none" />
                </w:tblBorders>
                <w:tblLook w:firstColumn="1" w:firstRow="1" w:lastColumn="0" w:lastRow="0"
                    w:noHBand="0" w:noVBand="1" w:val="04A0" />
            </w:tblPr>
            <w:tblGrid>
                <w:gridCol w:w="4302" />
                <w:gridCol w:w="1288" />
                <w:gridCol w:w="811" />
                <w:gridCol w:w="1358" />
                <w:gridCol w:w="1116" />
            </w:tblGrid>
            <w:tr w14:paraId="3A9806A6" w14:textId="77777777" w:rsidR="00DF092C"
                w:rsidTr="00E279CF">
                <w:tc>
                    <w:tcPr>
                        <w:tcW w:type="dxa" w:w="4302" />
                    </w:tcPr>
                    <w:p w14:paraId="25743519" w14:textId="77777777" w:rsidP="00E279CF"
                        w:rsidR="00DF092C" w:rsidRDefault="00DF092C" w:rsidRPr="00DF092C">
                        <w:pPr>
                            <w:rPr>
                                <w:rFonts w:ascii="Arial" w:cs="Arial" w:hAnsi="Arial" />
                                <w:bCs />
                                <w:color w:val="1C1C1C" />
                                <w:sz w:val="20" />
                                <w:szCs w:val="20" />
                            </w:rPr>
                        </w:pPr>
                    </w:p>
                </w:tc>
                <w:tc>
                    <w:tcPr>
                        <w:tcW w:type="dxa" w:w="1288" />
                    </w:tcPr>
                    <w:p w14:paraId="7625BABF" w14:textId="796376FC" w:rsidP="00E279CF"
                        w:rsidR="00DF092C" w:rsidRDefault="00DF092C" w:rsidRPr="00DF092C">
                        <w:pPr>
                            <w:jc w:val="right" />
                            <w:rPr>
                                <w:rFonts w:ascii="Arial" w:cs="Arial" w:hAnsi="Arial" />
                                <w:bCs />
                                <w:color w:val="1C1C1C" />
                            </w:rPr>
                        </w:pPr>
                        <w:r w:rsidRPr="00DF092C">
                            <w:rPr>
                                <w:rFonts w:ascii="Arial" w:cs="Arial" w:hAnsi="Arial" />
                                <w:bCs />
                                <w:color w:val="1C1C1C" />
                                <w:sz w:val="20" />
                                <w:szCs w:val="20" />
                            </w:rPr>
                            <w:t>$amount</w:t>
                        </w:r>
                    </w:p>
                </w:tc>
                <w:tc>
                    <w:tcPr>
                        <w:tcW w:type="dxa" w:w="811" />
                    </w:tcPr>
                    <w:p w14:paraId="207A3A35" w14:textId="2BD76982" w:rsidP="00E279CF"
                        w:rsidR="00DF092C" w:rsidRDefault="00DF092C" w:rsidRPr="00DF092C">
                        <w:pPr>
                            <w:jc w:val="right" />
                            <w:rPr>
                                <w:rFonts w:ascii="Arial" w:cs="Arial" w:hAnsi="Arial" />
                                <w:bCs />
                                <w:color w:val="1C1C1C" />
                            </w:rPr>
                        </w:pPr>
                        <w:r w:rsidRPr="00DF092C">
                            <w:rPr>
                                <w:rFonts w:ascii="Arial" w:cs="Arial" w:hAnsi="Arial" />
                                <w:bCs />
                                <w:color w:val="1C1C1C" />
                                <w:sz w:val="20" />
                                <w:szCs w:val="20" />
                            </w:rPr>
                            <w:t>$unit</w:t>
                        </w:r>
                    </w:p>
                </w:tc>
                <w:tc>
                    <w:tcPr>
                        <w:tcW w:type="dxa" w:w="1358" />
                    </w:tcPr>
                    <w:p w14:paraId="0C17D0CF" w14:textId="58E6920D" w:rsidP="00E279CF"
                        w:rsidR="00DF092C" w:rsidRDefault="00DF092C" w:rsidRPr="00DF092C">
                        <w:pPr>
                            <w:jc w:val="right" />
                            <w:rPr>
                                <w:rFonts w:ascii="Arial" w:cs="Arial" w:hAnsi="Arial" />
                                <w:bCs />
                                <w:color w:val="1C1C1C" />
                            </w:rPr>
                        </w:pPr>
                        <w:r>
                            <w:rPr>
                                <w:rFonts w:ascii="Arial" w:cs="Arial" w:hAnsi="Arial" />
                                <w:bCs />
                                <w:color w:val="1C1C1C" />
                                <w:sz w:val="20" />
                                <w:szCs w:val="20" />
                            </w:rPr>
                            <w:t>$singlePrice</w:t>
                        </w:r>
                    </w:p>
                </w:tc>
                <w:tc>
                    <w:tcPr>
                        <w:tcW w:type="dxa" w:w="1116" />
                    </w:tcPr>
                    <w:p w14:paraId="08B2489B" w14:textId="2F8B0889" w:rsidP="00E279CF"
                        w:rsidR="00DF092C" w:rsidRDefault="00DF092C" w:rsidRPr="00DF092C">
                        <w:pPr>
                            <w:jc w:val="right" />
                            <w:rPr>
                                <w:rFonts w:ascii="Arial" w:cs="Arial" w:hAnsi="Arial" />
                                <w:bCs />
                                <w:color w:val="1C1C1C" />
                            </w:rPr>
                        </w:pPr>
                        <w:r>
                            <w:rPr>
                                <w:rFonts w:ascii="Arial" w:cs="Arial" w:hAnsi="Arial" />
                                <w:bCs />
                                <w:color w:val="1C1C1C" />
                                <w:sz w:val="20" />
                                <w:szCs w:val="20" />
                            </w:rPr>
                            <w:t>$totalPrice</w:t>
                        </w:r>
                    </w:p>
                </w:tc>
            </w:tr>
        </w:tbl>
        <w:p w14:paraId="7C14C7B5" w14:textId="77777777" w:rsidP="00DF092C" w:rsidR="00DF092C" w:rsidRDefault="00DF092C" w:rsidRPr="009E36B2">
            <w:pPr>
                <w:rPr>
                    <w:rFonts w:ascii="Gisha" w:cs="Gisha" w:hAnsi="Gisha" />
                    <w:iCs />
                    <w:color w:val="1C1C1C" />
                    <w:sz w:val="20" />
                    <w:szCs w:val="20" />
                </w:rPr>
            </w:pPr>
        </w:p>
        ''';
  }

  String unterlvEntry(List<Unterleistung> unterleistungen) {
    return unterleistungen.map((unterleistung) {
      String name = encodeForWord(unterleistung.name);
      String? description;
      if(unterleistung.description != null) {
        description = encodeForWord(unterleistung.description!);
      }

      return '''
        <w:p w14:paraId="02A44904" w14:textId="77777777" w:rsidP="00C27CC0"
            w:rsidR="00C27CC0" w:rsidRDefault="00C27CC0">
            <w:pPr>
                <w:numPr>
                    <w:ilvl w:val="0" />
                    <w:numId w:val="14" />
                </w:numPr>
                <w:tabs>
                    <w:tab w:pos="720" w:val="num" />
                </w:tabs>
                <w:ind w:left="720" />
                <w:rPr>
                    <w:rFonts w:ascii="Gisha" w:cs="Gisha" w:hAnsi="Gisha" w:hint="cs" />
                    <w:color w:val="1C1C1C" />
                    <w:sz w:val="22" />
                    <w:szCs w:val="22" />
                </w:rPr>
            </w:pPr>
            <w:r>
                <w:rPr>
                    <w:rFonts w:ascii="Gisha" w:cs="Gisha" w:hAnsi="Gisha" w:hint="cs" />
                    <w:color w:val="1C1C1C" />
                    <w:sz w:val="22" />
                    <w:szCs w:val="22" />
                </w:rPr>
                <w:t>$name</w:t>
            </w:r>
        </w:p>
        ${description != null ? '''
        <w:p w14:paraId="7391C4D0" w14:textId="77777777" w:rsidP="00C27CC0"
            w:rsidR="00C27CC0" w:rsidRDefault="00C27CC0">
            <w:pPr>
                <w:ind w:left="1416" />
                <w:rPr>
                    <w:rFonts w:ascii="Gisha" w:cs="Gisha" w:hAnsi="Gisha" w:hint="cs" />
                    <w:color w:val="1C1C1C" />
                    <w:sz w:val="20" />
                    <w:szCs w:val="20" />
                </w:rPr>
            </w:pPr>
            <w:r>
                <w:rPr>
                    <w:rFonts w:ascii="Gisha" w:cs="Gisha" w:hAnsi="Gisha" w:hint="cs" />
                    <w:color w:val="1C1C1C" />
                    <w:sz w:val="20" />
                    <w:szCs w:val="20" />
                </w:rPr>
                <w:t xml:space="preserve">$description</w:t>
            </w:r>
        </w:p>
        ''' : ''}
        <w:p w14:paraId="7C14C7B5" w14:textId="77777777" w:rsidP="00DF092C" w:rsidR="00DF092C" w:rsidRDefault="00DF092C" w:rsidRPr="009E36B2">
            <w:pPr>
                <w:rPr>
                    <w:rFonts w:ascii="Gisha" w:cs="Gisha" w:hAnsi="Gisha" />
                    <w:iCs />
                    <w:color w:val="1C1C1C" />
                    <w:sz w:val="20" />
                    <w:szCs w:val="20" />
                </w:rPr>
            </w:pPr>
        </w:p>
    ''';
    }).join("\n");
  }
}