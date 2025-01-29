import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EpoxSureDialog extends StatelessWidget {
  final bool isUnterleistung;
  final int leistungId;
  final Function onPressed;

  const EpoxSureDialog({super.key, required this.isUnterleistung, required this.leistungId, required this.onPressed});

  @override
  Widget build(BuildContext context) {
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
            Navigator.of(context).pop(false);
          },
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () {
            onPressed();
            Navigator.of(context).pop(true);
          },
          child: const Text('Endgültig Löschen'),
        ),
      ],
    );
  }
}