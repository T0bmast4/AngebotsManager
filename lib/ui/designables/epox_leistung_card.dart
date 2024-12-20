import 'dart:ui';

import 'package:angebote_manager/models/leistung.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EpoxLeistungCard extends StatelessWidget {
  final int index;
  final double? elevation;
  final Leistung leistung;

  const EpoxLeistungCard({super.key, required this.index, this.elevation, required this.leistung});

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key("$index"),
      elevation: elevation ?? 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_indicator),
                ),
                Expanded(
                  child: Text(
                    "${index + 1}. ${leistung.name}",
                    style: Theme.of(context).textTheme.headlineSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit_note),
                  onPressed: () {
                    //TODO: Edit Menu for Leistung
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Bearbeiten geklickt: ${leistung.name}')),
                    );
                  },
                  tooltip: 'Bearbeiten',
                ),
              ],
            ),
            Padding(padding: EdgeInsets.only(top: 20)),
            Text(
              leistung.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}