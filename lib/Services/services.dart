import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:news_app/model/new_model.dart';

class NewsApi {
  List<NewsModel> dataStore = [];

  Future<void> getNews({String? category}) async {
    final String baseUrl =
        "https://newsapi.org/v2/top-headlines?country=us&apiKey=4d0163ca61fa418b9dc45ca6db794b5a";
    final Uri url = category != null
        ? Uri.parse("$baseUrl&category=$category")
        : Uri.parse(baseUrl);

    try {
      var response = await http.get(url);
      var jsonData = jsonDecode(response.body);

      if (jsonData["status"] == 'ok') {
        dataStore.clear();
        jsonData["articles"].forEach((element) {
          if (element['urlToImage'] != null &&
              element['description'] != null &&
              element['author'] != null &&
              element['content'] != null &&
              element['publishedAt'] != null) {
            NewsModel newsModel = NewsModel(
              title: element['title'],
              urlToImage: element['urlToImage'],
              description: element['description'],
              author: element['author'],
              content: element['content'],
              publishedAt: element['publishedAt'],
            );
            dataStore.add(newsModel);
          }
        });
      }
    } catch (e) {
      print("Error fetching news: $e");
    }
  }
}
