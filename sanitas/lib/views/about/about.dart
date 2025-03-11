import 'package:flutter/material.dart';

class AboutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('lib/assets/app_icon.png'),
          ),
          SizedBox(height: 20),
          Text(
            'My Awesome App',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Version 1.0.0',
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 20),
          Text(
            'This is a sample app description. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              // Add widget to home screen logic
            },
            child: Text('Add Widget to Home Screen'),
          ),
          SizedBox(height: 20),
          InkWell(
            onTap: () {
              // Open privacy policy
            },
            child: Text(
              'Privacy Policy',
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Developed by: Your Name\n\nSpecial thanks to:\n- Contributors\n- Testers\n- Open source projects',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}