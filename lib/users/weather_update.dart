import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'widgets/common_drawer.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage>
    with TickerProviderStateMixin {
  DateTime selectedDate = DateTime.now();
  bool isLoading = false;
  late AnimationController _backgroundAnimationController;
  late AnimationController _cardAnimationController;
  late AnimationController _rainAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Weather data
  Map<String, dynamic>? weatherData;
  String temperature = '25°C';
  String description = 'Clear Sky';
  String humidity = '65%';
  String windSpeed = '12 km/h';
  String feelsLike = '28°C';
  String pressure = '1013 hPa';
  String visibility = '10 km';
  IconData weatherIcon = Icons.wb_sunny;
  List<Color> backgroundGradient = [
    const Color(0xFF667eea),
    const Color(0xFF764ba2),
    const Color(0xFFf093fb),
  ];

  // Predefined cities for dropdown
  final List<Map<String, dynamic>> cities = [
    {'name': 'Dhaka', 'icon': Icons.location_city, 'temp': '28°C'},
    {'name': 'Chittagong', 'icon': Icons.directions_boat, 'temp': '26°C'},
    {'name': 'Sylhet', 'icon': Icons.landscape, 'temp': '24°C'},
    {'name': 'Rajshahi', 'icon': Icons.agriculture, 'temp': '30°C'},
    {'name': 'Khulna', 'icon': Icons.water, 'temp': '27°C'},
    {'name': 'Barisal', 'icon': Icons.beach_access, 'temp': '25°C'},
    {'name': 'Rangpur', 'icon': Icons.terrain, 'temp': '23°C'},
    {'name': 'Mymensingh', 'icon': Icons.park, 'temp': '26°C'},
  ];

  String? selectedCity;

  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _cardAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _rainAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.bounceOut,
      ),
    );

    selectedCity = cities.first['name'];

    // Start animations
    _cardAnimationController.forward();
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _cardAnimationController.dispose();
    _rainAnimationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.light,
            ),
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
    if (selectedCity == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Simulate API call with beautiful loading
      await Future.delayed(const Duration(seconds: 2));

      // Mock weather data based on city
      final cityData = cities.firstWhere(
        (city) => city['name'] == selectedCity,
      );

      setState(() {
        temperature = cityData['temp'];
        description = _getRandomWeatherDescription();
        humidity = '${60 + math.Random().nextInt(30)}%';
        windSpeed = '${5 + math.Random().nextInt(15)} km/h';
        feelsLike =
            '${int.parse(temperature.replaceAll('°C', '')) + math.Random().nextInt(5)}°C';
        pressure = '${1000 + math.Random().nextInt(50)} hPa';
        visibility = '${8 + math.Random().nextInt(5)} km';
        weatherIcon = _getWeatherIcon(description);
        backgroundGradient = _getGradientForWeather(description);
      });

      // Restart card animation
      _cardAnimationController.reset();
      _cardAnimationController.forward();
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
        return Icons.wb_cloudy;
      case 'cloudy':
      case 'overcast':
        return Icons.cloud;
      case 'light rain':
        return Icons.grain;
      case 'heavy rain':
        return Icons.thunderstorm;
      case 'thunderstorm':
        return Icons.flash_on;
      default:
        return Icons.wb_sunny;
    }
  }

  List<Color> _getGradientForWeather(String desc) {
    switch (desc.toLowerCase()) {
      case 'clear sky':
      case 'sunny':
        return [
          const Color(0xFFffecd2),
          const Color(0xFFfcb69f),
          const Color(0xFFff9a9e),
        ];
      case 'partly cloudy':
        return [
          const Color(0xFF89f7fe),
          const Color(0xFF66a6ff),
          const Color(0xFF667eea),
        ];
      case 'cloudy':
      case 'overcast':
        return [
          const Color(0xFFbdc3c7),
          const Color(0xFF2c3e50),
          const Color(0xFF34495e),
        ];
      case 'light rain':
      case 'heavy rain':
        return [
          const Color(0xFF74b9ff),
          const Color(0xFF0984e3),
          const Color(0xFF6c5ce7),
        ];
      case 'thunderstorm':
        return [
          const Color(0xFF2d3436),
          const Color(0xFF636e72),
          const Color(0xFF6c5ce7),
        ];
      default:
        return [
          const Color(0xFF667eea),
          const Color(0xFF764ba2),
          const Color(0xFFf093fb),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CommonDrawer(),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Weather Forecast',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchWeather,
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _backgroundAnimationController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: backgroundGradient,
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // City Selection Card
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildCitySelectionCard(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Date Selection Card
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildDateSelectionCard(),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Main Weather Card
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildMainWeatherCard(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Weather Details Grid
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildWeatherDetailsGrid(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCitySelectionCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 25,
            offset: const Offset(0, 12),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(-5, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(Icons.location_on, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 15),
              Text(
                'Select City',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.25),
                  Colors.white.withOpacity(0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedCity,
                isExpanded: true,
                dropdownColor: Colors.indigo.shade800,
                style: TextStyle(color: Colors.white, fontSize: 16),
                icon: Icon(Icons.keyboard_arrow_down, color: Colors.white),
                items:
                    cities.map<DropdownMenuItem<String>>((city) {
                      return DropdownMenuItem<String>(
                        value: city['name'],
                        child: Row(
                          children: [
                            Icon(city['icon'], color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                            Text(city['name']),
                            const Spacer(),
                            Text(
                              city['temp'],
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
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
    );
  }

  Widget _buildMainWeatherCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
          stops: [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 20),
            spreadRadius: 5,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(-10, -10),
          ),
        ],
      ),
      child: Column(
        children: [
          if (isLoading)
            Column(
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 4,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Loading weather data...',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            )
          else
            Column(
              children: [
                // Weather Icon
                AnimatedBuilder(
                  animation: _rainAnimationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_rainAnimationController.value * 0.1),
                      child: Icon(weatherIcon, size: 100, color: Colors.white),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Temperature
                ShaderMask(
                  shaderCallback:
                      (bounds) => LinearGradient(
                        colors: [Colors.white, Colors.white.withOpacity(0.8)],
                      ).createShader(bounds),
                  child: Text(
                    temperature,
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w200,
                      color: Colors.white,
                      height: 1,
                      letterSpacing: -2,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Description
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Text(
                    description,
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white.withOpacity(0.95),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // Feels like
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.25),
                        Colors.white.withOpacity(0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.thermostat, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Feels like $feelsLike',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetailsGrid() {
    final details = [
      {
        'icon': Icons.water_drop,
        'label': 'Humidity',
        'value': humidity,
        'color': Colors.blue,
      },
      {
        'icon': Icons.air,
        'label': 'Wind Speed',
        'value': windSpeed,
        'color': Colors.cyan,
      },
      {
        'icon': Icons.speed,
        'label': 'Pressure',
        'value': pressure,
        'color': Colors.orange,
      },
      {
        'icon': Icons.visibility,
        'label': 'Visibility',
        'value': visibility,
        'color': Colors.green,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.1,
      ),
      itemCount: details.length,
      itemBuilder: (context, index) {
        final detail = details[index];
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.25),
                Colors.white.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(-5, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (detail['color'] as Color).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  detail['icon'] as IconData,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                detail['label'] as String,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                detail['value'] as String,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateSelectionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                'Forecast Date',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          InkWell(
            onTap: () => _selectDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: Colors.white),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: fetchWeather,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.9),
                foregroundColor: backgroundGradient.first,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_download, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    'Get Weather Forecast',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
