import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> with SingleTickerProviderStateMixin {
  DateTime selectedDate = DateTime.now();
  String weatherResult = '';
  bool isLoading = false;
  late AnimationController _animationController;

  // Predefined cities for dropdown
  final List<String> cities = [
    'Dhaka',
    'Mirpur',
    'Uttara',
    'Chittagong',
    'Khulna',
    'Sylhet',
    'Rajshahi',
  ];

  String? selectedCity; // currently selected city

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    selectedCity = cities.first; // default city selection
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 7)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.green.shade700,
              onPrimary: Colors.white,
              surface: Colors.green.shade900,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.green.shade800,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> fetchWeather() async {
    if (selectedCity == null || selectedCity!.isEmpty) {
      setState(() {
        weatherResult = 'Please select a city.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      weatherResult = '';
    });
    _animationController.repeat();

    final apiKey = '217aadec26df100fd829866790dd39fc'; // Replace with your API key
    final city = selectedCity!.trim();

    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final temp = data['main']['temp'];
        final description = data['weather'][0]['description'];
        final emoji = _getWeatherEmoji(description);

        // Capitalize first letter for condition label
        final conditionLabel = description[0].toUpperCase() + description.substring(1);

        setState(() {
          weatherResult = '$emoji\n$conditionLabel\n${temp.toStringAsFixed(1)}°C\n(${selectedDate.toLocal().toString().split(' ')[0]}) in $city';
        });
      } else {
        setState(() {
          weatherResult = 'Error: ${data['message']}';
        });
      }
    } catch (e) {
      setState(() {
        weatherResult = 'Failed to fetch weather.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
      _animationController.reset();
    }
  }

  String _getWeatherEmoji(String desc) {
    desc = desc.toLowerCase();
    if (desc.contains('rain')) return '🌧️';
    if (desc.contains('cloud')) return '☁️';
    if (desc.contains('clear')) return '☀️';
    if (desc.contains('snow')) return '❄️';
    if (desc.contains('storm')) return '⛈️';
    if (desc.contains('fog') || desc.contains('mist')) return '🌫️';
    return '🌤️';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade900, Colors.green.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Weather Forecast',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 5,
                        color: Colors.black45,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Dropdown for City Selection
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Select City',
                    labelStyle: TextStyle(color: Colors.green.shade200),
                    prefixIcon: Icon(Icons.location_city, color: Colors.green.shade200),
                    filled: true,
                    fillColor: Colors.green.shade800.withOpacity(0.7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.green.shade700),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedCity,
                      dropdownColor: Colors.green.shade800,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      items: cities
                          .map((city) => DropdownMenuItem(
                                value: city,
                                child: Text(city),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCity = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Date: ${selectedDate.toLocal().toString().split(' ')[0]}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade50,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 3,
                            color: Colors.black38,
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _selectDate(context),
                      icon: Icon(Icons.date_range),
                      label: Text('Pick Date'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 163, 215, 232),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        elevation: 6,
                        shadowColor: Colors.black45,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                ElevatedButton.icon(
                  onPressed: fetchWeather,
                  icon: Icon(Icons.cloud_outlined, size: 28),
                  label: Text(
                    'Get Weather',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade900,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 10,
                    shadowColor: Colors.black87,
                  ),
                ),
                const SizedBox(height: 40),

                Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isLoading
                        ? FadeTransition(
                            opacity: _animationController.drive(
                              Tween(begin: 0.3, end: 1.0).chain(
                                CurveTween(curve: Curves.easeInOut),
                              ),
                            ),
                            child: SizedBox(
                              height: 80,
                              width: 80,
                              child: CircularProgressIndicator(
                                strokeWidth: 8,
                                color: Colors.green.shade200,
                              ),
                            ),
                          )
                        : weatherResult.isNotEmpty
                            ? Container(
                                key: ValueKey(weatherResult),
                                padding: const EdgeInsets.all(28),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 15,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      weatherResult.split('\n')[0], // emoji
                                      style: TextStyle(fontSize: 70),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      weatherResult.split('\n')[1], // condition text
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade900,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      weatherResult.split('\n')[2], // temperature
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green.shade800,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      weatherResult.split('\n')[3], // date + city
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.green.shade700,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
