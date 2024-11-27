import 'dart:convert';
import 'dart:io';

import 'package:angebote_manager/angebot.dart';
import 'package:angebote_manager/angebot_create_provider.dart';
import 'package:angebote_manager/leistung.dart';
import 'package:archive/archive.dart';
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

class _AngebotCreatePage extends State<AngebotCreatePage> {
  final _formKey = GlobalKey<FormState>();
  Set<Leistung> selectedLeistungen = Set<Leistung>();

  TextEditingController nameController = TextEditingController();
  TextEditingController zHController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController plzController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController projectController = TextEditingController();

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
                          TextFormField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Name',
                              ),
                              validator: (value) => value?.isNotEmpty == true ? null : "Bitte gib einen Namen ein."
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
                              controller: plzController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'PLZ',
                              ),
                              validator: (value) => value?.isNotEmpty == true ? null : "Bitte gib eine PLZ ein."
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

                          StreamBuilder<List<Leistung>>(
                            stream: provider.leistungen,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return CircularProgressIndicator();
                              }

                              final leistungen = snapshot.data!;
                              return Container(
                                height: 500,
                                child: ListView.builder(
                                  itemCount: leistungen.length,
                                  itemBuilder: (context, index) {
                                    final leistung = leistungen[index];
                                    return CheckboxListTile(
                                      title: Text(leistung.name),
                                      subtitle: Text(leistung.description),
                                      value: selectedLeistungen.contains(leistung),  // Verwendet das Set
                                      onChanged: (bool? value) {
                                        setState(() {
                                          if (value == true) {
                                            selectedLeistungen.add(leistung);  // Hinzufügen zur Auswahl
                                          } else {
                                            selectedLeistungen.remove(leistung);  // Entfernen aus der Auswahl
                                          }
                                        });
                                        print(selectedLeistungen);
                                      },
                                    );
                                  },
                                ),
                              );

                            },
                          ),
                          FilledButton(onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              if(zHController.text.isNotEmpty) {
                                Angebot(
                                    name: nameController.text,
                                    zH: zHController.text,
                                    address: addressController.text,
                                    plz: plzController.text,
                                    city: cityController.text,
                                    leistungen: selectedLeistungen,
                                    project: projectController.text
                                ).createDocument();
                              }else{
                                Angebot(
                                    name: nameController.text,
                                    zH: null,
                                    address: addressController.text,
                                    plz: plzController.text,
                                    city: cityController.text,
                                    leistungen: selectedLeistungen,
                                    project: projectController.text
                                ).createDocument();
                              }

                            }
                          }, child: Text("Erstellen")),
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
}