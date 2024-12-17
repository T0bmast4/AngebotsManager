import 'package:angebote_manager/models/leistung.dart';
import 'package:angebote_manager/models/unterleistung.dart';

class PredefinedLeistungen{
  List<Leistung> get predefined_leistungen {
    return
        [
          Leistung(
              name: "Baustellengemeinkosten",
              description: "Sämtliche Baustellengemeinkosten wie Einrichtung, Räumung und Entsorgung, sowie An- und Abreise zur Baustelle",
              units: ["PA", "m²"]
          ),

          Leistung(
              name: "Entfernung des Fliesenbelags",
              description: "Die zu beschichtenden Oberflächen müssen trocken, fest, griffig und frei von Staub, Fett und anderen haftungsstörenden Substanzen sein. Die Abreißfestigkeit des vorbereiteten Untergrundes muss 1,5 N/mm“ betragen. Oberflächenrestfeuchtigkeit max. 4 %. Entfernung der Fliesen und Untergrundvorbereitung durch diamantschleifen.",
              units: ["PA", "m²"]
          ),

          Leistung(
              name: "Entfernung der Altbeschichtung",
              description: "Die zu beschichtenden Oberflächen müssen trocken, fest, griffig und frei von Staub, Fett und anderen haftungsstörenden Substanzen sein. Die Abreißfestigkeit des vorbereiteten Untergrundes muss 1,5 N/mm“ betragen. Oberflächenrestfeuchtigkeit max. 4 %. Entfernung der Altbeschichtung und Untergrundvorbereitung durch diamantschleifen.",
              units: ["m²", "PA"]
          ),

          Leistung(
              name: "Klebereste entfernen",
              description: "Die zu beschichtenden Oberflächen müssen trocken, fest, griffig und frei von Staub, Fett und anderen haftungsstörenden Substanzen sein. Die Abreißfestigkeit des vorbereiteten Untergrundes muss 1,5 N/mm“ betragen. Oberflächenrestfeuchtigkeit max. 4 %. Entfernung der Kleberreste. Diese Bedarfsposition wird nach tatsächlichen Quadratmetern abgerechnet.",
              units: ["m²", "PA"]
          ),

          Leistung(
              name: "Verdübelung von Rissen / Estrichfugen",
              description: "Risse nachschneiden, Querschnitte im Abstand von ca. 25 cm. Einlegen von Stahlstiften in die Querschnitte und vergießen mit 2-Komponenten EP-Flüssigharz. Diese Bedarfsposition wird nach tatsächlich verdübelten Laufmetern abgerechnet.",
              units: ["lfm", "PA"]
          ),

          Leistung(
              name: "Niveauanpassung / Reprofilierung",
              description: "Wiederherstellung einer beschichtungsfähigen Oberfläche durch verfüllen und ausbessern von Hohlräumen mittels eines Mörtels bestehend aus Epoxidharz und feuergetrocknetem Quarzsand stetiger Sieblinie. Diese Bedarfsposition wird nach tatsächlichem Materialverbrauch je kg eingebrachten Mörtel abgerechnet.",
              units: ["kg", "PA"]
          ),

          Leistung(
              name: "Randfugenverschluss",
              description: "Herstellen eines Randfugenverschluss (Boden-Wand) mittels PU-Dichtmasse (betongrau). Diese Bedarfsposition wird nach tatsächlich hergestellten Laufmetern abgerechnet.",
              units: ["lfm", "PA"]
          ),

          Leistung(
              name: "Hohlkehlen",
              description: "Liefern und verlegen eines fertigen Hohlkehlenprofils (PVP), Höhe = 6 cm; Radius = 3 cm, inklusive aller Vor- und Nacharbeiten. Beschichtungsaufbau analog Bodensystem. Diese Bedarfsposition wird nach tatsächlich verlegten Laufmetern abgerechnet.",
              units: ["lfm", "PA"]
          ),

          Leistung(
              name: "Hochzug",
              description: "Herstellen eines Hochzug (h=10 cm) durch grundieren und 2-lagiges versiegeln. Farbe analog Bodensystem. Diese Bedarfsposition wird nach tatsächlich hergestellten Laufmetern abgerechnet.",
              units: ["lfm", "PA"]
          ),

          Leistung(
              name: "Abschlussschienen / Schlüterschienen",
              description: "Liefern und versetzen von „Schlüterschienen“ als Abschluss. Diese Bedarfsposition wird nach tatsächlich verlegten Laufmetern abgerechnet.",
              units: ["lfm", "PA"]
          ),

          Leistung(
              name: "Dichtband zur Fassade",
              description: "Einspachteln eines Dichtbandes für den Übergang Boden-Wand. Diese Bedarfsposition wird nach tatsächlich verlegten Laufmetern abgerechnet.",
              units: ["lfm", "PA"]
          ),

          Leistung(
              name: "Terrassenabschlussprofil",
              description: "Liefern und versetzen von Terrassenabschlussprofilen. Diese Bedarfsposition wird nach tatsächlich verlegten Laufmetern abgerechnet.",
              units: ["lfm", "PA"]
          ),

          Leistung(
              name: "PU-BODENSYSTEM matt, UV-beständig",
              description: "Polyurethan-Bodensystem geeignet für die fugenlose Verarbeitung von tragfähigen Untergründen wie Estriche, Gussasphalt, Fliesen- und Terrazzobelägen, Holzuntergründen, Kunststoffbelägen, wahlweise mit einer speziell gemischten Kunststoffgranulateinstreuung aus verschiedenen Farbtönen.",
              unterleistungen: [
                Unterleistung(
                    name: "Untergrundvorbereitung durch Schleifen",
                    description: "Die zu beschichtenden Oberflächen müssen trocken, fest, griffig und frei von Staub, Fett und anderen haftungsstörenden Substanzen sein. Die Abreißfestigkeit des vorbereiteten Untergrundes muss 1,5 N/mm² betragen. Oberflächenrestfeuchtigkeit max. 4 %. Untergrundvorbereitung durch staubfreies Diamantschleifen."
                ),
                Unterleistung(
                    name: "Randfugenverschluss (wenn erforderlich)",
                    description: "Herstellen eines Randfugenverschluss zwischen Boden und Wand mittels PU-Dichtmasse."
                ),
                Unterleistung(
                    name: "Grundierspachtelung",
                    description: "Aufbringen einer Grundierspachtelung, bestehend aus einem lösemittelfreien, unpigmentierten, niedrigviskosen 2-Komponenten Grundierharz, gemischt mit feuergetrocknetem Quarzsand der Körnung 0,1 – 0,4 mm im Mischungsverhältnis 1 : 0,3, auf die vorbehandelte abgesaugte Bodenfläche. Anschließend vollflächiges absanden der frischen Grundierspachtelung mittels feuergetrocknetem Quarzsand der Körnung 0,3 – 0,8 mm. Verbrauch Bindemittel: 0,5 – 0,7 kg/m²"
                ),
                Unterleistung(
                    name: "Kratzspachtelung",
                    description: "Aufbringen einer Grundierspachtelung, bestehend aus einem lösemittelfreien, unpigmentierten, niedrigviskosen 2-Komponenten Grundierharz, gemischt mit feuergetrocknetem Quarzsand der Körnung 0,1 – 0,4 mm im Mischungsverhältnis 1 : 0,5, auf die vorbehandelte abgesaugte Bodenfläche. Anschließend vollflächiges absanden der frischen Grundierspachtelung mittels feuergetrocknetem Quarzsand der Körnung 0,3 – 0,8 mm. Verbrauch Bindemittel: 0,7 – 1,0 kg/m² (Bedarfsposition)"
                ),
                Unterleistung(
                    name: "PU-Verlaufbeschichtung",
                    description: "Auftragen einer lösemittelfreien, pigmentierten, elastischen und UV-beständigen 2-Komponenten Verlaufbeschichtung auf Polyurethanbasis, wahlweise mit Kunststoffgranulateinstreuung (Chips)."
                ),
                Unterleistung(
                    name: "PU-Flächenversiegelung matt",
                    description: "Aufrollen einer pigmentierten, bzw. unpigmentierten (bei Einstreuung), matten und UV-beständigen 2-Komponenten Versiegelung auf Polyurethanbasis. (RAL-Farbe nach Wahl Auftraggeber)"
                ),
              ],
              units: ["m²", "PA"]
          ),

          Leistung(
              name: "PU-STIEGENVERKLEIDUNG matt",
              description: "Das Beschichtungssystem für die Stufen wird als Pauschale erfasst. Diese beinhaltet:",
              unterleistungen: [
                Unterleistung(name: "Untergrundvorbereitung durch Schleifen"),
                Unterleistung(name: "Aufbringen einer vollflächigen Grundierspachtelung, bestehend aus einem 2-Komponenten Grundierharz gemischt mit Quarzsand"),
                Unterleistung(name: "Liefern und Versetzen der vorgefertigten Stiegenelemente (Setzstufe)"),
                Unterleistung(name: "Beschichten der Trittflächen mit einer pigmentierten 2-Komponenten Verlaufbeschichtung auf Polyurethanbasis (RAL nach Wahl Auftraggeber), wahlweise mit Kunststoffgranulateinstreuung (Chips)."),
                Unterleistung(name: "Aufrollen einer pigmentierten (RAL nach Wahl Auftraggeber), bzw. unpigmentierten (bei Kunststoffgranulateinstreuung) matten 2-Komponenten Versiegelung auf Polyurethanbasis."),
                Unterleistung(name: "Liefern und Versetzen der Übertrittschienen"),
              ],
              units: ["m²", "PA"]
          ),

          Leistung(
              name: "EP-BODENSYSTEM matt",
              description: "",
              unterleistungen: [
                Unterleistung(
                    name: "Untergrundvorbereitung durch Schleifen",
                    description: "Die zu beschichtenden Oberflächen müssen trocken, fest, griffig und frei von Staub, Fett und anderen haftungsstörenden Substanzen sein. Die Abreißfestigkeit des vorbereiteten Untergrundes muss 1,5 N/mm² betragen. Oberflächenrestfeuchtigkeit max. 4 %. Untergrundvorbereitung durch staubfreies Diamantschleifen."
                ),
                Unterleistung(
                    name: "Randfugenverschluss (wenn erforderlich)",
                    description: "Herstellen eines Randfugenverschluss zwischen Boden und Wand mittels PU-Dichtmasse."
                ),
                Unterleistung(
                    name: "Grundierspachtelung",
                    description: "Aufbringen einer Grundierspachtelung, bestehend aus einem lösemittelfreien, unpigmentierten, niedrigviskosen 2-Komponenten Grundierharz, gemischt mit feuergetrocknetem Quarzsand der Körnung 0,1 – 0,4 mm im Mischungsverhältnis 1 : 0,3, auf die vorbehandelte abgesaugte Bodenfläche. Anschließend vollflächiges absanden der frischen Grundierspachtelung mittels feuergetrocknetem Quarzsand der Körnung 0,3 – 0,8 mm. Verbrauch Bindemittel: 0,5 – 0,7 kg/m²."
                ),
                Unterleistung(
                    name: "Kratzspachtelung",
                    description: "Aufbringen einer Grundierspachtelung, bestehend aus einem lösemittelfreien, unpigmentierten, niedrigviskosen 2-Komponenten Grundierharz, gemischt mit feuergetrocknetem Quarzsand der Körnung 0,1 – 0,4 mm im Mischungsverhältnis 1 : 0,5, auf die vorbehandelte abgesaugte Bodenfläche. Anschließend vollflächiges absanden der frischen Grundierspachtelung mittels feuergetrocknetem Quarzsand der Körnung 0,3 – 0,8 mm. Verbrauch Bindemittel: 0,7 – 1,0 kg/m² (Bedarfsposition)."
                ),
                Unterleistung(
                    name: "EP-Verlaufbeschichtung",
                    description: "Auftrag einer lösemittelfreien, pigmentierten 2-Komponenten Verlaufbeschichtung auf Epoxidharzbasis, wahlweise mit Kunststoffgranulateinstreuung (Chips)."
                ),
                Unterleistung(
                    name: "EP-Flächenversiegelung",
                    description: "Aufrollen einer pigmentierten, bzw. unpigmentierten (bei Kunststoffgranulateinstreuung) matten 2-Komponenten Versiegelung auf Epoxidharzbasis. (RAL-Farbe nach Wahl Auftraggeber)."
                ),
              ],
              units: ["m²", "PA"]
          ),
          Leistung(
              name: "EP-STIEGENBESCHICHTUNG matt",
              description: "Das Beschichtungssystem für die Stufen wird als Pauschale erfasst. Diese beinhaltet:",
              unterleistungen: [
                Unterleistung(name: "Untergrundvorbereitung durch Schleifen"),
                Unterleistung(name: "Aufbringen einer vollflächigen Grundierspachtelung, bestehend aus einem 2-Komponenten Grundierharz gemischt mit Quarzsand"),
                Unterleistung(name: "Setzen von Schlüterschienen"),
                Unterleistung(name: "Beschichten der Stufen mit einer pigmentierten 2-Komponenten Verlaufbeschichtung auf Epoxidharzbasis wahlweise mit Kunststoffgranulateinstreuung (Chips)."),
                Unterleistung(name: "Aufrollen einer pigmentierten (RAL analog Bodenbeschichtung), bzw. unpigmentierten (bei Kunststoffgranulateinstreuung) matten 2-Komponenten Versiegelung auf Epoxidharzbasis."),
              ],
              units: ["PA"]
          ),

          Leistung(
              name: "PU-WANDBESCHICHTUNG matt, UV-beständig",
              description: "",
              unterleistungen: [
                Unterleistung(
                    name: "Schleifen und Reinigen",
                    description: "Auf „malerfertig“ vorbereitete Untergründe. Die zu beschichtenden Oberflächen müssen trocken, fest, griffig und frei von Staub, Fett und anderen haftungsstörenden Substanzen sein. Die Abreißfestigkeit des vorbereiteten Untergrundes muss 1,5 N/mm² betragen. Oberflächenrestfeuchtigkeit max. 4 %."
                ),
                Unterleistung(
                    name: "Grundierung EP/Dampfbremse",
                    description: "Vorbehandelten Untergrund nach Herstellervorschrift mit einem lösemittelfreien, unpigmentierten, niedrigviskosen 2-K-System auf Epoxid-Flüssigharzbasis grundieren."
                ),
                Unterleistung(
                    name: "Haftvermittler für Versiegelung",
                    description: "Aufbringen eines geeigneten Haftvermittlers für nachfolgende Versiegelungsarbeiten auf EP-Flüssigharzbasis."
                ),
                Unterleistung(
                    name: "Endversiegelung 1. Lage",
                    description: "Aufbringen einer pigmentierten, matten und UV-beständigen 2-Komponenten Versiegelung auf PU-Flüssigharzbasis mittels Rollen und anschließendem Nachverschlichten, um eine gleichmäßige Oberfläche zu erreichen. Verbrauch: 0,25 kg/m²."
                ),
                Unterleistung(
                    name: "Endversiegelung 2. Lage",
                    description: "Aufbringen einer pigmentierten, matten und UV-beständigen 2-Komponenten Versiegelung auf PU-Flüssigharzbasis mittels Rollen und anschließendem Nachverschlichten, um eine gleichmäßige Oberfläche zu erreichen. Verbrauch: 0,25 kg/m²."
                ),
                Unterleistung(
                    name: "Endversiegelung 3. Lage",
                    description: "Aufbringen einer pigmentierten, matten und UV-beständigen 2-Komponenten Versiegelung auf PU-Flüssigharzbasis mittels Rollen und anschließendem Nachverschlichten, um eine gleichmäßige Oberfläche zu erreichen. Verbrauch: 0,25 kg/m²."
                ),
              ],
              units: ["m²", "PA"]
          ),

          Leistung(
              name: "SICHTESTRICH-VERSIEGELUNG",
              description: "",
              unterleistungen: [
                Unterleistung(
                    name: "Untergrundvorbereitung durch Diamantschleifen",
                    description: "Diamantschleifen des bauseits hergestellten Estrichs. Die zu beschichtenden Oberflächen müssen trocken, fest, griffig und frei von Staub, Fett und anderen haftungsstörenden Substanzen sein. Die Abreißfestigkeit des vorbereiteten Untergrundes muss 1,5 N/mm² betragen. Oberflächenrestfeuchtigkeit max. 4 %."
                ),
                Unterleistung(
                    name: "Beschichtung Sichtestrich",
                    description: "Aufbringen einer klaren Beschichtung/Versiegelung (ohne Vergilbungseffekt, UV-beständig), auf den bauseits hergestellten Estrich in folgenden Arbeitsschritten: \no 2-faches Auftragen einer wässrigen Tiefenimprägnierung durch Aufrollen, \no mehrmaliges Abspachteln (Porenverschluss) mittels transparenter PU-Spachtelmasse, \no 2-lagige Endversiegelung farblos matt."
                ),
              ],
              units: ["m²", "PA"]
          ),

          Leistung(
              name: "SICHTESTRICH-VERSIEGELUNG Treppe",
              description: "",
              unterleistungen: [
                Unterleistung(
                    name: "Untergrundvorbereitung durch Diamantschleifen",
                    description: "Diamantschleifen der Fertigteiltreppe. Die zu beschichtenden Oberflächen müssen trocken, fest, griffig und frei von Staub, Fett und anderen haftungsstörenden Substanzen sein. Die Abreißfestigkeit des vorbereiteten Untergrundes muss 1,5 N/mm² betragen. Oberflächenrestfeuchtigkeit max. 4 %."
                ),
                Unterleistung(
                    name: "Beschichtung Sichtestrich Treppe",
                    description: "Aufbringen einer klaren Beschichtung/Versiegelung (ohne Vergilbungseffekt, UV-beständig), auf der Fertigteiltreppe in folgenden Arbeitsschritten: \no 2-faches Auftragen einer wässrigen Tiefenimprägnierung durch Aufrollen, \no mehrmaliges Abspachteln (Porenverschluss) mittels transparenter PU-Spachtelmasse, \no 2-lagige Endversiegelung farblos matt."
                ),
              ],
              units: ["PA"]
          ),

          Leistung(
              name: "NATURSTEINTEPPICH ab 50m²",
              description: "",
              unterleistungen: [
                Unterleistung(
                    name: "Untergrundvorbereitung durch Schleifen",
                    description: "Die zu beschichtenden Oberflächen müssen trocken, fest, griffig und frei von Staub, Fett und anderen haftungsstörenden Substanzen sein. Die Abreißfestigkeit des vorbereiteten Untergrundes muss 1,5 N/mm² betragen. Oberflächenrestfeuchtigkeit max. 4 %. Untergrundvorbereitung durch staubfreies Diamantschleifen."
                ),
                Unterleistung(
                    name: "Randfugenverschluss (wenn erforderlich)",
                    description: "Herstellen eines Randfugenverschluss zwischen Boden und Wand mittels PU-Dichtmasse."
                ),
                Unterleistung(
                    name: "Grundierspachtelung",
                    description: "Aufbringen einer Grundierspachtelung, bestehend aus einem lösemittelfreien, unpigmentierten, niedrigviskosen 2-Komponenten Grundierharz, gemischt mit feuergetrocknetem Quarzsand der Körnung 0,1 – 0,4 mm im Mischungsverhältnis 1 : 0,5, auf die vorbehandelte abgesaugte Bodenfläche. Anschließend vollflächiges absanden der frischen Grundierspachtelung mittels feuergetrocknetem Quarzsand der Körnung 0,3 – 0,8 mm. Verbrauch Bindemittel: 0,7 – 1,0 kg/m²."
                ),
                Unterleistung(
                    name: "Flächenabdichtung",
                    description: "Aufbringen einer Abdichtungslage auf PU- Flüssigharzbasis."
                ),
                Unterleistung(
                    name: "Natursteinteppich",
                    description: "Einbringen eines Natursteinteppich bestehend aus einem Marmorkiesel oder Quarzkiesel (Farbe nach Wahl Auftraggeber) gemischt mit einem 2-komponentigen, unpigmentierten, UV-beständigen Polyurethanharz."
                ),
              ],
              units: ["m²", "PA"]
          ),

          Leistung(
              name: "NATURSTEINTEPPICH 30-50m²",
              description: "",
              unterleistungen: [
                Unterleistung(
                    name: "Untergrundvorbereitung durch Schleifen",
                    description: "Die zu beschichtenden Oberflächen müssen trocken, fest, griffig und frei von Staub, Fett und anderen haftungsstörenden Substanzen sein. Die Abreißfestigkeit des vorbereiteten Untergrundes muss 1,5 N/mm² betragen. Oberflächenrestfeuchtigkeit max. 4 %. Untergrundvorbereitung durch staubfreies Diamantschleifen."
                ),
                Unterleistung(
                    name: "Randfugenverschluss (wenn erforderlich)",
                    description: "Herstellen eines Randfugenverschluss zwischen Boden und Wand mittels PU-Dichtmasse."
                ),
                Unterleistung(
                    name: "Grundierspachtelung",
                    description: "Aufbringen einer Grundierspachtelung, bestehend aus einem lösemittelfreien, unpigmentierten, niedrigviskosen 2-Komponenten Grundierharz, gemischt mit feuergetrocknetem Quarzsand der Körnung 0,1 – 0,4 mm im Mischungsverhältnis 1 : 0,5, auf die vorbehandelte abgesaugte Bodenfläche. Anschließend vollflächiges absanden der frischen Grundierspachtelung mittels feuergetrocknetem Quarzsand der Körnung 0,3 – 0,8 mm. Verbrauch Bindemittel: 0,7 – 1,0 kg/m²."
                ),
                Unterleistung(
                    name: "Flächenabdichtung",
                    description: "Aufbringen einer Abdichtungslage auf PU-Flüssigharzbasis."
                ),
                Unterleistung(
                    name: "Natursteinteppich",
                    description: "Einbringen eines Natursteinteppich bestehend aus einem Marmorkiesel oder Quarzkiesel (Farbe nach Wahl Auftraggeber) gemischt mit einem 2-komponentigen, unpigmentierten, UV-beständigen Polyurethanharz."
                ),
              ],
              units: ["m²", "PA"]
          ),

          Leistung(
              name: "NATURSTEINTEPPICH bis 30m²",
              description: "",
              unterleistungen: [
                Unterleistung(
                    name: "Untergrundvorbereitung durch Schleifen",
                    description: "Die zu beschichtenden Oberflächen müssen trocken, fest, griffig und frei von Staub, Fett und anderen haftungsstörenden Substanzen sein. Die Abreißfestigkeit des vorbereiteten Untergrundes muss 1,5 N/mm² betragen. Oberflächenrestfeuchtigkeit max. 4 %. Untergrundvorbereitung durch staubfreies Diamantschleifen."
                ),
                Unterleistung(
                    name: "Randfugenverschluss (wenn erforderlich)",
                    description: "Herstellen eines Randfugenverschluss zwischen Boden und Wand mittels PU-Dichtmasse."
                ),
                Unterleistung(
                    name: "Grundierspachtelung",
                    description: "Aufbringen einer Grundierspachtelung, bestehend aus einem lösemittelfreien, unpigmentierten, niedrigviskosen 2-Komponenten Grundierharz, gemischt mit feuergetrocknetem Quarzsand der Körnung 0,1 – 0,4 mm im Mischungsverhältnis 1 : 0,5, auf die vorbehandelte abgesaugte Bodenfläche. Anschließend vollflächiges absanden der frischen Grundierspachtelung mittels feuergetrocknetem Quarzsand der Körnung 0,3 – 0,8 mm. Verbrauch Bindemittel: 0,7 – 1,0 kg/m²."
                ),
                Unterleistung(
                    name: "Flächenabdichtung",
                    description: "Aufbringen einer Abdichtungslage auf PU-Flüssigharzbasis."
                ),
                Unterleistung(
                    name: "Natursteinteppich",
                    description: "Einbringen eines Natursteinteppich bestehend aus einem Marmorkiesel oder Quarzkiesel (Farbe nach Wahl Auftraggeber) gemischt mit einem 2-komponentigen, unpigmentierten, UV-beständigen Polyurethanharz."
                ),
              ],
              units: ["m²", "PA"]
          ),

          Leistung(
              name: "NATURSTEINTEPPICH Stiegen",
              description: "",
              unterleistungen: [
                Unterleistung(
                    name: "Untergrundvorbereitung durch Schleifen",
                    description: "Die zu beschichtenden Oberflächen müssen trocken, fest, griffig und frei von Staub, Fett und anderen haftungsstörenden Substanzen sein. Die Abreißfestigkeit des vorbereiteten Untergrundes muss 1,5 N/mm² betragen. Oberflächenrestfeuchtigkeit max. 4 %. Untergrundvorbereitung durch staubfreies Diamantschleifen."
                ),
                Unterleistung(
                    name: "Grundierspachtelung",
                    description: "Aufbringen einer Grundierspachtelung, bestehend aus einem lösemittelfreien, unpigmentierten, niedrigviskosen 2-Komponenten Grundierharz, gemischt mit feuergetrocknetem Quarzsand der Körnung 0,1 – 0,4 mm im Mischungsverhältnis 1 : 0,5, auf die vorbehandelte abgesaugte Bodenfläche. Anschließend vollflächiges absanden der frischen Grundierspachtelung mittels feuergetrocknetem Quarzsand der Körnung 0,3 – 0,8 mm. Verbrauch Bindemittel: 0,7 – 1,0 kg/m²."
                ),
                Unterleistung(
                    name: "Flächenabdichtung",
                    description: "Aufbringen einer Abdichtungslage auf PU-Flüssigharzbasis."
                ),
                Unterleistung(
                    name: "Abschlussschienen / Schlüterschienen",
                    description: "Liefern und versetzen von „Schlüterschienen“ als Abschluss."
                ),
                Unterleistung(
                    name: "Natursteinteppich",
                    description: "Einbringen eines Natursteinteppich bestehend aus einem Marmorkiesel oder Quarzkiesel (Farbe nach Wahl Auftraggeber) gemischt mit einem 2-komponentigen, unpigmentierten, UV-beständigen Polyurethanharz."
                ),
              ],
              units: ["PA"]
          ),

          Leistung(
              name: "BESCHICHTUNG – OS 8 System",
              description: "Befahrbares Beschichtungssystem geeignet für erdberührte Flächen. RAL-Farbe nach Wahl Auftraggeber (kein Aufpreis für Sonderfarben)!",
              unterleistungen: [
                Unterleistung(
                    name: "Untergrundvorbereitung durch Schleifen",
                    description: "Die zu beschichtenden Oberflächen müssen trocken, fest, griffig und frei von Staub, Fett und anderen haftungsstörenden Substanzen sein. Die Abreißfestigkeit des vorbereiteten Untergrundes muss 1,5 N/mm² betragen. Oberflächenrestfeuchtigkeit max. 4 %. Untergrundvorbereitung durch staubfreies Diamantschleifen."
                ),
                Unterleistung(
                    name: "Randfugenverschluss (wenn erforderlich)",
                    description: "Herstellen eines Randfugenverschluss zwischen Boden und Wand mittels PU-Dichtmasse."
                ),
                Unterleistung(
                    name: "Grundierspachtelung",
                    description: "Aufbringen einer Grundierspachtelung, bestehend aus einem lösemittelfreien, unpigmentierten, niedrigviskosen 2-Komponenten Grundierharz, gemischt mit feuergetrocknetem Quarzsand der Körnung 0,1 – 0,4 mm im Mischungsverhältnis 1 : 0,5, auf die vorbehandelte abgesaugte Bodenfläche. Anschließend vollflächiges absanden der frischen Grundierspachtelung mittels feuergetrocknetem Quarzsand der Körnung 0,3 – 0,8 mm. Verbrauch Bindemittel: 0,7 – 1,0 kg/m²."
                ),
                Unterleistung(
                    name: "Einstreuschicht EP",
                    description: "Vorbehandelten Untergrund nach Herstellervorschrift spachteln mit einem lösemittelfreien, unpigmentierten, niedrigviskosen 2-K-System auf Epoxid-Flüssigharzbasis gemischt mit feuergetrocknetem Quarzsand. Frischen Spachtel vollflächig absanden mit feuergetrocknetem Quarzsand der Körnung 0,3-0,9 mm. Nicht eingebundenen Quarzsand nach Härtung entfernen. Verbrauch Bindemittel: ca. 0,7-0,8 kg/m²; Verbrauch Quarzsand: ca. 3,5-4,0 kg/m²."
                ),
                Unterleistung(
                    name: "Geprüfte Deckversiegelung - rutschhemmend",
                    description: "Auftrag eines lösemittelfreien, pigmentierten, niedrigviskosen 2-K-Systems auf Epoxid-Flüssigharzbasis auf den vorbehandelten Untergrund. Anschließend mit Walzen nachverschlichten um einen gleichmäßigen Auftrag zu gewährleisten. Verbrauch: ca. 0,8-0,9 kg/m²."
                ),
              ],
              units: ["m²", "PA"]
          ),

          Leistung(
              name: "COLORQUARZBELAG",
              description: "",
              unterleistungen: [
                Unterleistung(
                    name: "Untergrundvorbereitung durch Schleifen",
                    description: "Die zu beschichtenden Oberflächen müssen trocken, fest, griffig und frei von Staub, Fett und anderen haftungsstörenden Substanzen sein. Die Abreißfestigkeit des vorbereiteten Untergrundes muss 1,5 N/mm² betragen. Oberflächenrestfeuchtigkeit max. 4 %. Untergrundvorbereitung durch staubfreies Diamantschleifen."
                ),
                Unterleistung(
                    name: "Randfugenverschluss (wenn erforderlich)",
                    description: "Herstellen eines Randfugenverschluss zwischen Boden und Wand mittels PU-Dichtmasse."
                ),
                Unterleistung(
                    name: "Grundierspachtelung",
                    description: "Aufbringen einer Grundierspachtelung, bestehend aus einem lösemittelfreien, unpigmentierten, niedrigviskosen 2-Komponenten Grundierharz, gemischt mit feuergetrocknetem Quarzsand der Körnung 0,1 – 0,4 mm im Mischungsverhältnis 1 : 0,5, auf die vorbehandelte abgesaugte Bodenfläche. Anschließend vollflächiges absanden der frischen Grundierspachtelung mittels feuergetrocknetem Quarzsand der Körnung 0,3 – 0,8 mm. Verbrauch Bindemittel: 0,7 – 1,0 kg/m²."
                ),
                Unterleistung(
                    name: "Einstreuschicht EP",
                    description: "Vorbehandelten Untergrund nach Herstellervorschrift spachteln mit einem lösemittelfreien, unpigmentierten, niedrigviskosen 2-K-System auf Epoxid-Flüssigharzbasis gemischt mit feuergetrocknetem Quarzsand. Frischen Spachtel vollflächig absanden mit feuergetrocknetem, pigmentieren Quarzsand (Farbe nach Wahl Auftraggeber) der Körnung 0,3-0,9 mm. Nicht eingebundenen Quarzsand nach Härtung entfernen. Verbrauch Bindemittel: ca. 0,7-0,8 kg/m²; Verbrauch Quarzsand: ca. 3,5-4,0 kg/m²."
                ),
                Unterleistung(
                    name: "Deckversiegelung - rutschhemmend",
                    description: "Auftrag eines lösemittelfreien, unpigmentierten, niedrigviskosen 2-K-Systems auf Epoxid-Flüssigharzbasis auf den vorbehandelten Untergrund. Anschließend mit Walzen nachverschlichten um einen gleichmäßigen Auftrag zu gewährleisten. Verbrauch: ca. 0,8-0,9 kg/m²."
                ),
              ],
              units: ["m²", "PA"]
          ),

          Leistung(
              name: "Wochenendaufschlag",
              description: "Aufzahlung für Ausführung am Wochenende.",
              units: ["PA"]
          ),

          Leistung(
              name: "Kleinflächenzuschlag",
              description: "Mindermengenzuschlag für Baustellen unter 50 m².",
              units: ["PA"]
          ),
        ];
  }
}