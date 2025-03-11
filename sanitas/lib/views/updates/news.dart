import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './news_model.dart';

class NewsSection extends StatefulWidget {
  @override
  _NewsSectionState createState() => _NewsSectionState();
}

class _NewsSectionState extends State<NewsSection> {
  List<NewsItem> newsList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    try {
      final response = await http.get(Uri.parse('http://172.22.0.37:8000/api/recent/updates/'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          newsList = data.map((item) => NewsItem(
            title: item['title'],
            content: item['content'],
            date: item['date'].substring(0, 10), // Extracting only the date part
            imageUrl: 'https://picsum.photos/200', // Placeholder image
          )).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      print('Error fetching news: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              final news = newsList[index];
              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text(news.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(news.content),
                      SizedBox(height: 5),
                      Text(news.date, style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              );
            },
          );
  }
}
