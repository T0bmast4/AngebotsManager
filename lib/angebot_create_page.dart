import 'dart:convert';
import 'dart:io';

import 'package:angebote_manager/angebot.dart';
import 'package:angebote_manager/angebot_create_provider.dart';
import 'package:angebote_manager/angebotsleistung.dart';
import 'package:angebote_manager/leistung.dart';
import 'package:archive/archive.dart';
import 'package:blinking_text/blinking_text.dart';
import 'package:docx_template/docx_template.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:xml/xml.dart';

class AngebotCreatePage extends StatefulWidget{
  @override
  _AngebotCreatePage createState() => _AngebotCreatePage();
}

class _AngebotCreatePage extends State<AngebotCreatePage> with SingleTickerProviderStateMixin{
  final _formKey = GlobalKey<FormState>();
  List<Leistung> items = [];
  List<Leistung> filteredItems = [];
  String _query = '';
  List<AngebotsLeistung> selectedLeistungen = [];

  String? errorMessage;
  String? feedbackMessage;

  TextEditingController nameController = TextEditingController();
  TextEditingController zHController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController plzController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController projectController = TextEditingController();

  final anschriften = ["Damen und Herren", "Frau", "Herr"];

  var selectedAnschrift = "Damen und Herren";

  void search(String query) {
    _query = query;
    if (_query.isEmpty) {
      filteredItems = items;
    } else {
      filteredItems = items.where((item) => item.name.toLowerCase().contains(query.toLowerCase())).toList();
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showError(String message) {
    setState(() {
      errorMessage = message;
    });

    print(message);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AngebotCreateProvider>(
      create: (_) => AngebotCreateProvider(),
      child: Scaffold(
        appBar: AppBar(title: Text("Angebot erstellen")),
        body: Consumer<AngebotCreateProvider>(
          builder: (context, provider, _) {
            return SingleChildScrollView(
              child: Center(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Formularfelder
                          TextFormField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Name',
                              ),
                              validator: (value) => value?.isNotEmpty == true ? null : "Bitte gib einen Namen ein."
                          ),
                          Padding(padding: EdgeInsets.only(top: 20)),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: DropdownMenu<String>(
                              initialSelection: anschriften.first,
                              onSelected: (String? value) {
                                setState(() {
                                  selectedAnschrift = value!;
                                });
                              },
                              dropdownMenuEntries: anschriften.map<DropdownMenuEntry<String>>((String value) {
                                return DropdownMenuEntry<String>(value: value, label: value);
                              }).toList(),
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(top: 20)),

                          TextFormField(
                              controller: zHController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'zH',
                              ),
                              validator: (value) {
                                return null;
                              }
                          ),
                          Padding(padding: EdgeInsets.only(top: 20)),

                          TextFormField(
                              controller: addressController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Adresse',
                              ),
                              validator: (value) => value?.isNotEmpty == true ? null : "Bitte gib eine Adresse ein."
                          ),
                          Padding(padding: EdgeInsets.only(top: 20)),

                          TextFormField(
                              controller: cityController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Stadt',
                              ),
                              validator: (value) => value?.isNotEmpty == true ? null : "Bitte gib eine Stadt ein."
                          ),
                          Padding(padding: EdgeInsets.only(top: 20)),

                          TextFormField(
                              controller: projectController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Projekt',
                              ),
                              validator: (value) => value?.isNotEmpty == true ? null : "Bitte gib ein Projekt ein."
                          ),
                          Padding(padding: EdgeInsets.only(top: 20)),

                          const Text("Leistungen", textScaler: TextScaler.linear(2)),
                          Padding(padding: EdgeInsets.only(top: 20)),
                          SearchBar(
                            hintText: "Suchen...",
                            onChanged: (value) {
                              search(value);
                            },
                            leading: IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                            trailing: [IconButton(icon: const Icon(Icons.mic), onPressed: () {})],
                          ),
                          Padding(padding: EdgeInsets.only(top: 10)),
                          StreamBuilder<List<Leistung>>(
                            stream: provider.leistungen,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return CircularProgressIndicator();
                              }

                              items = snapshot.data!;

                              final displayItems = _query.isNotEmpty ? filteredItems : items;
                              return displayItems.isEmpty
                                  ? Container(
                                height: 500,
                                child: const Center(
                                  child: Text("Keine Ergebnisse gefunden!", style: TextStyle(fontSize: 18)),
                                ),
                              )
                                  : Container(
                                height: 500,
                                child: GridView.builder(
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: MediaQuery.of(context).size.width ~/ 300,
                                    crossAxisSpacing: 16.0,
                                    mainAxisSpacing: 16.0,
                                    childAspectRatio: 4,
                                  ),
                                  itemCount: displayItems.length,
                                  itemBuilder: (context, index) {
                                    final leistung = displayItems[index];

                                    return Container(
                                      padding: EdgeInsets.all(8.0),
                                      child: CheckboxListTile(
                                        controlAffinity: ListTileControlAffinity.leading,
                                        title: Text(
                                          leistung.name,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        value: selectedLeistungen.any((angebotsLeistung) => angebotsLeistung.leistung == leistung),
                                        onChanged: (bool? value) async {
                                          if (!selectedLeistungen.any((angebotsLeistung) => angebotsLeistung.leistung == leistung)) {
                                            _showLeistungsForm(context, leistung);
                                          } else {
                                            setState(() {
                                              selectedLeistungen.removeWhere((angebotsLeistung) => angebotsLeistung.leistung == leistung);
                                            });
                                          }
                                        },
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          if (feedbackMessage != null)
                            Text(
                              feedbackMessage!,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          if (errorMessage != null)
                                Column(
                                  children: [
                                    BlinkText(
                                      "Alarm! Umgehend Software-Entwickler informieren",
                                      style: TextStyle(fontSize: 24.0, color: Colors.red[900], fontWeight: FontWeight.bold),
                                      beginColor: Colors.redAccent,
                                      endColor: Colors.red[900],
                                      duration: Duration(seconds: 1),
                                      textAlign: TextAlign.center,
                                    ),
                                    BlinkText(
                                        errorMessage!,
                                        style: TextStyle(fontSize: 18.0, color: Colors.red[900]),
                                        beginColor: Colors.grey[100],
                                        endColor: Colors.red[900],
                                        duration: Duration(seconds: 1),
                                        textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                          Padding(padding: EdgeInsets.only(top: 10)),
                          FilledButton(onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                feedbackMessage = null;
                              });
                              try {
                                await Angebot(
                                  name: nameController.text,
                                  zH: zHController.text.isNotEmpty ? zHController.text : null,
                                  address: addressController.text,
                                  city: cityController.text,
                                  leistungen: selectedLeistungen.reversed.toList(),
                                  project: projectController.text,
                                  anschrift: selectedAnschrift,
                                ).createDocument();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Dokument erfolgreich erstellt!")),
                                );
                                setState(() {
                                  errorMessage = null;
                                });
                              } catch (e, stack) {
                                _showError("Ein unbekannter Fehler ist aufgetreten: $e, $stack");
                              }
                            }else{
                              setState(() {
                                feedbackMessage = "Das Formular ist nicht valide!";
                              });
                            }
                          }, child: const Text("Erstellen")),
                        ],
                      ),
                    ),
                  )
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showLeistungsForm(BuildContext context, Leistung leistung) async {
    final _formKey2 = GlobalKey<FormState>();
    TextEditingController singlePriceController = TextEditingController();
    TextEditingController amountController = TextEditingController();

    String selectedUnit = leistung.units.first;

    await showModalBottomSheet(
      context: context,
      elevation: 10,
      builder: (context) {
        return Padding(
          padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Form(
            key: _formKey2,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(padding: EdgeInsets.only(top: 20)),

                  TextFormField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Anzahl',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Bitte gib eine Anzahl ein.";
                    }

                    value = value.replaceAll(',', '.');
                    final parsedValue = double.tryParse(value);
                    if (parsedValue == null) {
                      return "Bitte gib eine gültige Zahl ein.";
                    }

                    return null;
                  },
                ),

                  Padding(padding: EdgeInsets.only(top: 20)),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: DropdownMenu<String>(
                      initialSelection: leistung.units.first,
                      onSelected: (String? value) {
                        setState(() {
                          selectedUnit = value!;
                        });
                      },
                      dropdownMenuEntries: leistung.units.map<DropdownMenuEntry<String>>((String value) {
                        return DropdownMenuEntry<String>(value: value, label: value);
                      }).toList(),
                    ),
                  ),

                  Padding(padding: EdgeInsets.only(top: 20)),

                  TextFormField(
                    controller: singlePriceController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Einzelpreis',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Bitte gib einen Einzelpreis ein.";
                      }
                      value = value.replaceAll(',', '.');
                      final parsedValue = double.tryParse(value);
                      if (parsedValue == null) {
                        return "Bitte gib eine gültige Zahl ein.";
                      }

                      return null;
                    },
                  ),

                  Padding(padding: EdgeInsets.only(top: 50)),

                  FilledButton(
                    onPressed: () {
                      if (_formKey2.currentState!.validate()) {
                        setState(() {
                          selectedLeistungen.add(
                            AngebotsLeistung(
                              leistung: leistung,
                              singlePrice: double.parse(singlePriceController.text.replaceAll(",", ".")),
                              amount: double.parse(amountController.text.replaceAll(",", ".")),
                              unit: selectedUnit,
                            ),
                          );
                        });

                        Navigator.pop(context);
                      }
                    },
                    child: Text('Speichern'),
                  ),
                  Padding(padding: EdgeInsets.only(bottom: 20)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
