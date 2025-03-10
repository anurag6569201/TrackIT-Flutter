import 'package:flutter/material.dart';

class MultiColorProgressBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double totalWidth = MediaQuery.of(context).size.width * 1; // 90% of screen width

    // Percentage values
    double percentageA = 0.05; // 10%
    double percentageB = 0.6; // 20%
    double percentageC = 0.7; // 30%

    return Padding(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dynamic Percentage Indicators using Stack
          Stack(
            children: [
              Container(
                height: 16,
                width: totalWidth,
              ),
              Positioned(left: totalWidth * percentageA - 12, child: percentageIndicator("5%")),
              Positioned(left: totalWidth * percentageB - 12, child: percentageIndicator("60%")),
              Positioned(left: totalWidth * percentageC - 12, child: percentageIndicator("70%")),
            ],
          ),
          SizedBox(height: 4),

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
    );
  }

  // Widget to create percentage indicators dynamically
  Widget percentageIndicator(String label) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 2),
        Container(
          width: 1.5,
          height: 6,
          color: Colors.black,
        ),
      ],
    );
  }

  // Widget to create the legend (color + disease name + percentage)
  Widget legendItem(Color color, String disease, String percentage) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6),
        Text(
          "$disease ($percentage)",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
