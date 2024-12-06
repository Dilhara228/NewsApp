import 'package:flutter/material.dart';
import 'package:news_app/Screen/news_detail.dart';
import 'package:news_app/Services/services.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../model/new_model.dart';
import 'package:news_app/Services/database_helper.dart'; 

class SelectedCategoryNews extends StatefulWidget {
  final String category;

  const SelectedCategoryNews({Key? key, required this.category}) : super(key: key);

  @override
  State<SelectedCategoryNews> createState() => _SelectedCategoryNewsState();
}

class _SelectedCategoryNewsState extends State<SelectedCategoryNews> {
  List<NewsModel> articles = [];
  bool isLoading = true;
  List<NewsModel> bookmarkedArticles = [];

  Future<void> getCategoryNews() async {
    try {
      NewsApi newsApi = NewsApi();
      await newsApi.getNews(category: widget.category.toLowerCase());
      setState(() {
        articles = newsApi.dataStore;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching category news: $e");
    }
  }

  Future<void> loadBookmarks() async {
    final dbHelper = DatabaseHelper();
    final bookmarks = await dbHelper.getBookmarks();
    setState(() {
      bookmarkedArticles = bookmarks;
    });
  }

  bool isBookmarked(NewsModel article) {
    return bookmarkedArticles.any((a) => a.title == article.title); 
  }

  Future<void> toggleBookmark(NewsModel article) async {
    final dbHelper = DatabaseHelper();
    if (isBookmarked(article)) {
      await dbHelper.removeBookmark(article.title!);
    } else {
      await dbHelper.addBookmark(article);
    }
    await loadBookmarks(); 
  }

  String getTimeAgo(String? publishedAt) {
    if (publishedAt == null) return "Unknown";
    try {
      final publishedDate = DateTime.parse(publishedAt);
      return timeago.format(publishedDate);
    } catch (e) {
      return "Unknown";
    }
  }

  @override
  void initState() {
    super.initState();
    getCategoryNews();
    loadBookmarks(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          widget.category,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : articles.isEmpty
          ? const Center(
        child: Text("No news available in this category"),
      )
          : ListView.builder(
        itemCount: articles.length,
        padding: const EdgeInsets.all(10),
        itemBuilder: (context, index) {
          final article = articles[index];
          final isBookmarked = this.isBookmarked(article);

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewsDetail(newsModel: article),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    child: Image.network(
                      article.urlToImage ?? '',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                            height: 200,
                            width: double.infinity,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.broken_image, size: 50),
                            ),
                          ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.title ?? 'No Title',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              getTimeAgo(article.publishedAt),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isBookmarked
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: isBookmarked
                                    ? Colors.green
                                    : Colors.green,
                              ),
                              onPressed: () {
                                toggleBookmark(article); 
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
