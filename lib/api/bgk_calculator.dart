import 'dart:convert';

import 'package:http/http.dart' as http;

class BgkCalculator {

  Future<Map<String, dynamic>?> getRouteDetails(String origin, String destination) async {
    const String apiKey = 'AIzaSyAlLrkn1to0FEhEIsYuA0hTYBBdO0IJtck';
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
    var routeDetails = await getRouteDetails("Fabrikweg 27, Zurndorf", destination);
    var min = routeDetails?["duration"];
    var km = routeDetails?["distance"];

    if(min == null || km == null) {
      return 0.0;
    }

    double bgk = ((days * 2) * min) / 60 * 35 + (km*days);
    return bgk;
  }
}