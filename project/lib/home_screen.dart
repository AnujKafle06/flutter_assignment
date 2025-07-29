import 'package:flutter/material.dart';
import 'package:project/fire_base_auth/auth_screen.dart';

import 'bloc_counter/bloc_counter_screen.dart';
import 'provider_counter/provider_counter_screen.dart';
import 'weather/weather_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feature Navigator')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Provider Counter'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProviderCounterScreen()),
            ),
          ),
          ListTile(
            title: const Text('BLoC Counter'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BlocCounterScreen()),
            ),
          ),
          ListTile(
            title: const Text('Weather App'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WeatherScreen()),
            ),
          ),
          ListTile(
            title: const Text('Firebase Auth & Firestore'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AuthScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
