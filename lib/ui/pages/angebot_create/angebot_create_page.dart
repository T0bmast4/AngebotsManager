import 'package:angebote_manager/api/api_service.dart';
import 'package:angebote_manager/database/angebot_database.dart';
import 'package:angebote_manager/database/leistungen_database.dart';
import 'package:angebote_manager/models/angebot.dart';
import 'package:angebote_manager/ui/pages/angebot_create/angebot_create_provider.dart';
import 'package:angebote_manager/models/angebotsleistung.dart';
import 'package:angebote_manager/models/leistung.dart';
import 'package:blinking_text/blinking_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AngebotCreatePage extends StatefulWidget {
  final int? id;
  final Angebot? angebot;

  const AngebotCreatePage({super.key, this.id, this.angebot});

  @override
  _AngebotCreatePage createState() => _AngebotCreatePage();
}

class _AngebotCreatePage extends State<AngebotCreatePage> with SingleTickerProviderStateMixin {
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
  TextEditingController cityController = TextEditingController();
  TextEditingController projectController = TextEditingController();

  final anschriften = ["Damen und Herren", "Frau", "Herr", "Familie"];

  var selectedAnschrift = "Damen und Herren";

  Stream<List<Leistung>> leistungsStream = const Stream.empty();

  @override
  void initState() {
    super.initState();
    loadLeistungen();

    Angebot? angebot = widget.angebot;
    if(angebot != null) {
      nameController.text = angebot.name;
      if(angebot.zH != null) {
        zHController.text = angebot.zH!;
      }
      addressController.text = angebot.address;
      cityController.text = angebot.city;
      projectController.text = angebot.project;

      selectedLeistungen = angebot.leistungen;
      selectedAnschrift = angebot.anschrift;
    }
  }

  void search(String query) {
    _query = query;
    if (_query.isEmpty) {
      filteredItems = items;
    } else {
      filteredItems = items
          .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    setState(() {});
  }

  void _showError(String message) {
    setState(() {
      errorMessage = message;
    });

    print(message);
  }

  void loadLeistungen() async {
    try {
      List<Leistung> leistungen = await LeistungenDatabase.leistungen();
      setState(() {
        leistungsStream = Stream.value(leistungen);
      });
    } catch (e, stack) {
      print("Error loading Leistungen: $e, $stack");
    }
  }

  void updateProjectField() {
    String address = addressController.text;
    String city = cityController.text;

    String currentProjectText = projectController.text;
    List<String> projectLines = currentProjectText.split('\n');

    if (projectLines.length < 2) {
      projectLines = List.generate(2, (index) => index == 0 ? currentProjectText : '');
    }

    String firstLine = projectLines[0];

    String secondLine = '$address, $city'.trim();

    projectController.text = [firstLine, secondLine].join('\n');

    projectController.selection = TextSelection.fromPosition(
      TextPosition(offset: projectController.text.length),
    );
  }


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AngebotCreateProvider>(
      create: (_) => AngebotCreateProvider(),
      child: Consumer<AngebotCreateProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            child: Center(
              child: Container(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Angebot erstellen", style: TextStyle(fontSize: 25)),
                      ),
                      Padding(padding: EdgeInsets.only(top: 20)),

                      TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Name',
                          ),
                          validator: (value) =>
                          value?.isNotEmpty == true ? null : "Bitte gib einen Namen ein."),
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
                          dropdownMenuEntries: anschriften
                              .map<DropdownMenuEntry<String>>((String value) {
                            return DropdownMenuEntry<String>(
                                value: value, label: value);
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
                          }),
                      Padding(padding: EdgeInsets.only(top: 20)),

                      TextFormField(
                          controller: addressController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Adresse',
                          ),
                          onChanged: (text) {
                            updateProjectField();
                          },
                          validator: (value) => value?.isNotEmpty == true
                              ? null
                              : "Bitte gib eine Adresse ein."),
                      Padding(padding: EdgeInsets.only(top: 20)),

