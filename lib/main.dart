import 'package:angebote_manager/angebot_create_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Epox Angebote',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: Colors.grey[800]!,
          onPrimary: Colors.white,
          secondary: Colors.grey[600]!,
          onSecondary: Colors.white,
          surface: Colors.grey[100]!,
          onSurface: Colors.black,
          error: Colors.red[300]!,
          onError: Colors.grey[800]!,
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  List<Widget> _pages = <Widget>[
    //AngebotOverviewPage(),
    AngebotCreatePage(),
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[800],
          title: Text(style: TextStyle(color: Colors.white), "Epox"),
          elevation: 20,
          centerTitle: true,
        ),
        bottomNavigationBar: Container(
          child: BottomNavigationBar(
            elevation: 50,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "Angebote",
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings), label: "Settings")
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.blueAccent,
            onTap: _onItemTapped,
          ),
        ),
        body: Center(
          child: _pages.elementAt(_selectedIndex),
        ));
  }
}