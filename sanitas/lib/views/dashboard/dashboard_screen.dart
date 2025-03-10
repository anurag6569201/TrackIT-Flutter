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
import 'progress.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  WeatherFactory wf = WeatherFactory(key);
  Location? loc; // Make it nullable
  wt.Weather? currentWeather;
  List<dynamic> diseases = [];
  int totalCases = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      HomeWidgetConfig.initialize().then((value) async {
        await callApiAndUpdateUI();
        fetchDiseaseData();
      });
    });
  }

  Future<void> callApiAndUpdateUI() async {
    try {
      loc = await Location.pickLocation(); // Wait for the user's real location
      var weatherData = await wf.currentWeatherByLocation(loc!.lat, loc!.long);
      
      // Format the date properly
      String formattedDate = DateFormat('EEEE, MMM d, yyyy').format(weatherData.date!);

      setState(() {
        currentWeather = wt.Weather(
          weatherType: WeatherUtil().fromCode(weatherData.weatherConditionCode),
          weather: "${weatherData.temperature?.celsius?.toStringAsFixed(2) ?? "--"}°",
          desc: weatherData.weatherDescription ?? "--",
          image: "https://openweathermap.org/img/wn/${weatherData.weatherIcon}@2x.png",
          cityName: weatherData.areaName ?? "--",
          new_date: formattedDate,
          total_cases:"500",
        );
      });

      HomeWidgetConfig.update(context, HomeWidget(currentWeather: currentWeather!));
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
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Container(
      child:Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          callApiAndUpdateUI();
        },
        elevation: 0,
        backgroundColor: Colors.blueAccent.withOpacity(0.3),
        child: const Icon(Icons.refresh),
      ),
      body: Stack(
        children: [
          if (currentWeather?.weatherType != null)
            WeatherBg(
              weatherType: currentWeather!.weatherType,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            )
          else
            const Center(
              child: CircularProgressIndicator(),
            ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(top: screenHeight / 15, left: 12, right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row with Date, City, and Weather
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date (Top Left)
                          Text(
                            currentWeather?.new_date ?? '--',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth / 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          // City Name (Below Date)
                          Text(
                            currentWeather?.cityName ?? '--',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth / 15,
                              fontWeight: FontWeight.w700,
                              shadows: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.8),
                                  spreadRadius: .1,
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Temperature (Right Side)
                      Text(
                        currentWeather?.weather ?? '--',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth / 7,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Center(child: MultiColorProgressBar()),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
