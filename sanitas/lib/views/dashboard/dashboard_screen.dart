import 'package:sanitas/models/location.dart';
import 'package:sanitas/models/weather.dart' as wt;
import 'package:sanitas/constants/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_weather_bg_null_safety/flutter_weather_bg.dart';
import 'package:sanitas/constants/strings.dart';
import 'package:sanitas/home_widget_config.dart';
import 'package:sanitas/views/home_widget/home_widget.dart';
import 'package:weather/weather.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'progress.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final WeatherFactory wf = WeatherFactory(key);
  Location? loc;
  wt.Weather? currentWeather;
  List<dynamic> diseases = [];
  int totalCases = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await HomeWidgetConfig.initialize();
      await callApiAndUpdateUI();
      fetchDiseaseData();
    });
  }

  Future<void> callApiAndUpdateUI() async {
    try {
      loc = await Location.pickLocation();
      final weatherData = await wf.currentWeatherByLocation(loc!.lat, loc!.long);
      final formattedDate = DateFormat('EEEE, MMM d, yyyy').format(weatherData.date!);

      setState(() {
        currentWeather = wt.Weather(
          weatherType: WeatherUtil().fromCode(weatherData.weatherConditionCode),
          weather: "${weatherData.temperature?.celsius?.toStringAsFixed(2) ?? "--"}°",
          desc: weatherData.weatherDescription ?? "--",
          image: "https://openweathermap.org/img/wn/${weatherData.weatherIcon}@2x.png",
          cityName: weatherData.areaName ?? "--",
          new_date: formattedDate,
          total_cases: "500",
        );
      });

      HomeWidgetConfig.update(context, HomeWidget(currentWeather: currentWeather!));
    } catch (e) {
      debugPrint("Error fetching location/weather: $e");
    }
  }

  Future<void> fetchDiseaseData() async {
    try {
      final response = await http.get(Uri.parse('http://172.22.0.37:8000/map/api/diseases/'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        setState(() {
          diseases = data['top_diseases'] ?? [];
          totalCases = data['total_cases'] ?? 0;
        });
      } else {
        throw Exception('Failed to load disease data');
      }
    } catch (e) {
      debugPrint('Error fetching disease data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      floatingActionButton: FloatingActionButton(
        onPressed: callApiAndUpdateUI,
        elevation: 0,
        backgroundColor: const Color.fromRGBO(18, 55, 42,1),
        child: const Icon(Icons.refresh),
      ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(top: screenHeight / 15, left: 12, right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'lib/assets/logo1.png',
                    height: 100,
                  ),
                  const Divider( 
                    color: Colors.black,
                    thickness: 1, 
                    height: 10, 
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentWeather?.new_date ?? '--',
                            style: TextStyle(
                              color: Color.fromRGBO(18, 55, 42,1),
                              fontSize: screenWidth / 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            currentWeather?.cityName ?? '--',
                            style: TextStyle(
                              color: Color.fromRGBO(18, 55, 42,1),
                              fontSize: screenWidth / 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currentWeather?.weather ?? '--',
                            style: TextStyle(
                              color: Color.fromRGBO(18, 55, 42,1),
                              fontSize: screenWidth / 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '+$totalCases ↑',
                            style: TextStyle(
                              color: Color.fromRGBO(18, 55, 42,1),
                              fontSize: screenWidth / 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: MultiColorProgressBar(
                      diseases: diseases,
                      totalCases: totalCases,
                    ),
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