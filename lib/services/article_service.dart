import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/article.dart';
import '../data/mock_data.dart';

class ArticleService extends ChangeNotifier {
  static const String _storageKey = 'plantify_articles';
  
  static const List<String> categories = [
    'Cultivation',
    'Prevention',
    'Plant Nutrition',
    'Ag-Tech',
    'Research',
    'Disease Management',
    'Fertilizer',
    'Harvesting',
    'Basics',
    'General Tips',
  ];
  
  // Initialize with mock data by default, but this will be overwritten if prefs exist
  List<Article> _allArticles = [];

  ArticleService() {
    _loadArticles();
  }

  // Getter for Featured Articles (used by Carousel)
  List<Article> get featuredArticles => 
      _allArticles.where((a) => a.isFeatured).toList();

  // Getter for Standard Articles (used by Latest Articles list)
  List<Article> get articles => 
      _allArticles.where((a) => !a.isFeatured).toList();

  // Getter for ALL articles (used by Management screen)
  List<Article> get allArticles => _allArticles;

  Future<void> _loadArticles() async {
    final prefs = await SharedPreferences.getInstance();
    final String? articlesJson = prefs.getString(_storageKey);

    if (articlesJson != null) {
      final List<dynamic> decodedList = jsonDecode(articlesJson);
      _allArticles = decodedList.map((item) => Article.fromMap(item)).toList();
    } else {
      // First run: Use mock data
      _allArticles = [
        ...MockData.featuredArticles,
        ...MockData.articles,
      ];
      // Save it immediately so next time we have it
      _saveArticles();
    }
    notifyListeners();
  }

  Future<void> _saveArticles() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = jsonEncode(_allArticles.map((a) => a.toMap()).toList());
    await prefs.setString(_storageKey, encodedList);
  }

  void addArticle(Article article) {
    _allArticles.insert(0, article);
    _saveArticles();
    notifyListeners();
  }

  void updateArticle(Article updatedArticle) {
    int index = _allArticles.indexWhere((a) => a.id == updatedArticle.id);
    if (index != -1) {
      _allArticles[index] = updatedArticle;
      _saveArticles();
      notifyListeners();
    }
  }

  void deleteArticle(String id) {
    _allArticles.removeWhere((a) => a.id == id);
    _saveArticles();
    notifyListeners();
  }
}