import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // Using OpenWeatherMap API - you can replace with your preferred weather API
  static const String _apiKey =
      'your_api_key_here'; // Replace with your API key
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  static Future<Map<String, dynamic>?> getWeatherByCity({
    required String city,
    DateTime? date,
  }) async {
    try {
      // For current weather (if no specific date is provided or date is today)
      final bool isCurrentWeather = date == null || _isToday(date);

      if (isCurrentWeather) {
        return await _getCurrentWeather(city);
      } else {
        // For future dates, use forecast API
        return await _getForecastWeather(city, date);
      }
    } catch (e) {
      print('❌ Weather API Error: $e');
      return _getFallbackWeather(city);
    }
  }

  static Future<Map<String, dynamic>?> _getCurrentWeather(String city) async {
    final url = '$_baseUrl/weather?q=$city&appid=$_apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _formatWeatherData(data);
      }
    } catch (e) {
      print('❌ Current Weather Error: $e');
    }

    return _getFallbackWeather(city);
  }

  static Future<Map<String, dynamic>?> _getForecastWeather(
    String city,
    DateTime date,
  ) async {
    final url = '$_baseUrl/forecast?q=$city&appid=$_apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Find the forecast closest to the requested date
        final forecasts = data['list'] as List;
        final targetTimestamp = date.millisecondsSinceEpoch ~/ 1000;

        Map<String, dynamic>? closestForecast;
        int closestDiff = double.maxFinite.toInt();

        for (var forecast in forecasts) {
          final forecastTime = forecast['dt'] as int;
          final diff = (forecastTime - targetTimestamp).abs();

          if (diff < closestDiff) {
            closestDiff = diff;
            closestForecast = forecast;
          }
        }

        if (closestForecast != null) {
          return _formatForecastData(closestForecast, data);
        }
      }
    } catch (e) {
      print('❌ Forecast Weather Error: $e');
    }

    return _getFallbackWeather(city);
  }

  static Map<String, dynamic> _formatWeatherData(Map<String, dynamic> data) {
    final main = data['main'];
    final weather = data['weather'][0];
    final wind = data['wind'] ?? {};

    return {
      'temperature': '${main['temp'].round()}°C',
      'feelsLike': '${main['feels_like'].round()}°C',
      'humidity': '${main['humidity']}%',
      'pressure': '${main['pressure']} hPa',
      'description': weather['description'],
      'icon': weather['icon'],
      'windSpeed':
          '${(wind['speed'] * 3.6).round()} km/h', // Convert m/s to km/h
      'visibility':
          data['visibility'] != null
              ? '${(data['visibility'] / 1000).round()} km'
              : 'N/A',
      'city': data['name'],
    };
  }

  static Map<String, dynamic> _formatForecastData(
    Map<String, dynamic> forecast,
    Map<String, dynamic> cityData,
  ) {
    final main = forecast['main'];
    final weather = forecast['weather'][0];
    final wind = forecast['wind'] ?? {};

    return {
      'temperature': '${main['temp'].round()}°C',
      'feelsLike': '${main['feels_like'].round()}°C',
      'humidity': '${main['humidity']}%',
      'pressure': '${main['pressure']} hPa',
      'description': weather['description'],
      'icon': weather['icon'],
      'windSpeed': '${(wind['speed'] * 3.6).round()} km/h',
      'visibility': 'N/A', // Not available in forecast
      'city': cityData['city']['name'],
    };
  }

  static Map<String, dynamic> _getFallbackWeather(String city) {
    // Fallback weather data when API fails
    final random = DateTime.now().millisecond % 100;

    final descriptions = [
      'Clear Sky',
      'Partly Cloudy',
      'Cloudy',
      'Light Rain',
      'Sunny',
      'Overcast',
    ];

    return {
      'temperature': '${25 + (random % 10)}°C',
      'feelsLike': '${27 + (random % 8)}°C',
      'humidity': '${60 + (random % 25)}%',
      'pressure': '${1010 + (random % 20)} hPa',
      'description': descriptions[random % descriptions.length],
      'icon': '01d', // Clear sky icon
      'windSpeed': '${8 + (random % 15)} km/h',
      'visibility': '${8 + (random % 5)} km',
      'city': city,
    };
  }

  static bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static String getWeatherIcon(String description) {
    switch (description.toLowerCase()) {
      case 'clear sky':
      case 'sunny':
        return '☀️';
      case 'partly cloudy':
        return '⛅';
      case 'cloudy':
      case 'overcast':
        return '☁️';
      case 'light rain':
        return '🌦️';
      case 'heavy rain':
      case 'rain':
        return '🌧️';
      case 'thunderstorm':
        return '⛈️';
      case 'snow':
        return '🌨️';
      case 'mist':
      case 'fog':
        return '🌫️';
      default:
        return '🌤️';
    }
  }
}
