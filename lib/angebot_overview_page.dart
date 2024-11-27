/*import 'package:discord_bot_manager/edit_bot.dart';

import 'db.dart';
import 'bot.dart';
import 'botmanager.dart';
import 'package:flutter/material.dart';

class BotOverviewPage extends StatefulWidget {
  const BotOverviewPage({Key? key}) : super(key: key);

  @override
  _BotOverviewWidget createState() => _BotOverviewWidget();
}

class _BotOverviewWidget extends State<BotOverviewPage> {
  BotManager botManager = BotManager();
  List<Angebot> angebotList = [];

  @override
  void initState() {
    super.initState();
  }

  //ACTUAL BOT OVERVIEW
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Angebot Übersicht"),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: ListWheelScrollView(
          itemExtent: 100,
          diameterRatio: 10,
          physics: BouncingScrollPhysics(),
          children: botList
              .map((bot) =>
              CustomCard(
                title: angebot.name,
                subtitle: angebot.description,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditPage(
                            botId: angebot.id as int,
                            botName: angebot.name,
                            botDescription: angebot.description,
                            botToken: angebot.token,
                          ),
                    ),
                  );
                },
                onLongPress: () {

                },
              ))
              .toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {

        },
        label: Text("Neues Angebot"),
        icon: Icon(Icons.add),
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const CustomCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: onTap,
        onLongPress: onLongPress,
        leading: const Icon(Icons.person, size: 30),
        trailing: const Icon(Icons.arrow_forward_ios),
        contentPadding: EdgeInsets.fromLTRB(20, 12.0, 20, 12.0),
      ),
    );
  }
}
*/