import 'dart:convert';

import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = '96f0d4b3d8f0b7fe969f8e64ed77289d';

  Future<Map<String, dynamic>?> fetchWeatherByCoordinates(
    double lat,
    double lon,
  ) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'temp': data['main']['temp'],
        'city': data['name'],
        'description': data['weather'][0]['description'],
        'icon': data['weather'][0]['icon'],
      };
    }
    return null;
  }
}
