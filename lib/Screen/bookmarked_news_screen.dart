import 'package:flutter/material.dart';
import 'package:news_app/Screen/news_detail.dart';
import 'package:news_app/model/new_model.dart'; 
import 'package:news_app/Services/database_helper.dart'; 
import 'package:timeago/timeago.dart' as timeago;

class BookmarkedNewsScreen extends StatefulWidget {
  @override
  _BookmarkedNewsScreenState createState() => _BookmarkedNewsScreenState();
}

class _BookmarkedNewsScreenState extends State<BookmarkedNewsScreen> {
  List<NewsModel> bookmarkedArticles = [];
  String sortCriteria = "Date"; // Default sort by date

  // Load saved bookmarks from the database
  Future<void> loadBookmarks() async {
    final dbHelper = DatabaseHelper();
    final bookmarks = await dbHelper.getBookmarks(); // Fetch bookmarks from DB
    setState(() {
      bookmarkedArticles = bookmarks; // Ensure bookmarks are updated in the list
      sortArticles(); // Sort articles based on selected criteria
    });
  }

  // Delete a bookmarked article
  Future<void> deleteArticle(NewsModel article) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.removeBookmark(article.title!); // Remove bookmark from DB based on title or identifier
    loadBookmarks(); // Refresh the bookmark list after removal
  }

  // Sort articles based on the selected criteria
  void sortArticles() {
    setState(() {
      if (sortCriteria == "Date") {
        bookmarkedArticles.sort((a, b) =>
            DateTime.parse(b.publishedAt!).compareTo(DateTime.parse(a.publishedAt!)));
      } else if (sortCriteria == "Title") {
        bookmarkedArticles.sort((a, b) => (a.title ?? "").compareTo(b.title ?? ""));
      }
    });
  }

  // Format time ago
  String formatTimeAgo(String? publishedAt) {
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
    loadBookmarks(); // Load bookmarks when screen initializes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          "Bookmarked Articles",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
           PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                sortCriteria = value;
                sortArticles(); 
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: "Date", child: Text("Sort by Date")),
              const PopupMenuItem(value: "Title", child: Text("Sort by Title")),
            ],
            icon: const Icon(Icons.sort, color: Colors.white),
          ),
        ],
      ),
      body: bookmarkedArticles.isEmpty
          ? const Center(child: Text("No bookmarks available"))
          : ListView.builder(
        itemCount: bookmarkedArticles.length,
        itemBuilder: (context, index) {
          final article = bookmarkedArticles[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green, width: 2),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0, 2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewsDetail(newsModel: article),
                  ),
                );
              },
              onSecondaryTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewsDetail(newsModel: article),
                  ),
                );
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (article.urlToImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        article.urlToImage!,
                        width: 100,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      width: 100,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                      ),
                    ),
                  const SizedBox(width: 10), 
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.title ?? "No Title",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          formatTimeAgo(article.publishedAt),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  // Delete Button
                  Container(
                    alignment: Alignment.center,
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.green),
                      onPressed: () {
                        deleteArticle(article);
                      },
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
