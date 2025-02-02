import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController apiKeyController = TextEditingController();
  String apiKey = "";
  bool isApiKeyValid = false;

  @override
  void initState() {
    super.initState();
    getApiKey();
    getYourAddress();
  }

  void setYourAddress(String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("user_address", address);
  }

  void getYourAddress() async {
    final prefs = await SharedPreferences.getInstance();
    addressController.text = prefs.getString("user_address") ?? "";
  }


  void getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    String savedKey = prefs.getString("api_key") ?? "";
    setState(() {
      apiKey = savedKey;
      apiKeyController.text = savedKey;
    });

    if (savedKey.isNotEmpty) {
      validateApiKey(savedKey);
    }
  }

  Future<void> validateApiKey(String key) async {
    final url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=test&key=$key";

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (data["status"] == "OK") {
        setState(() {
          isApiKeyValid = true;
        });
      } else {
        setState(() {
          isApiKeyValid = false;
        });
      }
    } catch (e) {
      setState(() {
        isApiKeyValid = false;
      });
    }
  }

  void setApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("api_key", key);
    setState(() {
      apiKey = key;
    });
    validateApiKey(key);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            controller: apiKeyController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Google API Key',
              suffixIcon: isApiKeyValid
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const Icon(Icons.error, color: Colors.red),
            ),
            onChanged: (value) {
              setApiKey(value);
            },
          ),
          const SizedBox(height: 20),
          AbsorbPointer(
            absorbing: !isApiKeyValid,
            child: Opacity(
              opacity: isApiKeyValid ? 1.0 : 0.5,
              child: GooglePlaceAutoCompleteTextField(
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
            ),
          ),
        ],
      ),
    );
  }
}
