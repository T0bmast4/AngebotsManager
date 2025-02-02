import 'dart:async';
import 'dart:ui';

import 'package:angebote_manager/database/leistungen_database.dart';
import 'package:angebote_manager/models/angebotsleistung.dart';
import 'package:angebote_manager/models/leistung.dart';
import 'package:angebote_manager/ui/designables/epox_leistung_card.dart';
import 'package:angebote_manager/ui/designables/epox_sure_dialog.dart';
import 'package:angebote_manager/ui/pages/leistungen_overview/leistungen_overview_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LeistungenOverviewPage extends StatefulWidget {
  const LeistungenOverviewPage({super.key});

  @override
  _LeistungenOverviewPageState createState() => _LeistungenOverviewPageState();
}

class _LeistungenOverviewPageState extends State<LeistungenOverviewPage> {

  late List<Leistung> leistungen;

  @override
  void initState() {
    super.initState();
    context.read<LeistungenOverviewProvider>().loadLeistungen();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LeistungenOverviewProvider>(
      builder: (context, provider, _) {
        return StreamBuilder<List<Leistung>>(
          stream: provider.leistungen,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('Keine Leistungen verfügbar'),
              );
            }

            leistungen = snapshot.data!;

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: ReorderableListView(
                scrollController: provider.scrollController,
                buildDefaultDragHandles: false,
                proxyDecorator: proxyDecorator,
                padding: const EdgeInsets.only(bottom: 16.0),
                onReorder: (int oldIndex, int newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final item = leistungen.removeAt(oldIndex);
                    leistungen.insert(newIndex, item);
                  });

                  updateLeistungOrder(leistungen);
                },
                children: [
                  for (int index = 0; index < leistungen.length; index++)
                    Dismissible(
                      key: Key(leistungen[index].id.toString()),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) {
                        return showDialog(
                            context: context,
                            builder: (context) {
                              return EpoxSureDialog(
                                isUnterleistung: false,
                                leistungId: leistungen[index].id,
                                onPressed: () async {
                                  await LeistungenDatabase.deleteLeistung(leistungen[index].id);
                                  context.read<LeistungenOverviewProvider>().reloadLeistungen();
                                  context.read<LeistungenOverviewProvider>().removeLeistung(index);
                                },
                              );
                            }
                        );
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                      ),
                      child: leistungen[index].name.isEmpty ?
                      EpoxLeistungCard(
                        key: Key("$index"),
                        index: index,
                        leistung: leistungen[index],
                        elevation: 5,
                        autoExpand: true,
                        ) :
                      EpoxLeistungCard(
                        key: Key("$index"),
                        index: index,
                        leistung: leistungen[index],
                        elevation: 5,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void updateLeistungOrder(List<Leistung> leistungen) async {
    try {
      for (int i = 0; i < leistungen.length; i++) {
        await LeistungenDatabase.updateLeistungOrder(leistungen[i].id, i);
      }
    } catch (e) {
      print("Error updating order in database: $e");
    }
  }

  Future<void> deleteLeistung(Leistung leistung) async {
    try {
      await LeistungenDatabase.deleteLeistung(leistung.id);
    } catch (e) {
      print("Error deleting Leistung: $e");
    }
  }



  Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double elevation = lerpDouble(5, 8, animValue)!;
        final double scale = lerpDouble(1, 1.02, animValue)!;
        return Transform.scale(
          scale: scale,
          child: EpoxLeistungCard(
            key: ValueKey(index),
            index: index,
            elevation: elevation,
            leistung: leistungen[index],
          ),
        );
      },
      child: child,
    );
  }

  void openSureDialog(bool isUnterleistung, int leistungId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Leistung löschen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              if (isUnterleistung)
                const Text("Sind Sie sicher, dass Sie die Unterleistung endgültig löschen möchten?")
              else
                const Text("Sind Sie sicher, dass Sie die Leistung inklusive der Unterleistungen endgültig löschen möchten?")
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () async {
                await LeistungenDatabase.deleteLeistung(leistungId);
                context.read<LeistungenOverviewProvider>().reloadLeistungen();
              },
              child: const Text('Endgültig Löschen'),
            ),
          ],
        );
      },
    );
  }
}