                      TextFormField(
                          controller: cityController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Stadt',
                          ),
                          onChanged: (text) {
                            updateProjectField();
                          },
                          validator: (value) =>
                          value?.isNotEmpty == true ? null : "Bitte gib eine Stadt ein."),
                      Padding(padding: EdgeInsets.only(top: 20)),

                      TextFormField(
                          controller: projectController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Projekt',
                          ),
                          keyboardType: TextInputType.multiline,
                          maxLines: 2,
                          onChanged: (text) {
                            int lineBreakCount = '\n'.allMatches(text).length;

                            if (lineBreakCount > 1) {
                              setState(() {
                                projectController.text = text.split('\n').take(2).join('\n');
                              });
                            }
                          },
                          validator: (value) =>
                          value?.isNotEmpty == true ? null : "Bitte gib ein Projekt ein."),
                      Padding(padding: EdgeInsets.only(top: 20)),

                      const Text("Leistungen", textScaler: TextScaler.linear(2)),
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: SearchBar(
                                hintText: "Suchen...",
                                onChanged: (value) {
                                  search(value);
                                },
                                leading: IconButton(
                                  icon: const Icon(Icons.search),
                                  onPressed: () {},
                                ),
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(right: 20)),
                            if (MediaQuery.of(context).size.width > 700) Padding(
                              padding: EdgeInsets.only(right: 20),
                              child: createButton(),
                            ),
                          ],
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 10)),

                      StreamBuilder<List<Leistung>>(
                        stream: leistungsStream,
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
                              child: Text("Keine Ergebnisse gefunden!",
                                  style: TextStyle(fontSize: 18)),
                            ),
                          )
                              : Container(
                            height: 500,
                            child: GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                MediaQuery.of(context).size.width ~/ 300,
                                crossAxisSpacing: 16.0,
                                mainAxisSpacing: 16.0,
                                childAspectRatio: 4,
                              ),
                              itemCount: displayItems.length,
                              itemBuilder: (context, index) {
                                final leistung = displayItems[index];
                                bool isSelected = selectedLeistungen.any((angebotsLeistung) => angebotsLeistung.leistung == leistung);

                                return Container(
                                  padding: EdgeInsets.all(8.0),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        if (!isSelected) {
                                          _showLeistungsForm(context, leistung);
                                        } else {
                                          setState(() {
                                            selectedLeistungen.removeWhere((angebotsLeistung) => angebotsLeistung.leistung == leistung);
                                          });
                                        }
                                      },
                                      child: Row(
                                        children: [
                                          Checkbox(
                                            value: isSelected,
                                            onChanged: (bool? value) {
                                              if (!isSelected) {
                                                _showLeistungsForm(context, leistung);
                                              } else {
                                                setState(() {
                                                  selectedLeistungen.removeWhere((angebotsLeistung) => angebotsLeistung.leistung == leistung);
                                                });
                                              }
                                            },
                                          ),
                                          Expanded(
                                            child: Text(
                                              leistung.name,
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ),
                                          if (selectedLeistungen.any((angebotsLeistung) => angebotsLeistung.leistung == leistung))
                                            IconButton(
                                              icon: Icon(Icons.edit),
                                              onPressed: () {
                                                final angebotsLeistung = selectedLeistungen.firstWhere((item) => item.leistung == leistung);
                                                _showLeistungEditForm(context, angebotsLeistung);
                                              },
                                            ),
                                        ],
                                      ),
                                    ),
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
                              "Fehler! Umgehend Software-Entwickler informieren",
                              style: TextStyle(
                                  fontSize: 24.0,
                                  color: Colors.red[900],
                                  fontWeight: FontWeight.bold),
                              beginColor: Colors.redAccent,
                              endColor: Colors.red[900],
                              duration: Duration(seconds: 1),
                              textAlign: TextAlign.center,
                            ),
                            BlinkText(
                              errorMessage!,
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.red[900]),
                              beginColor: Colors.grey[100],
                              endColor: Colors.red[900],
                              duration: Duration(seconds: 1),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      Padding(padding: EdgeInsets.only(top: 10)),
                      createButton(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget createButton() {
    String buttonText;
    if(widget.angebot != null) {
      buttonText = "Speichern";
    }else{
      buttonText = "Erstellen";
    }
    return FilledButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            setState(() {
              feedbackMessage = null;
            });
            try {
              var now = DateTime.now();
              var formatter = DateFormat('dd.MM.yyyy');
              String formattedDate = formatter.format(now);

              Angebot currentAngebot = Angebot(
                name: nameController.text,
                zH: zHController.text.isNotEmpty
                    ? zHController.text
                    : null,
                address: addressController.text,
                city: cityController.text,
                leistungen: selectedLeistungen.reversed.toList(),
                project: projectController.text,
                anschrift: selectedAnschrift,
                date: formattedDate,
              );

              if(widget.angebot != null) {
                await AngebotDatabase.updateAngebot(currentAngebot, widget.id!);
                Navigator.pop(context, true);
              }else{
                await AngebotDatabase.createAngebot(currentAngebot);
              }

              await currentAngebot.createDocument();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Dokument erfolgreich erstellt!")),
              );
              setState(() {
                errorMessage = null;
              });
            } catch (e, stack) {
              _showError(
                  "Ein unbekannter Fehler ist aufgetreten: $e, $stack");
            }
          } else {
            setState(() {
              feedbackMessage = "Das Formular ist nicht valide!";
            });
          }
        },
        child: Text(buttonText));
  }

  Future<void> _showLeistungsForm(BuildContext context, Leistung leistung) async {
    final _formKey2 = GlobalKey<FormState>();
    TextEditingController singlePriceController = TextEditingController();
    TextEditingController amountController = TextEditingController();
    TextEditingController daysController = TextEditingController();
    final FocusNode daysFocusNode = FocusNode();

    String selectedUnit = leistung.units.first;

    bool isLoading = false;

    if (leistung.fixCost != null) {
      if (leistung.fixCost != 0) {
        singlePriceController.text = leistung.fixCost!.toStringAsFixed(2);
      }
    }

    if (leistung.id == 1) {
      amountController.text = "1";
    }

    await showModalBottomSheet(
      context: context,
      elevation: 10,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, bottomSheetSetState) {
            final FocusNode daysFocusNode = FocusNode();

            if(projectController.text.isNotEmpty) {
              daysFocusNode.addListener(() async {
                if (!daysFocusNode.hasFocus) {
                  String value = daysController.text;

                    if (value.isNotEmpty) {
                      bottomSheetSetState(() {
                        isLoading = true;
                      });


                      final double bgk = await ApiService().getBGK(int.parse(daysController.text), projectController.text.split("\n")[1]);
                      singlePriceController.text = bgk.toStringAsFixed(2);

                      bottomSheetSetState(() {
                        isLoading = false;
                      });
                    }
                  }
                }
              );
            }

            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
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
                      const Padding(padding: EdgeInsets.only(top: 20)),
                      if (leistung.id == 1) ...[
                        TextFormField(
                          focusNode: daysFocusNode,
                          controller: daysController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Tage',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Bitte gib Tage ein.";
                            }
                            value = value.replaceAll(',', '.');
                            final parsedValue = double.tryParse(value);
                            if (parsedValue == null) {
                              return "Bitte gib eine gültige Zahl ein.";
                            }

                            return null;
                          },
                        ),
                        const Padding(padding: EdgeInsets.only(top: 20)),
                      ],
                      Align(
                        alignment: Alignment.centerLeft,
                        child: DropdownMenu<String>(
                          initialSelection: leistung.units.first,
                          onSelected: (String? value) {
                            bottomSheetSetState(() {
                              selectedUnit = value!;
                            });
                          },
                          dropdownMenuEntries: leistung.units
                              .map<DropdownMenuEntry<String>>((String value) {
                            return DropdownMenuEntry<String>(
                                value: value, label: value);
                          }).toList(),
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 20)),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
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
                          ),
                          if (isLoading) ...[
                            const SizedBox(width: 10),
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          ],
                        ],
                      ),
                      Padding(padding: EdgeInsets.only(top: 50)),
                      FilledButton(
                        onPressed: () {
                          if (_formKey2.currentState!.validate()) {
                            Navigator.pop(context);
                            setState(() {
                              if(daysController.text.isNotEmpty) {
                                selectedLeistungen.add(
                                  AngebotsLeistung(
                                    leistung: leistung,
                                    singlePrice: double.parse(singlePriceController.text.replaceAll(",", ".")),
                                    amount: double.parse(amountController.text.replaceAll(",", ".")),
                                    unit: selectedUnit,
                                    days: int.parse(daysController.text),
                                  ),
                                );
                              }else{
                                selectedLeistungen.add(
                                  AngebotsLeistung(
                                    leistung: leistung,
                                    singlePrice: double.parse(singlePriceController.text.replaceAll(",", ".")),
                                    amount: double.parse(amountController.text.replaceAll(",", ".")),
                                    unit: selectedUnit,
                                  ),
                                );
                              }
                            });
                          }
                        },
                        child: Text("Speichern"),
                      ),
                      Padding(padding: EdgeInsets.only(bottom: 20)),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    daysFocusNode.dispose();
  }

  Future<void> _showLeistungEditForm(BuildContext context, AngebotsLeistung angebotsLeistung) async {
    final _formKey2 = GlobalKey<FormState>();
    TextEditingController singlePriceController = TextEditingController();
    TextEditingController amountController = TextEditingController();
    TextEditingController daysController = TextEditingController();
    final FocusNode daysFocusNode = FocusNode();

    String selectedUnit = angebotsLeistung.unit;
    singlePriceController.text = angebotsLeistung.singlePriceString;
    amountController.text = angebotsLeistung.amountString;
    if(angebotsLeistung.leistung.id == 1) {
      daysController.text = angebotsLeistung.days!.toString();
    }

    bool isLoading = false;

    await showModalBottomSheet(
      context: context,
      elevation: 10,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, bottomSheetSetState) {
            final FocusNode daysFocusNode = FocusNode();

            if(projectController.text.isNotEmpty) {
              daysFocusNode.addListener(() async {
                if (!daysFocusNode.hasFocus) {
                  String value = daysController.text;

                  if (value.isNotEmpty) {
                    bottomSheetSetState(() {
                      isLoading = true;
                    });


                    final double bgk = await ApiService().getBGK(int.parse(daysController.text), projectController.text.split("\n")[1]);
                    singlePriceController.text = bgk.toStringAsFixed(2);

                    bottomSheetSetState(() {
                      isLoading = false;
                    });
                  }
                }
              }
              );
            }

            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
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
                      const Padding(padding: EdgeInsets.only(top: 20)),
                      if (angebotsLeistung.leistung.id == 1) ...[
                        TextFormField(
                          focusNode: daysFocusNode,
                          controller: daysController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Tage',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Bitte gib Tage ein.";
                            }
                            value = value.replaceAll(',', '.');
                            final parsedValue = double.tryParse(value);
                            if (parsedValue == null) {
                              return "Bitte gib eine gültige Zahl ein.";
                            }

                            return null;
                          },
                        ),
                        const Padding(padding: EdgeInsets.only(top: 20)),
                      ],
                      Align(
                        alignment: Alignment.centerLeft,
                        child: DropdownMenu<String>(
                          initialSelection: angebotsLeistung.unit,
                          onSelected: (String? value) {
                            bottomSheetSetState(() {
                              selectedUnit = value!;
                            });
                          },
                          dropdownMenuEntries: angebotsLeistung.leistung.units
                              .map<DropdownMenuEntry<String>>((String value) {
                            return DropdownMenuEntry<String>(
                                value: value, label: value);
                          }).toList(),
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 20)),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
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
                          ),
                          if (isLoading) ...[
                            const SizedBox(width: 10),
                            const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          ],
                        ],
                      ),
                      Padding(padding: EdgeInsets.only(top: 50)),
                      FilledButton(
                        onPressed: () {
                          if (_formKey2.currentState!.validate()) {
                            Navigator.pop(context);
                            setState(() {
                              selectedLeistungen.remove(angebotsLeistung);
                              if(daysController.text.isNotEmpty) {
                                selectedLeistungen.add(
                                  AngebotsLeistung(
                                    leistung: angebotsLeistung.leistung,
                                    singlePrice: double.parse(singlePriceController.text.replaceAll(",", ".")),
                                    amount: double.parse(amountController.text.replaceAll(",", ".")),
                                    unit: selectedUnit,
                                    days: int.parse(daysController.text),
                                  ),
                                );
                              }else{
                                selectedLeistungen.add(
                                  AngebotsLeistung(
                                    leistung: angebotsLeistung.leistung,
                                    singlePrice: double.parse(singlePriceController.text.replaceAll(",", ".")),
                                    amount: double.parse(amountController.text.replaceAll(",", ".")),
                                    unit: selectedUnit,
                                  ),
                                );
                              }

                            });
                          }
                        },
                        child: Text("Speichern"),
                      ),
                      Padding(padding: EdgeInsets.only(bottom: 20)),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    daysFocusNode.dispose();
  }
}
