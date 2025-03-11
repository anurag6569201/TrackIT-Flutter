import 'package:flutter/material.dart';
import 'views/about/about.dart';
import 'views/dashboard/home.dart';
import 'views/materials/material.dart';
import 'views/updates/news.dart';

void main() {
  runApp(MaterialApp(
    home: HomePage(),
  ));
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(173, 189, 158,1),
          title: Image.asset('lib/assets/logo1.png', height: 60),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Home'),
              Tab(icon: Icon(Icons.article), text: 'Updates'),
              Tab(icon: Icon(Icons.book), text: 'Materials'),
              Tab(icon: Icon(Icons.info), text: 'About'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            HomeSection(),
            NewsSection(),
            MaterialSection(),
            AboutSection(),
          ],
        ),
      ),
    );
  }
}



