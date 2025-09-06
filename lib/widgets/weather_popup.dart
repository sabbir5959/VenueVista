import 'package:flutter/material.dart';
import '../services/weather_service.dart';

class WeatherPopup extends StatefulWidget {
  final String location;
  final DateTime bookingDate;
  final String groundName;

  const WeatherPopup({
    super.key,
    required this.location,
    required this.bookingDate,
    required this.groundName,
  });

  @override
  State<WeatherPopup> createState() => _WeatherPopupState();
}

class _WeatherPopupState extends State<WeatherPopup> {
  Map<String, dynamic>? weatherData;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // Extract city name from location
      final city = _extractCityFromLocation(widget.location);

      final data = await WeatherService.getWeatherByCity(
        city: city,
        date: widget.bookingDate,
      );

      setState(() {
        weatherData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to fetch weather data';
        isLoading = false;
      });
    }
  }

  String _extractCityFromLocation(String location) {
    // Clean up the location first - remove unwanted area details
    String cleanedLocation =
        location
            .replaceAll(RegExp(r'roundabout\s*area', caseSensitive: false), '')
            .replaceAll(RegExp(r'roundabout', caseSensitive: false), '')
            .replaceAll(
              RegExp(r'\s+'),
              ' ',
            ) // Replace multiple spaces with single space
            .trim();

    // Try to extract city name from cleaned address
    final parts = cleanedLocation.split(',').map((e) => e.trim()).toList();

    // Look for known city names in Bangladesh
    final bangladeshCities = [
      'dhaka',
      'chittagong',
      'sylhet',
      'rajshahi',
      'khulna',
      'rangpur',
      'mymensingh',
      'cumilla',
      'barisal',
      'narayanganj',
      'mirpur',
      'dhanmondi',
      'uttara',
      'gulshan',
      'banani',
    ];

    for (String part in parts) {
      for (String city in bangladeshCities) {
        if (part.toLowerCase().contains(city)) {
          return city.substring(0, 1).toUpperCase() + city.substring(1);
        }
      }
    }

    // If no city found, use the first part (cleaned) or default to Dhaka
    if (parts.isNotEmpty && parts.first.isNotEmpty) {
      String firstPart = parts.first;
      // If it contains numbers (like "Mirpur 10"), extract just the main area name
      if (firstPart.toLowerCase().contains('mirpur')) {
        return 'Mirpur';
      }
      return firstPart;
    }

    return 'Dhaka'; // Default fallback
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weather Update',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.groundName,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        _formatDate(widget.bookingDate),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Weather Content
            if (isLoading)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Fetching weather data...'),
                ],
              )
            else if (error != null)
              Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(error!, style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _fetchWeather,
                    child: const Text('Retry'),
                  ),
                ],
              )
            else if (weatherData != null)
              _buildWeatherContent()
            else
              Text(
                'No weather data available',
                style: TextStyle(color: Colors.grey.shade600),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherContent() {
    if (weatherData == null) return const SizedBox();

    return Column(
      children: [
        // Main weather info
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade300, Colors.blue.shade500],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                WeatherService.getWeatherIcon(weatherData!['description']),
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 8),
              Text(
                weatherData!['temperature'],
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                weatherData!['description'].toString().toUpperCase(),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Feels like ${weatherData!['feelsLike']}',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Additional weather details
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildWeatherDetail(
                'Humidity',
                weatherData!['humidity'],
                Icons.water_drop,
              ),
              const SizedBox(height: 12),
              _buildWeatherDetail(
                'Wind Speed',
                weatherData!['windSpeed'],
                Icons.air,
              ),
              const SizedBox(height: 12),
              _buildWeatherDetail(
                'Pressure',
                weatherData!['pressure'],
                Icons.compress,
              ),
              if (weatherData!['visibility'] != 'N/A') ...[
                const SizedBox(height: 12),
                _buildWeatherDetail(
                  'Visibility',
                  weatherData!['visibility'],
                  Icons.visibility,
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Location info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.location_on, color: Colors.green.shade600, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  weatherData!['city'],
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherDetail(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }
}
