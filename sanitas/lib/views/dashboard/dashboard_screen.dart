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
import 'package:geolocator/geolocator.dart';

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
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await HomeWidgetConfig.initialize();
      await fetchWeatherAndLocation();
      await fetchDiseaseData();
    });
  }

  Future<void> fetchWeatherAndLocation() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      bool hasPermission = await _requestLocationPermission();
      if (!hasPermission) {
        setState(() => errorMessage = "Location permission denied.");
        return;
      }

      loc = await Location.pickLocation();
      if (loc == null) throw Exception("Location not available.");

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
        isLoading = false;
      });

      HomeWidgetConfig.update(context, HomeWidget(currentWeather: currentWeather!));
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Failed to load weather data. Please try again.";
      });
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
      setState(() => errorMessage = "Error fetching disease data.");
      debugPrint('Error fetching disease data: $e');
    }
  }

  Future<bool> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    double totalWidth = MediaQuery.of(context).size.width * 1;

    // Safely calculate percentages
    int safeTotalCases = totalCases > 0 ? totalCases : 1;
    double percentageA = diseases.length > 0 ? (diseases[0]['cases'] / safeTotalCases) : 0.0;
    double percentageB = diseases.length > 1 ? (diseases[1]['cases'] / safeTotalCases) : 0.0;
    double percentageC = diseases.length > 2 ? (diseases[2]['cases'] / safeTotalCases) : 0.0;
    double percentageD = diseases.length > 3 ? (diseases[3]['cases'] / safeTotalCases) : 0.0;
    double percentageE = diseases.length > 4 ? (diseases[4]['cases'] / safeTotalCases) : 0.0;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: fetchWeatherAndLocation,
        elevation: 0,
        backgroundColor: const Color.fromRGBO(173, 189, 158, 1),
        child: const Icon(Icons.refresh),
      ),
      body: Stack(
        children: [
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (errorMessage != null)
            Center(
              child: Text(
                errorMessage!,
                style: TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            )
          else
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only( left: 12, right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
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
                                color: Color.fromRGBO(18, 55, 42, 1),
                                fontSize: screenWidth / 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              currentWeather?.cityName ?? '--',
                              style: TextStyle(
                                color: Color.fromRGBO(18, 55, 42, 1),
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
                                color: Color.fromRGBO(18, 55, 42, 1),
                                fontSize: screenWidth / 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '+$totalCases ↑',
                              style: TextStyle(
                                color: Color.fromRGBO(18, 55, 42, 1),
                                fontSize: screenWidth / 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Container(
                                height: 12,
                                width: totalWidth,
                              ),
                              Positioned(
                                left: totalWidth * percentageA - 12,
                                child: percentageIndicator("${(percentageA * 100).toStringAsFixed(0)}%"),
                              ),
                              Positioned(
                                left: totalWidth * percentageC - 12,
                                child: percentageIndicator("${(percentageC * 100).toStringAsFixed(0)}%"),
                              ),
                              Positioned(
                                left: totalWidth * percentageE - 12,
                                child: percentageIndicator("${(percentageE * 100).toStringAsFixed(0)}%"),
                              ),
                            ],
                          ),
                          SizedBox(height: 2),
                          Stack(
                            children: [
                              Container(
                                height: 12,
                                width: totalWidth,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[300],
                                ),
                              ),
                              Positioned.fill(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    height: 12,
                                    width: totalWidth * percentageE,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Color.fromRGBO(82, 109, 130,1),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    height: 12,
                                    width: totalWidth * percentageD,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Color.fromRGBO(230, 255, 148,0.7),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    height: 12,
                                    width: totalWidth * percentageC,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Color.fromRGBO(157, 222, 139,0.5),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    height: 12,
                                    width: totalWidth * percentageB,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Color.fromRGBO(64, 165, 120,0.5),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    height: 12,
                                    width: totalWidth * percentageA,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Color.fromRGBO(0, 103, 105,0.5),
                                    ),
                                  ),
                                ),
                              ),
                              
                            ],
                          ),
                          SizedBox(height: 2),
                          Stack(
                            children: [
                              Container(
                                height: 12,
                                width: totalWidth,
                              ),
                              Positioned(
                                left: totalWidth * percentageB - 12,
                                child: percentageIndicator("${(percentageB * 100).toStringAsFixed(0)}%"),
                              ),
                              Positioned(
                                left: totalWidth * percentageD - 12,
                                child: percentageIndicator("${(percentageD * 100).toStringAsFixed(0)}%"),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),

                          // Legend Section with safe index checks
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              diseases.length > 0 
                                  ? legendItem(Color.fromRGBO(0, 103, 105,0.5), "${diseases[0]['name']}", "${diseases[0]['cases']}")
                                  : Container(),
                              diseases.length > 1 
                                  ? legendItem(Color.fromRGBO(64, 165, 120,0.5), "${diseases[1]['name']}", "${diseases[1]['cases']}")
                                  : Container(),
                              diseases.length > 2 
                                  ? legendItem(Color.fromRGBO(157, 222, 139,0.5), "${diseases[2]['name']}", "${diseases[2]['cases']}")
                                  : Container(),
                            ],
                          ),
                          SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              diseases.length > 3 
                                  ? legendItem(Color.fromRGBO(230, 255, 148,0.5), "${diseases[3]['name']}", "${diseases[3]['cases']}")
                                  : Container(),
                              diseases.length > 4 
                                  ? legendItem(Color.fromRGBO(82, 109, 130,1), "${diseases[4]['name']}", "${diseases[4]['cases']}")
                                  : Container(),
                              diseases.length > 5 
                                  ? legendItem(Color.fromRGBO(255, 255, 255, 0), "${diseases[5]['name']}", "${diseases[5]['cases']}")
                                  : Container(),
                            ],
                          )
                        ],
                      ),
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

  Widget percentageIndicator(String label) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,color: Color.fromRGBO(18, 55, 42,1)),
        ),
      ],
    );
  }
  Widget legendItem(Color color, String disease, String cases) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 4),
        Text(
          "$disease ($cases)",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,color: Color.fromRGBO(18, 55, 42,1)),
        ),
      ],
    );
  }
}