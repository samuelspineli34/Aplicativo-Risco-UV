import 'package:flutter/material.dart';
import 'package:weather/weather.dart';

class WeatherDisplay extends StatefulWidget {
  @override
  _WeatherDisplayState createState() => _WeatherDisplayState();
}

class _WeatherDisplayState extends State<WeatherDisplay> {
  WeatherFactory wf = WeatherFactory("bd5e378503939ddaee76f12ad7a97608", language: Language.PORTUGUESE_BRAZIL);

  Weather? currentWeather;

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    try {
      Weather w = await wf.currentWeatherByLocation(-19.912998, -43.940933);
      setState(() {
        currentWeather = w;
      });
    } catch (e) {
      // Handle any errors, e.g., if there's an issue with the API request.
      print('Error fetching weather data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Current Weather'),
      ),
      body: Center(
        child: currentWeather != null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('City: ${currentWeather!.areaName}'),
            Text('Temperature: ${currentWeather?.temperature?.celsius}°C'),
            Text('Weather: ${currentWeather!.weatherDescription}'),
          ],
        )
            : CircularProgressIndicator(), // Show a loading indicator while fetching data.
      ),
    );
  }
}
