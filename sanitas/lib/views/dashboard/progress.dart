import 'package:flutter/material.dart';

class MultiColorProgressBar extends StatelessWidget {
  final List<dynamic> diseases;
  final int totalCases;
  MultiColorProgressBar({required this.diseases, required this.totalCases});
  @override
  Widget build(BuildContext context) {
    double totalWidth = MediaQuery.of(context).size.width * 1; // 90% of screen width

    // Percentage values
    double percentageA = (diseases[0]['cases']/totalCases); // 5%
    double percentageB = (diseases[1]['cases']/totalCases); // 15%
    double percentageC = (diseases[2]['cases']/totalCases); // 25%
    double percentageD = (diseases[3]['cases']/totalCases); // 35%
    double percentageE = (diseases[4]['cases']/totalCases); // 45%

    return Padding(
      padding: const EdgeInsets.all(0),
      child: Column(
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
                      color: Color.fromRGBO(82, 109, 130,1),
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
              legendItem(Color.fromRGBO(0, 103, 105,0.5), "${diseases[0]['name']}", "${diseases[0]['cases']}"),
              legendItem(Color.fromRGBO(64, 165, 120,0.5), "${diseases[1]['name']}", "${diseases[1]['cases']}"),
              legendItem(Color.fromRGBO(157, 222, 139,0.5), "${diseases[2]['name']}", "${diseases[2]['cases']}"),
            ],
          ),
          SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              legendItem(Color.fromRGBO(230, 255, 148,0.5), "${diseases[3]['name']}", "${diseases[3]['cases']}"),
              legendItem(Color.fromRGBO(82, 109, 130,1), "${diseases[4]['name']}", "${diseases[4]['cases']}"),
              legendItem(Color.fromRGBO(255, 255, 255, 0), "${diseases[5]['name']}", "${diseases[5]['cases']}"),
            ],
          )
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
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,color: Color.fromRGBO(18, 55, 42,1)),
        ),
      ],
    );
  }
}
