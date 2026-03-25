import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const String _langKey = 'selected_language';
  Locale _locale = const Locale('en');
  late SharedPreferences _prefs;

  Locale get locale => _locale;
  bool get isIndonesian => _locale.languageCode == 'id';

  LanguageService() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    _prefs = await SharedPreferences.getInstance();
    final langCode = _prefs.getString(_langKey) ?? 'en';
    _locale = Locale(langCode);
    notifyListeners();
  }

  Future<void> setLanguage(String langCode) async {
    _locale = Locale(langCode);
    await _prefs.setString(_langKey, langCode);
    notifyListeners();
  }

  String translate(String en, String id) {
    return isIndonesian ? id : en;
  }
}
