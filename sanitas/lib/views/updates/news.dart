import 'package:flutter/material.dart';
import './news_model.dart';


class NewsSection extends StatelessWidget {
  final List<NewsItem> dummyNews = [
    NewsItem(
      title: 'Breaking News 1',
      content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      date: '2023-08-01',
      imageUrl: 'https://picsum.photos/200',
    ),
    NewsItem(
      title: 'Important Update',
      content: 'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
      date: '2023-08-02',
      imageUrl: 'https://picsum.photos/201',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchNews(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: dummyNews.length,
          itemBuilder: (context, index) {
            final news = dummyNews[index];
            return Card(
              margin: EdgeInsets.all(8),
              child: ListTile(
                leading: Image.network(news.imageUrl),
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
      },
    );
  }

  Future<List<NewsItem>> _fetchNews() async {
    await Future.delayed(Duration(seconds: 1));
    return dummyNews;
  }
}