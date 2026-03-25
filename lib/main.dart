import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'theme/app_theme.dart';
import 'theme/theme_service.dart';
import 'services/language_service.dart';
import 'services/article_service.dart';
import 'services/detection_history_service.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => LanguageService()),
        ChangeNotifierProvider(create: (_) => ArticleService()),
        ChangeNotifierProvider(create: (_) => DetectionHistoryService()),
      ],
      child: const ToastificationWrapper(child: PlantifyApp()),
    ),
  );
}

class PlantifyApp extends StatelessWidget {
  const PlantifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    
    return MaterialApp(
      title: 'Plantify AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeService.themeMode,
      home: const SplashScreen(),
    );
  }
}