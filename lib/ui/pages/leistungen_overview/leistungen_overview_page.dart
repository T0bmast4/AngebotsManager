import 'dart:ui';

import 'package:angebote_manager/database/leistungen_database.dart';
import 'package:angebote_manager/models/leistung.dart';
import 'package:angebote_manager/ui/designables/epox_leistung_card.dart';
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

  List<Leistung> leistungen = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadLeistungen();
  }


  void loadLeistungen() async {
    try {
      List<Leistung> data = await LeistungenDatabase.leistungen();
      setState(() {
        leistungen = data;
        isLoading = false;
      });
    } catch (e, stack) {
      print("Error loading Leistungen: $e, $stack");
      setState(() {
        isLoading = false;
      });
    }
  }


  void updateLeistungOrder(List<Leistung> leistungen) async {
    try {
      for (int i = 0; i < leistungen.length; i++) {
        if(leistungen[i].id != null) {
          await LeistungenDatabase.updateOrderIndex(leistungen[i].id!, i);
        } else {
          print("Error updating order in database: leistung.id is null!");
        }
      }
    } catch (e) {
      print("Error updating order in database: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LeistungenOverviewProvider>(
      create: (_) => LeistungenOverviewProvider(),
      child: Consumer<LeistungenOverviewProvider>(
        builder: (context, provider, _) {
          return isLoading
              ? Center(
                child: CircularProgressIndicator(),
              )
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: ReorderableListView(
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
                    EpoxLeistungCard(
                      key: Key("$index"),
                      index: index,
                      leistung: leistungen[index],
                      elevation: 5,
                    ),
                ],
              ),
          );
        }
      ),
    );
  }


  Widget proxyDecorator(
      Widget child, int index, Animation<double> animation) {
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
}

