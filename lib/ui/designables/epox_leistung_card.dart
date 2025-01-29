import 'package:angebote_manager/database/leistungen_database.dart';
import 'package:angebote_manager/models/leistung.dart';
import 'package:angebote_manager/models/unterleistung.dart';
import 'package:angebote_manager/ui/designables/epox_sure_dialog.dart';
import 'package:angebote_manager/ui/pages/leistungen_overview/leistungen_overview_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EpoxLeistungCard extends StatefulWidget {
  final int index;
  final double? elevation;
  final Leistung leistung;

  const EpoxLeistungCard({
    super.key,
    required this.index,
    this.elevation,
    required this.leistung,
  });

  @override
  _EpoxLeistungCardState createState() => _EpoxLeistungCardState();
}

class _EpoxLeistungCardState extends State<EpoxLeistungCard>
    with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  bool isExpanded = false;


  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.leistung.name);
    _descriptionController = TextEditingController(text: widget.leistung.description);
  }

  void updateUnterleistungOrder(List<Unterleistung> unterleistungen) async {
    try {
      for (int i = 0; i < unterleistungen.length; i++) {
        await LeistungenDatabase.updateUnterleistungOrder(
            unterleistungen[i].id, i);
      }
    } catch (e) {
      print("Error updating order in database: $e");
    }
  }

  Future<void> updateSinglePrice(Leistung leistung, double singlePrice) async {
    try {
      await LeistungenDatabase.updateLeistungSinglePrice(leistung.id, singlePrice);
    } catch (e) {
      print("Error updating singlePrice in database: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: isExpanded ? expandedCard() : collapsedCard(),
    );
  }

  Widget collapsedCard() {
    return Card(
      key: Key("${widget.index}"),
      elevation: widget.elevation ?? 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ReorderableDragStartListener(
                  index: widget.index,
                  child: const Icon(Icons.drag_indicator),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${widget.index + 1}. ${widget.leistung.name}",
                        style: Theme.of(context).textTheme.headlineSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.leistung.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(isExpanded ? Icons.expand_less : Icons.edit_note),
                  onPressed: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                  tooltip: 'Bearbeiten',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget expandedCard() {
    final _formKey = GlobalKey<FormState>();
    return Card(
      key: Key("${widget.index}"),
      elevation: widget.elevation ?? 5,
      child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ReorderableDragStartListener(
                      index: widget.index,
                      child: const Icon(Icons.drag_indicator),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${widget.index + 1}. ${widget.leistung.name}",
                            style: Theme.of(context).textTheme.headlineSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.leistung.description,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(isExpanded ? Icons.expand_less : Icons.edit_note),
                          onPressed: () {
                            setState(() {
                              isExpanded = !isExpanded;
                            });
                          },
                          tooltip: 'Bearbeiten',
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: const Text("Löschen"),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return EpoxSureDialog(
                                      isUnterleistung: false,
                                      leistungId: widget.leistung.id,
                                      onPressed: () async {
                                        await LeistungenDatabase.deleteLeistung(widget.leistung.id);
                                        context.read<LeistungenOverviewProvider>().reloadLeistungen();
                                        setState(() {
                                          isExpanded = false;
                                        });
                                      }
                                  );
                                }
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    controller: _nameController,
                    validator: (value) =>
                    value?.isNotEmpty == true
                        ? null
                        : "Bitte gib einen Namen ein."
                ),

                const SizedBox(height: 16),

                TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                    labelText: 'Beschreibung',
                    border: OutlineInputBorder(),
                  ),
                  controller: _descriptionController,
                ),

                const SizedBox(height: 16),

                FilledButton(
                  onPressed: () {
                    showSinglePriceForm(context, widget.leistung);
                  },
                  child: const Text('Fixe Kosten'),
                ),

                const SizedBox(height: 16),

                if (widget.leistung.unterleistungen != null && widget.leistung.unterleistungen!.isNotEmpty)
                  ReorderableListView(
                    shrinkWrap: true,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) {
                          newIndex -= 1;
                        }

                        final item = widget.leistung.unterleistungen!.removeAt(oldIndex);
                        widget.leistung.unterleistungen!.insert(newIndex, item);

                        updateUnterleistungOrder(widget.leistung.unterleistungen!);
                      });
                    },
                    children: [
                      for (int i = 0; i < widget.leistung.unterleistungen!.length; i++)
                        ListTile(
                          key: Key("$i"),
                          title: Text(widget.leistung.unterleistungen![i].name),
                          subtitle: Text(widget.leistung.unterleistungen![i].description ?? ""),
                          onTap: () {
                            editUnterleistungDialog(i);
                          },
                        ),
                    ],
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    FilledButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await LeistungenDatabase.updateLeistung(widget.leistung.id, _nameController.text, _descriptionController.text);
                          context.read<LeistungenOverviewProvider>().reloadLeistungen();
                          setState(() {
                            isExpanded = false;
                          });
                        }
                      },
                      child: const Text('Speichern'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          isExpanded = false;
                        });
                      },
                      child: const Text('Abbrechen'),
                    ),
                  ],
                ),
              ],
            ),
          )
      ),
    );
  }

  Future<void> showSinglePriceForm(BuildContext context, Leistung leistung) async {
    final _formKey2 = GlobalKey<FormState>();
    TextEditingController singlePriceController = TextEditingController();

    if(leistung.fixCost != null) {
      if(leistung.fixCost != 0) {
        singlePriceController.text = leistung.fixCost!.toStringAsFixed(2);
      }
    }

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
                    controller: singlePriceController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Einzelpreis',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return null;
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
                      if(_formKey2.currentState!.validate()) {
                        var value = singlePriceController.text.replaceAll(',', '.');
                        if(value.isNotEmpty) {
                          updateSinglePrice(leistung, double.parse(value));
                        }else{
                          updateSinglePrice(leistung, 0);
                        }
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

  void editUnterleistungDialog(int index) {
    final _formKey = GlobalKey<FormState>();
    final unterleistung = widget.leistung.unterleistungen![index];
    TextEditingController nameController = TextEditingController(text: unterleistung.name);
    TextEditingController descriptionController = TextEditingController(text: unterleistung.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Unterleistung bearbeiten'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                    value?.isNotEmpty == true
                        ? null
                        : "Bitte gib einen Namen ein."
                ),

                const SizedBox(height: 8),

                TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                    labelText: 'Beschreibung',
                    border: OutlineInputBorder(),
                  ),
                  controller: descriptionController,
                ),
              ],
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await LeistungenDatabase.updateUnterleistung(unterleistung.id, nameController.text, descriptionController.text);
                  Navigator.of(context).pop();
                  context.read<LeistungenOverviewProvider>().reloadLeistungen();
                }
              },
              child: const Text('Speichern'),
            ),
          ],
        );
      },
    );
  }
}
