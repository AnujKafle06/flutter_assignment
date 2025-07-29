import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService service = WeatherService();
  double? temperature;
  String? cityName;
  String? description;
  String? iconCode;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    try {
      final position = await _determinePosition();
      final weather = await service.fetchWeatherByCoordinates(
        position.latitude,
        position.longitude,
      );

      if (weather != null) {
        setState(() {
          temperature = weather['temp'];
          cityName = weather['city'];
          description = weather['description'];
          iconCode = weather['icon'];
          isLoading = false;
        });
      } else {
        setState(() {
          error = "Failed to load weather data.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Error: ${e.toString()}";
        isLoading = false;
      });
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location services are disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Real-Time Weather')),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : error != null
            ? Text(
                error!,
                style: const TextStyle(fontSize: 18, color: Colors.red),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (iconCode != null)
                    Image.network(
                      'https://openweathermap.org/img/wn/$iconCode@2x.png',
                    ),
                  Text('$cityName', style: const TextStyle(fontSize: 28)),
                  Text('$temperature°C', style: const TextStyle(fontSize: 48)),
                  Text('$description', style: const TextStyle(fontSize: 22)),
                ],
              ),
      ),
    );
  }
}
