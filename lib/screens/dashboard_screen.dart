import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/profile_section.dart';
import '../widgets/hero_detection_card.dart';
import '../widgets/section_title.dart';
import '../widgets/crop_card.dart';
import '../widgets/article_list_item.dart';
import 'library_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import '../services/article_service.dart';
import '../services/language_service.dart';
import '../models/article.dart';
import 'article_detail_screen.dart';
import 'onboarding_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  bool _isScrolled = false;

  @override
  Widget build(BuildContext context) {
    final articleService = Provider.of<ArticleService>(context);
    final langService = Provider.of<LanguageService>(context);

    // Safer article lookup
    Article? riceArticle;
    Article? tomatoArticle;

    try {
      riceArticle = articleService.articles.firstWhere(
        (a) => a.id == '7', 
        orElse: () => articleService.articles.isNotEmpty ? articleService.articles[0] : articleService.featuredArticles[0]
      );
      tomatoArticle = articleService.articles.firstWhere(
        (a) => a.id == '6', 
        orElse: () => articleService.articles.length > 1 ? articleService.articles[1] : articleService.featuredArticles[0]
      );
    } catch (e) {
      // Fallback if absolutely no articles exist
      const fallback = Article(
        id: '0', title: 'Loading...', category: '...', imageUrl: 'assets/images/rice_field.jpg',
        date: '', readTime: '', summary: '', content: '', authorName: '', authorRole: ''
      );
      riceArticle ??= fallback;
      tomatoArticle ??= fallback;
    }
    
    final tipsArticles = articleService.articles.take(3).toList();

    return Scaffold(
      extendBody: true,
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification && notification.metrics.axis == Axis.vertical) {
            final double offset = notification.metrics.pixels;
            final double maxScroll = notification.metrics.maxScrollExtent;

            // If scrolled down past 30 AND not near the bottom, shrink the navbar
            if (offset > 30 && offset < maxScroll - 20 && !_isScrolled) {
              setState(() => _isScrolled = true);
            } 
            // If at top OR at bottom, restore the navbar
            else if ((offset <= 30 || offset >= maxScroll - 20) && _isScrolled) {
              setState(() => _isScrolled = false);
            }
          }
          return false; // Allow notification to bubble up
        },
        child: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _currentIndex,
            children: [
              // Index 0: Home
              SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const ProfileSection(),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.cardSurfaceDark,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            child: const Icon(Icons.help_outline_rounded, color: Colors.white),
                          ),
                        ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                         .shimmer(duration: 2000.ms, color: Colors.white.withValues(alpha: 0.3))
                         .boxShadow(
                            borderRadius: BorderRadius.circular(40),
                            begin: const BoxShadow(color: Colors.transparent, blurRadius: 0),
                            end: BoxShadow(
                              color: AppTheme.primaryTeal.withValues(alpha: 0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                            duration: 1500.ms,
                            curve: Curves.easeInOut,
                         ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const HeroDetectionCard(),
                    const SizedBox(height: 20),
                    SectionTitle(
                      title: langService.translate('My Crops Articles', 'Artikel Tanaman Saya'),
                      actionText: langService.translate('See All', 'Lihat Semua'),
                      onActionTap: () => setState(() => _currentIndex = 1),
                    ),
                    SizedBox(
                      height: 160,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          CropCard(
                            title: langService.translate('Rice Care', 'Perawatan Padi'),
                            subtitle: riceArticle.title,
                            imagePath: riceArticle.imageUrl,
                            heroTag: 'dashboard_crop_rice_${riceArticle.id}',
                            onTap: () => _navigateToArticle(context, riceArticle!, 'dashboard_crop_rice_${riceArticle.id}'),
                          ),
                          CropCard(
                            title: langService.translate('Tomato Care', 'Perawatan Tomat'),
                            subtitle: tomatoArticle.title,
                            imagePath: tomatoArticle.imageUrl,
                            heroTag: 'dashboard_crop_tomato_${tomatoArticle.id}',
                            onTap: () => _navigateToArticle(context, tomatoArticle!, 'dashboard_crop_tomato_${tomatoArticle.id}'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SectionTitle(title: langService.translate('Latest Farming Tips', 'Tips Pertanian Terbaru')),
                    Column(
                      children: tipsArticles.asMap().entries.map((entry) {
                        final index = entry.key;
                        final article = entry.value;
                        return ArticleListItem(
                          title: article.title,
                          subtitle: article.summary,
                          imagePath: article.imageUrl,
                          heroTag: 'dashboard_tip_${index}_${article.id}',
                          onTap: () => _navigateToArticle(context, article, 'dashboard_tip_${index}_${article.id}'),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 120), 
                  ],
                ),
              ),
              const LibraryScreen(),
              const HistoryScreen(),
              const SettingsScreen(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildFluidNavbar(langService),
    );
  }

  void _navigateToArticle(BuildContext context, Article article, String heroTag) {
    if (article.id == '0') return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleDetailScreen(article: article, heroTag: heroTag),
      ),
    );
  }

  Widget _buildFluidNavbar(LanguageService langService) {
    return Container(
      height: 100, // Fixed outer height to prevent Scaffold layout jumps
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          AnimatedPadding(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            padding: _isScrolled 
                ? const EdgeInsets.fromLTRB(24, 0, 24, 24) 
                : EdgeInsets.zero,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              height: 70,
              decoration: BoxDecoration(
                color: AppTheme.cardSurfaceDark,
                borderRadius: BorderRadius.circular(_isScrolled ? 35 : 0),
                boxShadow: [
                  if (_isScrolled)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_isScrolled ? 35 : 0),
                child: BottomNavigationBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  selectedItemColor: AppTheme.primaryTeal,
                  unselectedItemColor: AppTheme.iconColorInactive,
                  showUnselectedLabels: true,
                  type: BottomNavigationBarType.fixed,
                  currentIndex: _currentIndex,
                  onTap: (index) => setState(() {
                    _currentIndex = index;
                    _isScrolled = false; // Reset on tab change for safety
                  }),
                  items: [
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.home_filled),
                      label: langService.translate('Home', 'Beranda'),
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.menu_book_rounded),
                      label: langService.translate('Library', 'Pustaka'),
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(LucideIcons.history),
                      label: langService.translate('History', 'Riwayat'),
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.settings_rounded),
                      label: langService.translate('Settings', 'Pengaturan'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
