import 'package:angebote_manager/database/angebot_database.dart';
import 'package:angebote_manager/models/angebot.dart';
import 'package:angebote_manager/ui/designables/epox_angebot_card.dart';
import 'package:angebote_manager/ui/designables/epox_navbar.dart';
import 'package:angebote_manager/ui/pages/angebot_create/angebot_create_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AngebotOverviewPage extends StatefulWidget {
  const AngebotOverviewPage({super.key});

  @override
  _AngebotOverviewPageState createState() => _AngebotOverviewPageState();
}

class _AngebotOverviewPageState extends State<AngebotOverviewPage> {
  List<Angebot> angeboteList = [];

  @override
  void initState() {
    loadAngebote();
    super.initState();
  }

  void loadAngebote() async {
    try {
      List<Angebot> angebote = await AngebotDatabase.angebote();
      setState(() {
        angeboteList = angebote;
      });
    } catch (e, stack) {
      print("Error loading Angebote: $e, $stack");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: ListView(
        children: angeboteList.asMap().map((index, angebot) {
          return MapEntry(
            index,
            EpoxAngebotCard(
              title: "${angebot.name} | (${angebot.project.split("\n").first})",
              subtitle: "${angebot.address} | ${angebot.city}",
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(foregroundColor: Colors.white, backgroundColor: Colors.grey[800], title: const Text('Angebot bearbeiten')),
                      body: AngebotCreatePage(angebot: angebot, id: index+1),
                    ),
                  ),
                );

                if (result != null) {
                  loadAngebote();
                }
              },
              trailing: angebot.date,
            ),
          );
        }).values.toList(),
      ),
    );
  }
}