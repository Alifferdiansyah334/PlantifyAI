import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/featured_carousel.dart';
import '../widgets/article_tile.dart';
import '../services/article_service.dart';
import '../services/language_service.dart';
import 'article_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final articleService = Provider.of<ArticleService>(context);
    final langService = Provider.of<LanguageService>(context);

    // Use allArticles to include featured ones in the search/filter results
    final filteredArticles = articleService.allArticles.where((article) {
      final matchesSearch =
          article.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              article.summary.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' ||
          article.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    final categories = ['All', ...ArticleService.categories];

    return Scaffold(
      backgroundColor: AppTheme.primaryDarkBackground,
      body: CustomScrollView(
        slivers: [
          // 1. SliverAppBar
          SliverAppBar(
            backgroundColor: AppTheme.primaryDarkBackground,
            expandedHeight: 70.0,
            floating: false,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16, top: 0),
              expandedTitleScale: 1.2,
              title: Text(
                langService.translate('Knowledge Base', 'Pusat Pengetahuan'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),

          // 2. Sticky Search & Filter Header
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(
              minHeight: 120,
              maxHeight: 120,
              child: Container(
                color: AppTheme.primaryDarkBackground,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppTheme.cardSurfaceDark,
                          hintText: langService.translate('Search diseases, tips...', 'Cari penyakit, tips...'),
                          hintStyle:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textMediumEmphasis,
                                  ),
                          prefixIcon: const Icon(Icons.search,
                              color: AppTheme.textMediumEmphasis),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Category Filters
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: categories.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return _buildCategoryChip(
                              category, _selectedCategory == category);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Featured Carousel
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: FeaturedCarousel(
                articles: articleService.featuredArticles,
              ),
            ),
          ),

          // 4. Section Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                langService.translate('Latest Articles', 'Artikel Terbaru'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),

          // 5. Article List (Filtered)
          filteredArticles.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(
                      child: Text(
                        langService.translate('No articles found.', 'Artikel tidak ditemukan.'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textMediumEmphasis,
                            ),
                      ),
                    ),
                  ),
                )
              : SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ArticleTile(
                            article: filteredArticles[index],
                            heroTag: 'library_list_${filteredArticles[index].id}',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ArticleDetailScreen(
                                      article: filteredArticles[index],
                                      heroTag: 'library_list_${filteredArticles[index].id}',
                                      ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      childCount: filteredArticles.length,
                    ),
                  ),
                ),

          // Bottom Spacer
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryTeal : AppTheme.cardSurfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryTeal
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isSelected ? Colors.white : AppTheme.textMediumEmphasis,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
        ),
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _StickyHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}