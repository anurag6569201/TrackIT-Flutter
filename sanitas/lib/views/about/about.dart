import 'package:flutter/material.dart';

class AboutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Aligns all text to the left
        children: [
          Text(
            'Sanitas',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            'Version 1.0.0',
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 20),
          Text(
            'Imagine having access to a real-time map that not only visualizes disease hotspots but also predicts future outbreaks, all at your fingertips. The Disease Heatmap, a groundbreaking mapping system, is set to revolutionize how we monitor and respond to health threats in our communities.',
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              // Add widget to home screen logic
            },
            child: Text('Add Widget to Home Screen'),
          ),
          SizedBox(height: 20),
          Text(
            'Developed by: Sanitas Team',
            textAlign: TextAlign.center, // Only this text is centered
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
