import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EpoxAngebotCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trailing;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const EpoxAngebotCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.trailing,
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
        leading: const Icon(Icons.newspaper, size: 30),
        trailing: Text(trailing, style: TextStyle(fontSize: 20, color: Colors.grey)),
        contentPadding: EdgeInsets.fromLTRB(20, 12.0, 20, 12.0),
      ),
    );
  }
}