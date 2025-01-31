import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {

  Future<Map<String, dynamic>?> getRouteDetails(String origin, String destination) async {
    String apiKey = await getAPIKey();

    final String url = 'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final route = data['routes'][0];
          final legs = route['legs'][0];

          final distance = legs['distance']['value'] / 1000;
          final int durationInSeconds = legs['duration']['value'];
          final int durationInMinutes = (durationInSeconds / 60).round();

          return {
            'distance': distance,
            'duration': durationInMinutes,
          };
        } else {
          print('Fehler: ${data['status']}');
        }
      } else {
        print('Fehler: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }
    return null;
  }

  Future<double> getBGK(int days, String destination) async {
    final prefs = await SharedPreferences.getInstance();
    String address = await prefs.getString("user_address") ?? "";

    if(address.isEmpty) {
      return 0.0;
    }
    var routeDetails = await getRouteDetails(address, destination);

    var min = routeDetails?["duration"];
    var km = routeDetails?["distance"];

    if(min == null || km == null) {
      return 0.0;
    }

    double bgk = ((days * 2) * min) / 60 * 35 + (km*days);
    return bgk;
  }

  Future<String> getAPIKey() async {
    String apiKey = "";
    try {
      final keyFile = await rootBundle.loadString('assets/keys.txt');
      apiKey = keyFile.trim();

      if (apiKey.contains("=")) {
        apiKey = apiKey.split("=")[1].trim();
      }
    } catch (e) {
      throw Exception("Fehler beim Laden des Keys: $e");
    }
    return apiKey;
  }
}