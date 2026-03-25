class Article {
  final String id;
  final String title;
  final String category;
  final String imageUrl;
  final String date;
  final String readTime;
  final bool isFeatured;
  final String summary;
  final String authorName;
  final String authorRole;
  final String authorImageUrl;
  final String content;

  const Article({
    required this.id,
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.date,
    required this.readTime,
    this.isFeatured = false,
    required this.summary,
    this.authorName = "Dr. Sarah Chen",
    this.authorRole = "PhD in Plant Pathology",
    this.authorImageUrl = "assets/images/profile_pic.png",
    this.content = "Tomatoes (Solanum lycopersicum) are one of the most popular crops in home gardens, but they are susceptible to a variety of pests that can significantly reduce yield. Understanding these pests and how to manage them is crucial for a successful harvest.\n\nEarly detection is key to preventing major infestations. Regular monitoring of your plants, checking the undersides of leaves, and looking for signs of damage can help you catch problems before they get out of hand. Common pests include aphids, tomato hornworms, and whiteflies.",
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'imageUrl': imageUrl,
      'date': date,
      'readTime': readTime,
      'isFeatured': isFeatured,
      'summary': summary,
      'authorName': authorName,
      'authorRole': authorRole,
      'authorImageUrl': authorImageUrl,
      'content': content,
    };
  }

  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      date: map['date'] ?? '',
      readTime: map['readTime'] ?? '',
      isFeatured: map['isFeatured'] ?? false,
      summary: map['summary'] ?? '',
      authorName: map['authorName'] ?? '',
      authorRole: map['authorRole'] ?? '',
      authorImageUrl: map['authorImageUrl'] ?? 'assets/images/profile_pic.png',
      content: map['content'] ?? '',
    );
  }
}
