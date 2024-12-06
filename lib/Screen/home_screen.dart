import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:news_app/Screen/bookmarked_news_screen.dart';
import 'package:news_app/Screen/category_news.dart';
import 'package:news_app/Screen/news_detail.dart';
import 'package:news_app/Services/services.dart';
import 'package:news_app/model/category_data.dart';
import 'package:news_app/model/new_model.dart';
import 'package:news_app/Services/database_helper.dart';


class NewsHomeScreen extends StatefulWidget {
  const NewsHomeScreen({super.key});

  @override
  _NewsHomeScreenState createState() => _NewsHomeScreenState();
}

class _NewsHomeScreenState extends State<NewsHomeScreen> {
  List<NewsModel> articles = [];
  List<NewsModel> filteredArticles = [];
  List<CategoryModel> categories = [];
  List<NewsModel> bookmarkedArticles = [];
  bool isLoading = true;
  String sortOrder = 'desc'; 

  int _selectedIndex = 0; 
  TextEditingController _searchController = TextEditingController(); 
  bool isSearching = false; 

  Future<void> getNews() async {
    try {
      setState(() {
        isLoading = true;
      });

      NewsApi newsApi = NewsApi();
      await newsApi.getNews();

      final now = DateTime.now();
      articles = newsApi.dataStore.where((article) {
        if (article.publishedAt == null) return false;
        try {
          final publishedDate = DateTime.parse(article.publishedAt!);
          return publishedDate.isAfter(now.subtract(const Duration(days: 7)));
        } catch (e) {
          return false;
        }
      }).toList();

      if (sortOrder == 'asc') {
        articles.sort((a, b) => DateTime.parse(a.publishedAt!).compareTo(DateTime.parse(b.publishedAt!)));
      } else {
        articles.sort((a, b) => DateTime.parse(b.publishedAt!).compareTo(DateTime.parse(a.publishedAt!)));
      }

      filteredArticles = List.from(articles);
    } catch (e) {
      print('Error loading news: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load news')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void toggleBookmark(NewsModel article) async {
    final dbHelper = DatabaseHelper();

    if (bookmarkedArticles.contains(article)) {
      await dbHelper.removeBookmark(article.title!);
      setState(() {
        bookmarkedArticles.remove(article);
      });
    } else {
      final result = await dbHelper.addBookmark(article);
      if (result > 0) {
        setState(() {
          bookmarkedArticles.add(article);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('This article is already saved!')),
        );
      }
    }
  }


  void filterNews(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredArticles = List.from(articles);
      } else {
        filteredArticles = articles
            .where((article) => article.title!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void changeSortOrder() {
    setState(() 
      sortOrder = sortOrder == 'asc' ? 'desc' : 'asc';
    });
    
    getNews();
  }

  @override
  void initState() {
    super.initState();
    categories = getCategories();
    getNews();
    loadBookmarks(); 
  }

// Load saved bookmarks
  void loadBookmarks() async {
    final dbHelper = DatabaseHelper();
    final bookmarks = await dbHelper.getBookmarks();
    setState(() {
      bookmarkedArticles = bookmarks;
    });
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0), 
        child: AppBar(
          title: isSearching
              ? TextField(
            controller: _searchController,
            onChanged: filterNews,
            decoration: InputDecoration(
              hintText: 'Search news...',
              hintStyle: const TextStyle(color: Colors.white70), 
              prefixIcon: const Icon(Icons.search, color: Colors.white), 
              suffixIcon: IconButton(
                icon: const Icon(Icons.close, color: Colors.white), 
                onPressed: () {
                  setState(() {
                    isSearching = false;
                    _searchController.clear();
                    filteredArticles = List.from(articles);
                  });
                },
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1), 
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15), 
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: Colors.white), 
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: Colors.white), 
              ),
            ),
          )
              : const Text(
            "News",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Colors.green, 
          elevation: 0,
          actions: [
            if (!isSearching)
              IconButton(
                icon: const Icon(
                  Icons.sort,
                  color: Colors.white,
                ),
                onPressed: changeSortOrder,
              ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: getNews,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      itemCount: categories.length,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SelectedCategoryNews(
                                    category: category.categoryName!),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.green,
                              ),
                              child: Text(
                                category.categoryName!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final article = filteredArticles[index];
                  final isBookmarked = bookmarkedArticles.contains(article);
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewsDetail(newsModel: article),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  article.urlToImage!,
                                  height: 250,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        height: 250,
                                        color: Colors.grey,
                                        child: const Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            size: 50,
                                          ),
                                        ),
                                      ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                article.title!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                getTimeAgo(article.publishedAt),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              const Divider(thickness: 2),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 30,
                          right: 15,
                          child: IconButton(
                            icon: Icon(
                              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                              color: Colors.green,
                            ),
                            onPressed: () {
                              toggleBookmark(article);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: filteredArticles.length,
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.green, // Background color set to red
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            switch (index) {
              case 0:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const NewsHomeScreen()),
                );
                break;
              case 1:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookmarkedNewsScreen(
                    ),
                  ),
                );
                break;
              case 2:
                setState(() {
                  isSearching = !isSearching;
                  if (!isSearching) {
                    _searchController.clear();
                    filteredArticles = List.from(articles);
                  }
                });
                break;
              case 3:
                getNews();
                break;
            }
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Bookmarks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.refresh),
            label: 'Refresh',
          ),
        ],
        iconSize: 20, 
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
      ),
    );
  }
}

