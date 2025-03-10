import 'package:flutter/material.dart';
import 'package:flutter_weather_bg_null_safety/utils/weather_type.dart';
import 'package:sanitas/models/weather.dart';

class HomeWidget extends StatelessWidget {
  final Weather currentWeather;

  const HomeWidget({
    Key? key,
    required this.currentWeather,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double totalWidth = 300; // 90% of screen width

    // Percentage values
    double percentageA = 0.05; // 10%
    double percentageB = 0.6; // 20%
    double percentageC = 0.7; // 30%
    return Container(
      width: 300,
      height: 130,
      decoration: BoxDecoration(
        color: Colors.black, // Background color black
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
                      currentWeather.new_date,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // City Name (Below Date)
                    Text(
                      currentWeather.cityName,
                      style: TextStyle(
                        color: Colors.white,
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
                Text(
                  currentWeather.weather ,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                  ),
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
                    Positioned(left: totalWidth * percentageA - 12, child: percentageIndicator("5%")),
                    Positioned(left: totalWidth * percentageB - 12, child: percentageIndicator("60%")),
                    Positioned(left: totalWidth * percentageC - 12, child: percentageIndicator("70%")),
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
                    // Largest segment (C) at the bottom
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          height: 12,
                          width: totalWidth * percentageC,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.redAccent.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ),
                    // Middle segment (B) on top of C
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          height: 12,
                          width: totalWidth * percentageB,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.greenAccent.withOpacity(0.8),
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
                          width: totalWidth * percentageA,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.blueAccent.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Legend Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    legendItem(Colors.blueAccent, "Disease A", "5%"),
                    legendItem(Colors.greenAccent, "Disease B", "60%"),
                    legendItem(Colors.redAccent, "Disease C", "70%"),
                  ],
                ),
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
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
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
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}


