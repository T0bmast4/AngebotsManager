import 'package:angebote_manager/ui/pages/angebot_create/angebot_create_page.dart';
import 'package:angebote_manager/ui/pages/angebot_overview/angebot_overview_page.dart';
import 'package:angebote_manager/ui/pages/leistungen_overview/leistungen_overview_page.dart';
import 'package:angebote_manager/ui/pages/leistungen_overview/leistungen_overview_provider.dart';
import 'package:angebote_manager/ui/pages/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EpoxNavbar extends StatefulWidget {
  final selectedIndex;
  const EpoxNavbar({super.key, required this.selectedIndex});

  @override
  State<EpoxNavbar> createState() => _EpoxNavbarState();
}

class _EpoxNavbarState extends State<EpoxNavbar> {
  int _selectedIndex = 0;

  final List<Widget> _pages = <Widget>[
    const AngebotOverviewPage(),
    const AngebotCreatePage(),
    const LeistungenOverviewPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body:  Row(
            children: <Widget>[
              NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                elevation: 30,
                labelType: NavigationRailLabelType.all,
                destinations: const <NavigationRailDestination>[
                  NavigationRailDestination(
                    icon: Icon(Icons.newspaper),
                    selectedIcon: Icon(Icons.newspaper_outlined),
                    label: Text('Angebote'),
                  ),
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
                    label: Text('Einstellungen'),
                  ),
                ],
              ),
              Expanded(
                child: Center(
                  child: _pages.elementAt(_selectedIndex),
                ),
              ),
            ],
          ),
          floatingActionButton: _selectedIndex == 0 ? FloatingActionButton.extended(
            onPressed: () {
              setState(() {
                _selectedIndex = 1;
              });
            },
            icon: const Icon(Icons.add),
            label: Text("Neues Angebot"),
            backgroundColor: Colors.grey[800],
          ) : _selectedIndex == 2 ? FloatingActionButton(
            onPressed: () {
              context.read<LeistungenOverviewProvider>().addEmptyLeistung();
            },
            child: Icon(Icons.add_box_outlined)
          ) : null,
        );
      },
    );
  }
}