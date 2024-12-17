import 'package:angebote_manager/ui/pages/angebot_create/angebot_create_page.dart';
import 'package:flutter/material.dart';

class EpoxNavbar extends StatefulWidget {
  const EpoxNavbar({super.key});

  @override
  State<EpoxNavbar> createState() => _EpoxNavbarState();
}

class _EpoxNavbarState extends State<EpoxNavbar> {
  int _selectedIndex = 0;

  List<Widget> _pages = <Widget>[
    //AngebotOverviewPage(),
    AngebotCreatePage(),
    Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Leistungen"),
          Icon(Icons.mark_email_unread_rounded),
        ],
      ),
    ),
    Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Settings"),
          Icon(Icons.settings),
        ],
      ),
    ),

  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[

        // create a navigation rail
        NavigationRail(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          elevation: 30,
          labelType: NavigationRailLabelType.all,
          destinations: const <NavigationRailDestination>
          [
            // navigation destinations
            NavigationRailDestination(
              icon: Icon(Icons.euro),
              selectedIcon: Icon(Icons.euro),
              label: Text('Erstellen'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.work_outline),
              selectedIcon: Icon(Icons.work),
              label: Text('Leistungen'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.settings_sharp),
              selectedIcon: Icon(Icons.settings_sharp),
              label: Text('Settings'),
            ),
          ],
        ),
        Expanded(
          child: Center(
            child: _pages.elementAt(_selectedIndex),
          ),
        )
      ],
    );
  }
}