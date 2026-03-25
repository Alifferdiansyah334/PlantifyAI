import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/detection_history.dart';

class DetectionHistoryService extends ChangeNotifier {
  static const String _storageKey = 'plantify_detection_history';
  List<DetectionHistory> _history = [];

  List<DetectionHistory> get history => _history;

  DetectionHistoryService() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString(_storageKey);

    if (historyJson != null) {
      final List<dynamic> decodedList = jsonDecode(historyJson);
      _history = decodedList.map((item) => DetectionHistory.fromMap(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = jsonEncode(_history.map((h) => h.toMap()).toList());
    await prefs.setString(_storageKey, encodedList);
  }

  void addDetection(DetectionHistory detection) {
    _history.insert(0, detection); // Add to top
    _saveHistory();
    notifyListeners();
  }

  void deleteDetection(String id) {
    _history.removeWhere((item) => item.id == id);
    _saveHistory();
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    _saveHistory();
    notifyListeners();
  }

  Map<String, int> getStats() {
    int total = _history.length;
    int healthy = _history.where((h) => h.resultStatus.toLowerCase() == 'healthy').length;
    int diseased = total - healthy;

    return {
      'total': total,
      'healthy': healthy,
      'diseased': diseased,
    };
  }
}
