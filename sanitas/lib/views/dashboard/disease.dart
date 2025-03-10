import 'package:sanitas/models/location.dart';
import 'package:sanitas/models/weather.dart' as wt;
import 'package:sanitas/constants/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_weather_bg_null_safety/flutter_weather_bg.dart';
import 'package:sanitas/constants/strings.dart';
import 'package:sanitas/home_widget_config.dart';
import 'package:sanitas/views/home_widget/home_widget.dart';
import 'package:weather/weather.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  WeatherFactory wf = WeatherFactory(key);
  Location? loc; 
  wt.Weather? currentWeather;
  List<dynamic> diseases = [];
  int totalCases = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await HomeWidgetConfig.initialize();
      await callApiAndUpdateUI();
      fetchDiseaseData();
    });
  }

  Future<void> callApiAndUpdateUI() async {
    try {
      loc = await Location.pickLocation();
      if (loc == null) throw Exception("Location not found");

      var weatherData = await wf.currentWeatherByLocation(loc!.lat, loc!.long);

      setState(() {
        currentWeather = wt.Weather(
          weatherType: WeatherUtil().fromCode(weatherData.weatherConditionCode),
          weather: "${weatherData.temperature?.celsius?.toStringAsFixed(2) ?? "--"}°",
          desc: weatherData.weatherDescription ?? "--",
          image: "https://openweathermap.org/img/wn/${weatherData.weatherIcon}@2x.png",
          cityName: weatherData.areaName ?? "--",
        );
      });

      HomeWidgetConfig.update(context, HomeWidget(weather: currentWeather!));
    } catch (e) {
      print("Error fetching location/weather: $e");
    }
  }

  Future<void> fetchDiseaseData() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8000/map/api/diseases/'));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body); // Parse as Map
        List<dynamic> topDiseases = data['top_diseases'] ?? [];
        int total = data['total_cases'] ?? 0;

        setState(() {
          diseases = topDiseases; // Assign the extracted list
          totalCases = total; // Assign the extracted total
        });

      } else {
        throw Exception('Failed to load disease data');
      }
    } catch (e) {
      print('Error fetching disease data: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: fetchDiseaseData,
        elevation: 0,
        backgroundColor: Colors.blueAccent.withOpacity(0.3),
        child: const Icon(Icons.refresh),
      ),
      body: Stack(
        children: [
          // Weather Background
          Positioned.fill(
            child: WeatherBg(
              weatherType: currentWeather?.weatherType ?? WeatherType.sunny,
              width: screenWidth,
              height: MediaQuery.of(context).size.height,
            ),
          ),

          // Disease Dashboard
          Positioned(
            top: 90,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Top 5 Diseases",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth / 18,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: .1,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  children: List.generate(
                    diseases.length > 5 ? 5 : diseases.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        "${index + 1}. ${diseases[index]['name']} - ${diseases[index]['cases']} cases",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth / 22,
                          fontWeight: FontWeight.w500,
                          shadows: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: .1,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "Total Cases: $totalCases",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: screenWidth / 16,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        spreadRadius: .1,
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}









