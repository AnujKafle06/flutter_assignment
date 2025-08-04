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

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          'temp': data['main']['temp']?.toDouble(),
          'city': data['name'] ?? 'Unknown Location',
          'description': data['weather'][0]['description'] ?? 'No description',
          'icon': data['weather'][0]['icon'] ?? '01d',
          'feelsLike': data['main']['feels_like']?.toDouble(),
          'humidity': data['main']['humidity']?.toDouble(),
          'pressure': data['main']['pressure']?.toInt(),
          'windSpeed': data['wind']?['speed']?.toDouble(),
          'windDirection': data['wind']?['deg']?.toInt(),
          'visibility': data['visibility']?.toInt(),
          'cloudiness': data['clouds']?['all']?.toInt(),
          'tempMin': data['main']['temp_min']?.toDouble(),
          'tempMax': data['main']['temp_max']?.toDouble(),
          'country': data['sys']?['country'] ?? '',
          'coordinates': {
            'lat': data['coord']?['lat']?.toDouble(),
            'lon': data['coord']?['lon']?.toDouble(),
          },
          'sunrise': data['sys']?['sunrise']?.toInt(),
          'sunset': data['sys']?['sunset']?.toInt(),
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
      } else {
        print('Weather API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Weather Service Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchWeatherByCity(String cityName) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          'temp': data['main']['temp']?.toDouble(),
          'city': data['name'] ?? cityName,
          'description': data['weather'][0]['description'] ?? 'No description',
          'icon': data['weather'][0]['icon'] ?? '01d',
          'feelsLike': data['main']['feels_like']?.toDouble(),
          'humidity': data['main']['humidity']?.toDouble(),
          'pressure': data['main']['pressure']?.toInt(),
          'windSpeed': data['wind']?['speed']?.toDouble(),
          'windDirection': data['wind']?['deg']?.toInt(),
          'visibility': data['visibility']?.toInt(),
          'cloudiness': data['clouds']?['all']?.toInt(),
          'tempMin': data['main']['temp_min']?.toDouble(),
          'tempMax': data['main']['temp_max']?.toDouble(),
          'country': data['sys']?['country'] ?? '',
          'coordinates': {
            'lat': data['coord']?['lat']?.toDouble(),
            'lon': data['coord']?['lon']?.toDouble(),
          },
          'sunrise': data['sys']?['sunrise']?.toInt(),
          'sunset': data['sys']?['sunset']?.toInt(),
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
      } else {
        print('Weather API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Weather Service Error: $e');
      return null;
    }
  }

  String getWeatherCategory(String iconCode) {
    if (iconCode.contains('01')) return 'clear';
    if (iconCode.contains('02')) return 'partly_cloudy';
    if (iconCode.contains('03') || iconCode.contains('04')) return 'cloudy';
    if (iconCode.contains('09') || iconCode.contains('10')) return 'rainy';
    if (iconCode.contains('11')) return 'thunderstorm';
    if (iconCode.contains('13')) return 'snowy';
    if (iconCode.contains('50')) return 'foggy';
    return 'unknown';
  }

  String getWindDirection(int? degrees) {
    if (degrees == null) return 'N/A';

    const directions = [
      'N',
      'NNE',
      'NE',
      'ENE',
      'E',
      'ESE',
      'SE',
      'SSE',
      'S',
      'SSW',
      'SW',
      'WSW',
      'W',
      'WNW',
      'NW',
      'NNW',
    ];

    final index = ((degrees + 11.25) / 22.5).floor() % 16;
    return directions[index];
  }
}
