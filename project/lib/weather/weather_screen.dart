import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with TickerProviderStateMixin {
  final WeatherService service = WeatherService();

  // Weather data
  double? temperature;
  String? cityName;
  String? description;
  String? iconCode;
  double? humidity;
  double? windSpeed;
  double? feelsLike;
  int? pressure;
  int? visibility;

  // UI state
  bool isLoading = true;
  String? error;
  bool isSearchMode = false;

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    fetchWeatherData();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_rotationController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> fetchWeatherByCity(String cityName) async {
    setState(() {
      isLoading = true;
      error = null;
      isSearchMode = true;
    });

    try {
      final weather = await service.fetchWeatherByCity(cityName);

      if (weather != null) {
        setState(() {
          temperature = weather['temp'];
          this.cityName = weather['city'];
          description = weather['description'];
          iconCode = weather['icon'];
          humidity = weather['humidity']?.toDouble() ?? 50.0;
          windSpeed = weather['windSpeed']?.toDouble() ?? 5.0;
          feelsLike = weather['feelsLike']?.toDouble() ?? temperature;
          pressure = weather['pressure'] ?? 1013;
          visibility = weather['visibility'] ?? 10000;
          isLoading = false;
        });
      } else {
        setState(() {
          error = "City not found. Please try another city.";
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

  Future<void> fetchWeatherData() async {
    setState(() {
      isLoading = true;
      error = null;
      isSearchMode = false;
    });

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
          humidity = weather['humidity']?.toDouble() ?? 50.0;
          windSpeed = weather['windSpeed']?.toDouble() ?? 5.0;
          feelsLike = weather['feelsLike']?.toDouble() ?? temperature;
          pressure = weather['pressure'] ?? 1013;
          visibility = weather['visibility'] ?? 10000;
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

  Color _getWeatherColor() {
    if (temperature == null) return Colors.blue;
    if (temperature! > 30) return Colors.orange;
    if (temperature! > 20) return Colors.green;
    if (temperature! > 10) return Colors.blue;
    return Colors.blueGrey;
  }

  String _getWeatherEmoji() {
    if (iconCode == null) return '🌤️';
    if (iconCode!.contains('01')) return '☀️';
    if (iconCode!.contains('02')) return '⛅';
    if (iconCode!.contains('03') || iconCode!.contains('04')) return '☁️';
    if (iconCode!.contains('09') || iconCode!.contains('10')) return '🌧️';
    if (iconCode!.contains('11')) return '⛈️';
    if (iconCode!.contains('13')) return '❄️';
    if (iconCode!.contains('50')) return '🌫️';
    return '🌤️';
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          SearchCityDialog(onCitySelected: fetchWeatherByCity),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weatherColor = _getWeatherColor();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              weatherColor.withOpacity(0.7),
              weatherColor.withOpacity(0.3),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar with search button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isSearchMode)
                      IconButton(
                        onPressed: fetchWeatherData,
                        icon: const Icon(
                          Icons.my_location,
                          color: Colors.white,
                          size: 28,
                        ),
                        tooltip: 'Use Current Location',
                      )
                    else
                      const SizedBox(width: 48),

                    Text(
                      isSearchMode ? 'Search Results' : 'Current Weather',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),

                    IconButton(
                      onPressed: _showSearchDialog,
                      icon: const Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 28,
                      ),
                      tooltip: 'Search City',
                    ),
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: isLoading
                    ? _buildLoadingState()
                    : error != null
                    ? _buildErrorState()
                    : _buildWeatherContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value,
                child: Icon(
                  Icons.cloud_sync,
                  size: 80,
                  color: Colors.white.withOpacity(0.8),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Fetching Weather Data...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Oops!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.red.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: fetchWeatherData,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherContent() {
    return RefreshIndicator(
      onRefresh: fetchWeatherData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildMainWeatherCard(),
              const SizedBox(height: 24),
              _buildDetailsGrid(),
              const SizedBox(height: 24),
              _buildRefreshButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainWeatherCard() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value * 0.1 + 0.95,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Location
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        cityName ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Weather icon
                Center(
                  child: iconCode != null
                      ? Image.network(
                          'https://openweathermap.org/img/wn/$iconCode@2x.png',
                          width: 80,
                          height: 80,
                          errorBuilder: (context, error, stackTrace) {
                            return Text(
                              _getWeatherEmoji(),
                              style: const TextStyle(fontSize: 64),
                            );
                          },
                        )
                      : Text(
                          _getWeatherEmoji(),
                          style: const TextStyle(fontSize: 64),
                        ),
                ),

                const SizedBox(height: 16),

                // Temperature
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween(begin: 0, end: temperature ?? 0),
                  builder: (context, value, child) {
                    return Text(
                      '${value.round()}°C',
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  },
                ),

                // Description
                Text(
                  description?.toUpperCase() ?? 'N/A',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 1.2,
                  ),
                ),

                if (feelsLike != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Feels like ${feelsLike!.round()}°C',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4, // Increased from 1.2 to give more height
      children: [
        _buildDetailCard(
          icon: Icons.water_drop,
          title: 'Humidity',
          value: '${humidity?.round() ?? 50}%',
          color: Colors.blue,
        ),
        _buildDetailCard(
          icon: Icons.air,
          title: 'Wind Speed',
          value: '${windSpeed?.toStringAsFixed(1) ?? "5.0"} m/s',
          color: Colors.green,
        ),
        _buildDetailCard(
          icon: Icons.compress,
          title: 'Pressure',
          value: '${pressure ?? 1013} hPa',
          color: Colors.orange,
        ),
        _buildDetailCard(
          icon: Icons.visibility,
          title: 'Visibility',
          value: '${((visibility ?? 10000) / 1000).toStringAsFixed(1)} km',
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12), // Reduced from 16
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // Added to prevent overflow
        children: [
          Container(
            padding: const EdgeInsets.all(8), // Reduced from 12
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 24, // Reduced from 32
              color: color,
            ),
          ),
          const SizedBox(height: 8), // Reduced from 12
          Flexible(
            // Added Flexible to prevent text overflow
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12, // Reduced from 14
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2), // Reduced from 4
          Flexible(
            // Added Flexible to prevent text overflow
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16, // Reduced from 18
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefreshButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: fetchWeatherData,
        icon: const Icon(Icons.refresh),
        label: const Text('Refresh Weather'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.2),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
        ),
      ),
    );
  }
}

class SearchCityDialog extends StatefulWidget {
  final Function(String) onCitySelected;

  const SearchCityDialog({super.key, required this.onCitySelected});

  @override
  State<SearchCityDialog> createState() => _SearchCityDialogState();
}

class _SearchCityDialogState extends State<SearchCityDialog> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _popularCities = [
    'New York',
    'London',
    'Tokyo',
    'Paris',
    'Sydney',
    'Mumbai',
    'Dubai',
    'Singapore',
    'Barcelona',
    'Rome',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _searchCity() {
    final city = _controller.text.trim();
    if (city.isNotEmpty) {
      Navigator.of(context).pop();
      widget.onCitySelected(city);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Search City Weather',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Search input
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Enter city name...',
                  prefixIcon: const Icon(Icons.location_city),
                  suffixIcon: IconButton(
                    onPressed: _searchCity,
                    icon: const Icon(Icons.search),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _searchCity(),
              ),
            ),

            // Popular cities
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Popular Cities',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _popularCities.map((city) {
                          return ActionChip(
                            label: Text(city),
                            onPressed: () {
                              Navigator.of(context).pop();
                              widget.onCitySelected(city);
                            },
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            labelStyle: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
