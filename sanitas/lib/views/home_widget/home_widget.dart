import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_weather_bg_null_safety/utils/weather_type.dart';
import 'package:sanitas/models/weather.dart';

class HomeWidget extends StatefulWidget {
  final Weather currentWeather;

  const HomeWidget({
    Key? key,
    required this.currentWeather,
  }) : super(key: key);

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}
class _HomeWidgetState extends State<HomeWidget> {
  List<dynamic> diseases = [];
  int totalCases = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchDiseaseData();
    });
  }

  Future<void> fetchDiseaseData() async {
    try {
      final response =
          await http.get(Uri.parse('http://172.22.0.37:8000/map/api/diseases/'));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> topDiseases = data['top_diseases'] ?? [];
        int total = data['total_cases'] ?? 0;

        setState(() {
          diseases = topDiseases;
          totalCases = total;
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
    double totalWidth = 300; // 90% of screen width

    // Percentage values
    double percentageA = (diseases[0]['cases']/totalCases); // 5%
    double percentageB = (diseases[1]['cases']/totalCases); // 15%
    double percentageC = (diseases[2]['cases']/totalCases); // 25%
    double percentageD = (diseases[3]['cases']/totalCases); // 35%
    double percentageE = (diseases[4]['cases']/totalCases); // 45%
    return Container(
      width: 300,
      height: 150,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(173, 188, 159,1),
        borderRadius: BorderRadius.circular(4), // Rounded corners
      ),

      child: Padding(
      padding: EdgeInsets.only(top: 10, left: 10, right: 10,bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.currentWeather.new_date,
                      style: TextStyle(
                        color: const Color.fromRGBO(18, 55, 42,1),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // City Name (Below Date)
                    Text(
                      widget.currentWeather.cityName,
                      style: TextStyle(
                        color: const Color.fromRGBO(18, 55, 42,1),
                        fontSize: 20,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${widget.currentWeather.weather}', // Correct string interpolation
                      style: TextStyle(
                        color: const Color.fromRGBO(18, 55, 42, 1),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // City Name (Below Date)
                    Text(
                      '+$totalCases ↑', // Correct string interpolation
                      style: TextStyle(
                        color: const Color.fromRGBO(18, 55, 42, 1),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        shadows: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.8),
                            spreadRadius: 0.1,
                            blurRadius: 16,
                          ),
                        ],
                      ),
                    ),
                  ],

                ),
              ],
            ),
            SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dynamic Percentage Indicators using Stack
                Stack(
                  children: [
                    Container(
                      height: 12,
                      width: totalWidth,
                    ),
                    Positioned(
                      left: totalWidth * (diseases[0]['cases'] / totalCases) - 12,
                      child: percentageIndicator("${((diseases[0]['cases'] / totalCases) * 100).toStringAsFixed(0)}%"),
                    ),
                    Positioned(
                      left: totalWidth * (diseases[2]['cases'] / totalCases) - 12,
                      child: percentageIndicator("${((diseases[2]['cases'] / totalCases) * 100).toStringAsFixed(0)}%"),
                    ),
                    Positioned(
                      left: totalWidth * (diseases[4]['cases'] / totalCases) - 12,
                      child: percentageIndicator("${((diseases[4]['cases'] / totalCases) * 100).toStringAsFixed(0)}%"),
                    ),
                  ],
                ),
                SizedBox(height: 2),

                // Multi-color Progress Bar (With Background)
                Stack(
                  children: [
                    // Background progress bar
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
                            color: Color.fromRGBO(35, 136, 85, 0.839),
                          ),
                        ),
                      ),
                    ),
                    // Smallest segment (A) on top of B
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          height: 12,
                          width: totalWidth * percentageD,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Color.fromRGBO(25, 80, 60, 0.8),
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
                            color: Color.fromRGBO(134, 214, 102, 0.8),
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
                            color: Color.fromRGBO(75, 182, 196, 0.8),
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
                            color: Color.fromRGBO(30, 122, 188, 0.8),
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
                      left: totalWidth * (diseases[1]['cases'] / totalCases) - 12,
                      child: percentageIndicator("${((diseases[1]['cases'] / totalCases) * 100).toStringAsFixed(0)}%"),
                    ),
                    Positioned(
                      left: totalWidth * (diseases[3]['cases'] / totalCases) - 12,
                      child: percentageIndicator("${((diseases[3]['cases'] / totalCases) * 100).toStringAsFixed(0)}%"),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Legend Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    legendItem(Color.fromRGBO(35, 136, 85, 0.839), "${diseases[0]['name']}", "${diseases[0]['cases']}"),
                    legendItem(Color.fromRGBO(25, 80, 60, 0.8), "${diseases[1]['name']}", "${diseases[1]['cases']}"),
                    legendItem(Color.fromRGBO(134, 214, 102, 0.8), "${diseases[2]['name']}", "${diseases[2]['cases']}"),
                  ],
                ),
                SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    legendItem(Color.fromRGBO(75, 182, 196, 0.8), "${diseases[3]['name']}", "${diseases[3]['cases']}"),
                    legendItem(Color.fromRGBO(30, 122, 188, 0.8), "${diseases[4]['name']}", "${diseases[4]['cases']}"),
                    legendItem(Color.fromRGBO(66, 190, 147, 1), "${diseases[5]['name']}", "${diseases[5]['cases']}"),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget percentageIndicator(String label) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold,color: const Color.fromRGBO(18, 55, 42,1)),
        ),
      ],
    );
  }
  Widget legendItem(Color color, String disease, String percentage) {
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
          "$disease ($percentage)",
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500,color: const Color.fromRGBO(18, 55, 42,1)),
        ),
      ],
    );
  }
}


