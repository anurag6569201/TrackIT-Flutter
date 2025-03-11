import 'package:flutter/material.dart';
import 'package:sanitas/views/dashboard/dashboard_screen.dart';

class HomeSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const DashboardScreen(),
    );
  }
}