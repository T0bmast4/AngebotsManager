import 'package:angebote_manager/api/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController addressController = TextEditingController();
  String apiKey = "";

  @override
  void initState() {
    super.initState();
    getApiKey();
    getYourAddress();
  }

  void getApiKey() async {
    String key = await ApiService().getAPIKey();

    setState(() {
      apiKey = key;
    });
  }

  bool isValidInput(String input) {
    return RegExp(r"^[a-zA-Z0-9\s,.-]+$").hasMatch(input);
  }

  void setYourAddress(String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("user_address", address);
  }

  void getYourAddress() async {
    final prefs = await SharedPreferences.getInstance();
    String address = prefs.getString("user_address") ?? "";
    setState(() {
      addressController.text = address;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          GooglePlaceAutoCompleteTextField(
            language: "de",
            textEditingController: addressController,
            googleAPIKey: apiKey,
            inputDecoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Deine Adresse',
            ),
            debounceTime: 600,
            itemClick: (prediction) {
              addressController.text = prediction.description!;
              addressController.selection = TextSelection.fromPosition(
                TextPosition(offset: prediction.description!.length),
              );
              setYourAddress(prediction.description!);
            },
          ),
        ],
      ),
    );
  }
}