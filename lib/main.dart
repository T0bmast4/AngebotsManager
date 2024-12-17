import 'dart:io';

import 'package:angebote_manager/ui/designables/epox_navbar.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  if(Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
  }

  databaseFactory = databaseFactoryFfi;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EPOX Angebote',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[800],
          title: const Text(style: TextStyle(color: Colors.white), "EPOX"),
          elevation: 20,
          centerTitle: true,
        ),
      body: const EpoxNavbar(),
    );
  }
}