class NewsModel {
  String? title;
  String? description;
  String? urlToImage;
  String? author;
  String? content;
  String? publishedAt;

  NewsModel({
    this.title,
    this.description,
    this.urlToImage,
    this.author,
    this.content,
    this.publishedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'urlToImage': urlToImage,
      'author': author,
      'content': content,
      'publishedAt': publishedAt,
    };
  }

  factory NewsModel.fromMap(Map<String, dynamic> map) {
    return NewsModel(
      title: map['title'],
      description: map['description'],
      urlToImage: map['urlToImage'],
      author: map['author'],
      content: map['content'],
      publishedAt: map['publishedAt'],

    );
  }
}
