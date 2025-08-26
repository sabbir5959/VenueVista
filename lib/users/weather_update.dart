import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'widgets/common_drawer.dart';

class WeatherUpdate extends StatefulWidget {
  const WeatherUpdate({super.key});

  @override
  State<WeatherUpdate> createState() => _WeatherUpdateState();
}

class _WeatherUpdateState extends State<WeatherUpdate> {
  DateTime selectedDate = DateTime.now();
  bool isLoading = false;

  String? selectedCity = 'Dhaka';
  String temperature = '25°C';
  String humidity = '65%';
  String windSpeed = '12 km/h';
  String description = 'Clear Sky';
  String feelsLike = '28°C';
  String pressure = '1013 hPa';
  String visibility = '10 km';
  IconData weatherIcon = Icons.wb_sunny;

  final List<String> cities = [
    'Dhaka',
    'Chittagong',
    'Sylhet',
    'Rajshahi',
    'Khulna',
    'Rangpur',
    'Mymensingh',
    'Cumilla',
  ];

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        // Generate random weather data for demonstration
        description = _getRandomWeatherDescription();
        temperature = '${20 + math.Random().nextInt(15)}°C';
        humidity = '${50 + math.Random().nextInt(30)}%';
        windSpeed = '${5 + math.Random().nextInt(20)} km/h';
        feelsLike =
            '${int.parse(temperature.replaceAll('°C', '')) + math.Random().nextInt(5)}°C';
        pressure = '${1000 + math.Random().nextInt(50)} hPa';
        visibility = '${8 + math.Random().nextInt(5)} km';
        weatherIcon = _getWeatherIcon(description);
      });
    } catch (e) {
      setState(() {
        description = 'Unable to fetch weather data';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _getRandomWeatherDescription() {
    final descriptions = [
      'Clear Sky',
      'Partly Cloudy',
      'Cloudy',
      'Light Rain',
      'Heavy Rain',
      'Thunderstorm',
      'Sunny',
      'Overcast',
    ];
    return descriptions[math.Random().nextInt(descriptions.length)];
  }

  IconData _getWeatherIcon(String desc) {
    switch (desc.toLowerCase()) {
      case 'clear sky':
      case 'sunny':
        return Icons.wb_sunny;
      case 'partly cloudy':
        return Icons.cloud_queue;
      case 'cloudy':
      case 'overcast':
        return Icons.cloud;
      case 'light rain':
      case 'heavy rain':
        return Icons.grain;
      case 'thunderstorm':
        return Icons.thunderstorm;
      default:
        return Icons.wb_sunny;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CommonDrawer(),
      appBar: AppBar(
        title: const Text(
          'Weather & Forecast',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.green.shade700,
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchWeather,
            tooltip: 'Refresh Weather',
          ),
          IconButton(
            icon: const Icon(Icons.location_on, color: Colors.white),
            onPressed: () {
              // Optional: Add location-based weather functionality
            },
            tooltip: 'Current Location',
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFF5F6FA),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // City Selection Card
                _buildCitySelectionCard(),
                const SizedBox(height: 16),

                // Date Selection Card
                _buildDateSelectionCard(),
                const SizedBox(height: 20),

                // Main Weather Card
                _buildMainWeatherCard(),
                const SizedBox(height: 20),

                // Weather Details Section
                Text(
                  'Weather Details',
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Weather Details Grid
                _buildWeatherDetailsGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCitySelectionCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.green.shade700, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Choose Your Location',
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCity,
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  style: TextStyle(color: Colors.grey.shade800, fontSize: 16),
                  iconEnabledColor: Colors.green.shade700,
                  items:
                      cities.map((String city) {
                        return DropdownMenuItem<String>(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCity = newValue;
                    });
                    fetchWeather();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainWeatherCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (isLoading)
              Column(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading weather data...',
                    style: TextStyle(color: Colors.grey.shade800, fontSize: 16),
                  ),
                ],
              )
            else
              Column(
                children: [
                  // Weather Icon
                  Icon(weatherIcon, size: 80, color: Colors.green.shade700),
                  const SizedBox(height: 16),

                  // Temperature
                  Text(
                    temperature,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Text(
                      description,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Feels like
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.thermostat,
                        color: Colors.grey.shade600,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Feels like $feelsLike',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetailsGrid() {
    final details = [
      {'icon': Icons.water_drop, 'label': 'Humidity', 'value': humidity},
      {'icon': Icons.air, 'label': 'Wind Speed', 'value': windSpeed},
      {'icon': Icons.speed, 'label': 'Pressure', 'value': pressure},
      {'icon': Icons.visibility, 'label': 'Visibility', 'value': visibility},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: details.length,
      itemBuilder: (context, index) {
        final detail = details[index];
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  detail['icon'] as IconData,
                  color: Colors.green.shade700,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  detail['label'] as String,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail['value'] as String,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateSelectionCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Colors.green.shade700,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Select Forecast Date',
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 7)),
                      );
                      if (picked != null && picked != selectedDate) {
                        setState(() {
                          selectedDate = picked;
                        });
                        fetchWeather();
                      }
                    },
                    child: Icon(
                      Icons.edit_calendar,
                      color: Colors.green.shade700,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
