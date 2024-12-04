import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../model/new_model.dart'; // Adjust path if needed

class NewsDetail extends StatelessWidget {
  final NewsModel newsModel;

  const NewsDetail({Key? key, required this.newsModel}) : super(key: key);

  // Helper method to format time into "time ago" format
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green, // Consistent color for the app bar
        title: const Text(
          "News Details",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white), // Set title text color to white
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // White back arrow
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous page
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white), // Ensure consistent icon color
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the image of the news
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: newsModel.urlToImage != null && newsModel.urlToImage!.isNotEmpty
                  ? Image.network(
                newsModel.urlToImage!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
                  : Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Display the title of the news
            Text(
              newsModel.title ?? "No Title Available",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),

            // Display the time since publication
            Text(
              "Published: ${getTimeAgo(newsModel.publishedAt)}",
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),

            // Display the content of the news, if available
            Text(
              newsModel.content ?? "No content available.",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
